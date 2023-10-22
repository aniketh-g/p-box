/*
Zpsfoperand extension will read or write 64-bit operands using register-pairs in
RV32P. For RV32P, this is an optional sub-extension. For RV64P, the Zpsfoperand extension is a
required extension.
*/

import pbox_types     :: * ;
import multiplier     :: * ;
import usmultiplier   :: * ;

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

typedef enum {Idle, Compute, Finish} MulState deriving (Bits, Eq);

module mkMulIns(Ifc_binaryOp_PBox);

    Reg#(MulState) state           <- mkReg(Idle);
    Reg#(Bit#(XLEN)) rv1           <- mkReg(0);
    Reg#(Bit#(XLEN)) rv2           <- mkReg(0);
    Reg#(Bit#(XLEN)) rd            <- mkReg(0);
    Reg#(Bit#(7))    f7            <- mkReg(0);
    Reg#(Bit#(3))    f3            <- mkReg(0);
    Reg#(Bit#(1))    ov            <- mkReg(0);
    Reg#(Bit#(XLEN)) result        <- mkReg(0);
    Reg#(Bool)       valid         <- mkReg(False);
    Bit#(1) is16bitMulAcc = (~f7[6] & f7[4] & f7[3] & f7[2] & ~f7[1]) | (~f7[6] & f7[5] & ~f7[4] & f7[2]) | (~f7[6] & f7[5] & f7[2] & ~f7[1]) | (~f7[6] & f7[5] & f7[2] & ~f7[0]) | (f7[6] & ~f7[5] & ~f7[4] & f7[2] & ~f7[1]) | (f7[6] & ~f7[5] & ~f7[3] & f7[2] & ~f7[1]) | (f7[6] & ~f7[5] & f7[2] & f7[1] & ~f7[0]) | (~f7[6] & f7[2] & ~f7[1] & ~f7[0]);
    Bit#(1) is16bitMul = (f3[0] & is16bitMulAcc) | (~f3[0]);

    rule compute16 ((is16bitMul == 1) && state == Compute);
        `ifdef debug $display("State = %d", state); `endif
        `ifdef debug $display("rv1 = %x = %d,%d,%d,%d\nrv2 = %x = %d,%d,%d,%d\n",
                  rv1, rv1[63:48], rv1[47:32], rv1[31:16], rv1[15:0],
                  rv2, rv2[63:48], rv2[47:32], rv2[31:16], rv2[15:0]); `endif

        Bit#(16) mul0_ip1 = rv1[15: 0];
        Bit#(16) mul1_ip1 = rv1[31:16];
        Bit#(16) mul2_ip1 = rv1[47:32];
        Bit#(16) mul3_ip1 = rv1[63:48];

        Bit#(16) mul0_ip2 = rv2[15: 0];
        Bit#(16) mul1_ip2 = rv2[31:16];
        Bit#(16) mul2_ip2 = rv1[47:32];
        Bit#(16) mul3_ip2 = rv1[63:48];

        Bit#(1) isSMUL = 0;

        // Decode instruction and select inputs for multiplier

        Bit#(1) isMul16 = ~f3[0];
        Bit#(1) isMul16A32 = f3[0]&((~f7[6] & ~f7[1]) | (~f7[6] & ~f7[3]) | (~f7[6] & ~f7[0]));
        Bit#(1) isMul16A64 = f3[0]&((f7[3] & f7[1] & f7[0]) | (f7[6]));
        if(isMul16 == 1) begin
            isSMUL  = ~(f7[4]&f7[3]);
            Bit#(1) isX  = (f7[4] & f7[0])|(~f7[4] & f7[3]);

            if (isX == 1) begin
                mul0_ip2 = rv2[31:16];
                mul1_ip2 = rv2[15:0];
                mul2_ip2 = rv2[63:48];
                mul3_ip2 = rv2[47:32];
            end
        end
        else if((isMul16A32|isMul16A64) == 1) begin
            `ifdef debug $display("isMul16A32 %b, isMul16A64 %b", isMul16A32, isMul16A64); `endif
            isSMUL = 1;
            // Cross Inputs?
            Bit#(1) isX           = (~f7[6] & ~f7[5] & ~f7[4] & f7[3]) | (f7[5] & f7[4] & f7[3] & ~f7[0]) | (~f7[5] & f7[4] & f7[0]) | (~f7[6] & ~f7[3] & f7[0]) | (~f7[5] & f7[3] & f7[1]);
            // Single multiplication or double?
            Bit#(1) isSingle      = (~f7[5] & ~f7[4] & ~f7[1] & ~f7[0]) | (~f7[5] & ~f7[3] & ~f7[1] & ~f7[0]) | (~f7[6] & ~f7[4] & f7[3] & ~f7[1] & f7[0]) | (f7[5] & f7[4] & f7[0]);
            Bit#(1) isInvStraight = (f7[5] & f7[4] & f7[3] & f7[0]) | (~f7[5] & f7[4] & ~f7[3] & ~f7[1] & ~f7[0]) | (~f7[5] & ~f7[4] & ~f7[3] & f7[0]);
            
            `ifdef debug $display("isSingle %b, isInvStraight %b, isX %b", isSingle, isInvStraight, isX); `endif

            // If isX, cross only second input
            if((isX | isInvStraight) == 1) begin
                mul0_ip2 = rv2[31:16];
                mul1_ip2 = rv2[15:0];
                mul2_ip2 = rv2[63:48];
                mul3_ip2 = rv2[47:32];
            end
            // If isInvStraight, cross first input as well
            if(isInvStraight == 1) begin
                mul0_ip1 = rv1[31:16];
                mul1_ip1 = rv1[15:0];
                mul2_ip1 = rv1[63:48];
                mul3_ip1 = rv1[47:32];
            end
            Bit#(1) isSMAL = (f7[1] & f7[0]);
            if((isMul16A64 & isSMAL) == 1) begin
                mul0_ip1 = rv2[63:48];
                mul0_ip2 = rv2[47:32];
                mul1_ip1 = rv2[31:16];
                mul1_ip2 = rv2[15:0];
            end
        end
        // Compute Products
        let mul0 = usMult(mul0_ip1, mul0_ip2, isSMUL);
        let mul1 = usMult(mul1_ip1, mul1_ip2, isSMUL);
        let mul2 = usMult(mul2_ip1, mul2_ip2, isSMUL);
        let mul3 = usMult(mul3_ip1, mul3_ip2, isSMUL);

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
                mul2 = ~mul2 + 1;
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
        else if(isMul16A64 == 1) begin
            Bit#(1) isAcc64 = (~f7[5] & f7[0]) | (~f7[5] & f7[1]);
            Bit#(1) ism1_neg = (f7[4]) | (f7[3] & ~f7[1]);
            Bit#(1) ism0_neg = (f7[4] & ~f7[0]);

            if(~isAcc64 == 1) begin
                result <= rd+signExtend(mul0)+signExtend(mul1);
                state <= Finish;
            end
            else if(isAcc64 == 1) begin
                if(ism1_neg == 1) begin
                    mul1 = ~mul1+1;
                    mul3 = ~mul3+1;
                end
                if(ism0_neg == 1) begin
                    mul0 = ~mul0+1;
                    mul0 = ~mul0+1;
                end
                result <= rd+signExtend(mul0)+signExtend(mul1)+signExtend(mul2)+signExtend(mul3);
                state <= Finish;
            end
        end
    endrule : compute16


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