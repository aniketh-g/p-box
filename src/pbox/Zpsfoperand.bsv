/*
Zpsfoperand extension will read or write 64-bit operands using register-pairs in
RV32P. For RV32P, this is an optional sub-extension. For RV64P, the Zpsfoperand extension is a
required extension.
*/

import pbox_types     :: * ;
import multiplier     :: * ;

// `define reuse_mul // If defined, 2 multipliers will be reused, reducing area & increasing time
// `define debug

typedef enum {Idle, W_in, W_out
              `ifdef reuse_mul, Repeat `endif
              , Finish} Mul16State deriving (Bits, Eq);

module mkMul16(Ifc_binaryOp_PBox);

    Reg#(Mul16State) state         <- mkReg(Idle);
    Reg#(Bit#(XLEN)) rv1           <- mkReg(0);
    Reg#(Bit#(XLEN)) rv2           <- mkReg(0);
    Reg#(Bit#(7))    funct7_local  <- mkReg(0);
    Reg#(Bit#(XLEN)) result        <- mkReg(0);
    Reg#(Bool)       valid         <- mkReg(False);
    Reg#(Bool)       isNegW0_reg   <- mkReg(False);
    Reg#(Bool)       isNegW1_reg   <- mkReg(False);
    Ifc_Mult#(16)    multiplier0   <- mkMult;
    Ifc_Mult#(16)    multiplier1   <- mkMult;
    `ifdef reuse_mul
    Reg#(Bit#(1))    x             <- mkReg(0);
    `else
    Reg#(Bool)       isNegW2_reg   <- mkReg(False);
    Reg#(Bool)       isNegW3_reg   <- mkReg(False);
    Ifc_Mult#(16)    multiplier2   <- mkMult;
    Ifc_Mult#(16)    multiplier3   <- mkMult;
    `endif

    rule compute_w_in (state == W_in 
                       `ifdef reuse_mul || state == Repeat `endif
                       );
        `ifdef debug $display("State = %d", state); `endif
        `ifdef debug $display("rv1 = %x = %d,%d,%d,%d\nrv2 = %x = %d,%d,%d,%d\n",
                  rv1, rv1[63:48], rv1[47:32], rv1[31:16], rv1[15:0],
                  rv2, rv2[63:48], rv2[47:32], rv2[31:16], rv2[15:0]); `endif

        Bool isNegW0 = False;
        Bool isNegW1 = False;
        `ifndef reuse_mul
        Bool isNegW2 = False;
        Bool isNegW3 = False;
        `endif

        Bool isUMUL  = funct7_local[4:3] == 2'b11;
        Bit#(1) isX  = (funct7_local[4] & funct7_local[0])|(~funct7_local[4] & funct7_local[3]);

        Bit#(16) op1_w0 = rv1[15:0];
        Bit#(16) op1_w1 = rv1[31:16];
        `ifndef reuse_mul
        Bit#(16) op1_w2 = rv1[47:32];
        Bit#(16) op1_w3 = rv1[63:48];
        `endif
        if (!isUMUL) begin
            if (op1_w0[15] == 1'b1) begin
                op1_w0 = ~op1_w0 + 1;
                isNegW0 = !isNegW0;
                `ifdef debug $display("%d is negative", op1_w0); `endif
            end
            if (op1_w1[15] == 1'b1) begin
                op1_w1 = ~op1_w1 + 1;
                isNegW1 = !isNegW1;
                `ifdef debug $display("%d is negative", op1_w1); `endif
            end
            `ifndef reuse_mul
            if (op1_w2[15] == 1'b1) begin
                op1_w2 = ~op1_w2 + 1;
                isNegW2 = !isNegW2;
                `ifdef debug $display("%d is negative", op1_w2); `endif
            end
            if (op1_w3[15] == 1'b1) begin
                op1_w3 = ~op1_w3 + 1;
                isNegW3 = !isNegW3;
                `ifdef debug $display("%d is negative", op1_w3); `endif
            end
            `endif
        end

        Bit#(16) op2_w0 = rv2[15:0];
        Bit#(16) op2_w1 = rv2[31:16];
        `ifndef reuse_mul
        Bit#(16) op2_w2 = rv1[47:32];
        Bit#(16) op2_w3 = rv1[63:48];
        `endif
        if (isX == 1) begin
            op2_w0 = rv2[31:16];
            op2_w1 = rv2[15:0];
            `ifndef reuse_mul
            op2_w2 = rv2[63:48];
            op2_w3 = rv2[47:32];
            `endif
        end
        if (!isUMUL) begin
            if (op2_w0[15] == 1'b1) begin
                op2_w0 = ~op2_w0 + 1;
                isNegW0 = !isNegW0;
                `ifdef debug $display("%d is negative", op2_w0); `endif
            end
            if (op2_w1[15] == 1'b1) begin
                op2_w1 = ~op2_w1 + 1;
                isNegW1 = !isNegW1;
                `ifdef debug $display("%d is negative", op2_w1); `endif
            end
            `ifndef reuse_mul
            if (op2_w2[15] == 1'b1) begin
                op2_w2 = ~op2_w2 + 1;
                isNegW2 = !isNegW2;
                `ifdef debug $display("%d is negative", op2_w2); `endif
            end
            if (op2_w3[15] == 1'b1) begin
                op2_w3 = ~op2_w3 + 1;
                isNegW3 = !isNegW3;
                `ifdef debug $display("%d is negative", op2_w3); `endif
            end
            `endif
        end
        multiplier0.start(op1_w0, op2_w0);
        multiplier1.start(op1_w1, op2_w1);
        `ifndef reuse_mul
        multiplier2.start(op1_w2, op2_w2);
        multiplier3.start(op1_w3, op2_w3);
        `endif
        isNegW0_reg <= isNegW0;
        isNegW1_reg <= isNegW1;
        `ifndef reuse_mul
        isNegW2_reg <= isNegW2;
        isNegW3_reg <= isNegW3;
        `endif
        state <= W_out;
    endrule : compute_w_in
    rule compute_w_out (state == W_out);
        let res0 <- multiplier0.result(); if (isNegW0_reg) begin res0 = ~res0 + 1; end
        let res1 <- multiplier1.result(); if (isNegW1_reg) begin res1 = ~res1 + 1; end
        `ifdef debug $display("w0 = %b = %d = -%d\nw1 = %b = %d = -%d", res0, res0, ~res0+1, res1, res1, ~res1+1); `endif
        `ifndef reuse_mul
        let res2 <- multiplier2.result(); if (isNegW2_reg) begin res2 = ~res2 + 1; end
        let res3 <- multiplier3.result(); if (isNegW3_reg) begin res3 = ~res3 + 1; end
        `ifdef debug $display("w2 = %b = %d = -%d\nw3 = %b = %d = -%d", res2, res2, ~res2+1, res3, res3, ~res3+1); `endif
        `endif

        if(funct7_local[4] == 0) begin
            `ifdef reuse_mul
            if(x == 0) begin
                result[31:0]  <= {res1[30:15], res0[30:15]};
                x             <= 1;
                rv1[31:0]     <= rv1[63:32];
                rv2[31:0]     <= rv2[63:32];
                state         <= Repeat;
                
            end
            else begin
                result[63:32] <= {res1[30:15], res0[30:15]};
                x             <= 0;
                valid         <= True;
                state         <= Finish;
            end
            `else
            result            <= {res3[30:15], res2[30:15],res1[30:15], res0[30:15]};
            valid             <= True;
            state             <= Finish;
            `endif
        end
        else begin
            result <= {res1, res0};
            valid  <= True;
            state  <= Finish;
        end
    endrule : compute_w_out

    method Action writeInput(Bit#(7) funct7, Bit#(XLEN) rs1, Bit#(XLEN) rs2) if (state==Idle);
        rv1           <= rs1;
        rv2           <= rs2;
        funct7_local  <= funct7;
        state         <= W_in;
        `ifdef reuse_mul x <= 0; `endif
    endmethod

    method ActionValue#(PBoxOut) getOutput if (state == Finish);
        `ifdef reuse_mul x <= 0; `endif
        valid   <= False;
        state   <= Idle;
        return PBoxOut{valid: valid, data: result};
    endmethod

endmodule