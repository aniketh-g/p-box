/*
Zpsfoperand extension will read or write 64-bit operands using register-pairs in
RV32P. For RV32P, this is an optional sub-extension. For RV64P, the Zpsfoperand extension is a
required extension.
*/

import pbox_types     :: * ;
import multiplier     :: * ;
import usmultiplier     :: * ;

`define debug

function Tuple2#(Bit#(1), Bit#(32)) q31add(Bit#(32) a, Bit#(32)  b);
    Bit#(1) ov = 0;
    let sum = a + b;
    if(a[31] == b[31] && sum[31] != a[31]) begin
        ov = 1;
        case(a[31]) matches
            1'b1: sum = 32'h80000000;
            1'b0: sum = 32'h7fffffff;
        endcase
    end
    return tuple2(ov, sum);
endfunction

typedef enum {Idle, Compute, Finish} Mul16State deriving (Bits, Eq);

module mkMul16(Ifc_binaryOp_PBox);

    Reg#(Mul16State) state         <- mkReg(Idle);
    Reg#(Bit#(XLEN)) rv1           <- mkReg(0);
    Reg#(Bit#(XLEN)) rv2           <- mkReg(0);
    Reg#(Bit#(XLEN)) rd            <- mkReg(0);
    Reg#(Bit#(7))    f7            <- mkReg(0);
    Reg#(Bit#(3))    f3            <- mkReg(0);
    Reg#(Bit#(1))    ov            <- mkReg(0);
    Reg#(Bit#(XLEN)) result        <- mkReg(0);
    Reg#(Bool)       valid         <- mkReg(False);

    rule compute (state == Compute);
        `ifdef debug $display("State = %d", state); `endif
        `ifdef debug $display("rv1 = %x = %d,%d,%d,%d\nrv2 = %x = %d,%d,%d,%d\n",
                  rv1, rv1[63:48], rv1[47:32], rv1[31:16], rv1[15:0],
                  rv2, rv2[63:48], rv2[47:32], rv2[31:16], rv2[15:0]); `endif

        Bit#(16) op1_w0 = rv1[15: 0];
        Bit#(16) op1_w1 = rv1[31:16];
        Bit#(16) op1_w2 = rv1[47:32];
        Bit#(16) op1_w3 = rv1[63:48];

        Bit#(16) op2_w0 = rv2[15: 0];
        Bit#(16) op2_w1 = rv2[31:16];
        Bit#(16) op2_w2 = rv1[47:32];
        Bit#(16) op2_w3 = rv1[63:48];

        Bit#(1) isSMUL = 0;

        // Decode instruction and select inputs for multiplier

        Bit#(1) isMul16 = ~f3[0];
        Bit#(1) isMul16A32 = f3[0]&((~f7[6] & ~f7[1]) | (~f7[6] & ~f7[3]) | (~f7[6] & ~f7[0]));
        Bit#(1) isMul16A64 = f3[0]&((f7[3] & f7[1] & f7[0]) | (f7[6]));

        if(isMul16 == 1) begin
            isSMUL  = ~(f7[4]&f7[3]);
            Bit#(1) isX  = (f7[4] & f7[0])|(~f7[4] & f7[3]);

            if (isX == 1) begin
                op2_w0 = rv2[31:16];
                op2_w1 = rv2[15:0];
                op2_w2 = rv2[63:48];
                op2_w3 = rv2[47:32];
            end
        end
        else if(isMul16A32 == 1) begin
            `ifdef debug $display("isMul16A32 == 1"); `endif
            isSMUL = 1;
            // Cross Inputs?
            // Whether single multiplication or double multiplication in each word
            // 1's        : 4,12,20,45,53,61
            // Don't cares: 0,1,2,3,5,6,7,8,9,10,11,13,14,15,16,17,18,19,24,25,26,27,30,31,32,33,34,35,40,41,42,43,48,49,50,51,55,56,57,58,59,63,64,65,66,67,71,72,73,74,75,79,80,81,82,83,87,88,89,90,91,92,93,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127
            Bit#(1) isSingle   = (~f7[5] & ~f7[4]) | (~f7[5] & ~f7[3]) | (~f7[4] & f7[3] & f7[0]) | (f7[5] & f7[4] & f7[0]);
            // If single, whether straight or cross
            // 1's        : 4,45
            // Don't cares: 0,1,2,3,5,6,7,8,9,10,11,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,46,47,48,49,50,51,52,54,55,56,57,58,59,60,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127
            // Bit#(1) isBot      = (~f7[4] & ~f7[3]) | (~f7[4] & f7[0]);
            Bit#(1) isDiag     = (~f7[5] & f7[3]) | (~f7[3] & f7[0]);
            Bit#(1) isTop      = (f7[4] & f7[3]) | (~f7[5] & f7[4]);
            // If double, whether straight or cross
            // 1's        : 29,37,39,60,62
            // Don't cares: 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,30,31,32,33,34,35,40,41,42,43,45,47,48,49,50,51,53,55,56,57,58,59,61,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127
            // (Checked only if isSingle == 0)
            Bit#(1) isX        = (f7[0]) | (f7[5] & f7[4] & f7[3]);
            
            `ifdef debug $display("isSingle %b, isDiag %b, isTop %b, isX %b", isSingle, isDiag, isTop, isX); `endif

            // If Diag or X, cross only second input
            if(((~isSingle & isX) | (isSingle & isDiag) | isTop) == 1) begin
                op2_w0 = rv2[31:16];
                op2_w1 = rv2[15:0];
                op2_w2 = rv2[63:48];
                op2_w3 = rv2[47:32];
            end
            // If isTop, cross first input as well
            if((isSingle & isTop) == 1) begin
                op1_w0 = rv1[31:16];
                op1_w1 = rv1[15:0];
                op1_w2 = rv1[63:48];
                op1_w3 = rv1[47:32];
            end
        end
        // Compute Products
        let mul0 = usMult(op1_w0, op2_w0, isSMUL);
        let mul1 = usMult(op1_w1, op2_w1, isSMUL);
        let mul2 = usMult(op1_w2, op2_w2, isSMUL);
        let mul3 = usMult(op1_w3, op2_w3, isSMUL);

        `ifdef debug $display("w0 = %b = %d = -%d\nw1 = %b = %d = -%d", mul0, mul0, ~mul0+1, mul1, mul1, ~mul1+1); `endif
        `ifdef debug $display("w2 = %b = %d = -%d\nw3 = %b = %d = -%d", mul2, mul2, ~mul2+1, mul3, mul3, ~mul3+1); `endif
        
        // Decode instruction and process outputs of multiplier
        if(isMul16 == 1) begin
            if(f7[4] == 0) begin
                result            <= {mul3[30:15], mul2[30:15],mul1[30:15], mul0[30:15]};
                valid             <= True;
                state             <= Finish;
            end
            else begin
                result <= {mul1, mul0};
                valid  <= True;
                state  <= Finish;
            end
        end
        else if(isMul16A32 == 1) begin
            // Post multiplication, whether to add or subtract mul's with each other
            Bit#(1) isAdd  = (~f7[5] & f7[4] & f7[3]) | (f7[5] & ~f7[4] & ~f7[3]);
            Bit#(1) isSub  = (f7[5] & f7[3] & ~f7[0]);
            Bit#(1) isiSub = (f7[5] & f7[4] & ~f7[3] & ~f7[0]);

            `ifdef debug $display("isAdd %b, isSub %b, isiSub %b", isAdd, isSub, isiSub); `endif

            if(isSub == 1) begin
                mul0 = ~mul0 + 1;
                mul2 = ~mul0 + 1;
            end
            if(isiSub == 1)begin
                mul1 = ~mul1 + 1;
                mul3 = ~mul3 + 1;
            end

            let res0 = mul0;
            let res1 = mul2;
            let c0 = 1'b0, c1 = 1'b0;
            if((isAdd | isSub | isiSub) == 1) begin
                {c0, res0} = q31add(mul0, mul1);
                {c1, res1} = q31add(mul2, mul3);
                ov <= c0 | c1;
            end

            // Whether accumulating or not
            Bit#(1) isAccAdd = (f7[5] & ~f7[4] & ~f7[3] & ~f7[1]) | (f7[3] & f7[1]) | (f7[4] & f7[1]) | (f7[5] & ~f7[1] & f7[0]);
            Bit#(1) isAccSub = (~f7[4] & ~f7[3] & f7[1]);

            `ifdef debug $display("isAccAdd %b, isAccSub %b", isAccAdd, isAccSub); `endif

            if(isAccSub == 1) begin
                res0 = ~res0 + 1;
                res1 = ~res1 + 1;
            end

            if((isAccAdd | isAccSub) == 1) result <= {tpl_2(q31add(rd[63:32], res1)), tpl_2(q31add(rd[31:0], res0))};
            else result <= {res1, res0};
            valid <= True;
            state <= Finish;
        end
    endrule : compute

    method Action writeInput(Bit#(7) funct7, Bit#(3) funct3, Bit#(XLEN) rs1, Bit#(XLEN) rs2) if (state==Idle);
        rv1           <= rs1;
        rv2           <= rs2;
        f7            <= funct7;
        f3            <= funct3;
        state         <= Compute;
    endmethod

    method ActionValue#(PBoxOut) getOutput if (state == Finish);
        valid   <= False;
        state   <= Idle;
        return PBoxOut{valid: valid, data: result};
    endmethod

endmodule