// `include "pbox.defines"
import pbox_types     :: * ;
import multiplier_by4   :: * ;
// import ccore_types    :: * ;


/*doc: function: The top function where depending on the instruction the
  required function is called, get the result and return it. */
  function PBoxOut fn_compute(PBoxIn inp);
    Bit#(XLEN) result = 0;
    Bit#(XLEN) rv1 = inp.rs1;
    Bit#(XLEN) rv2 = inp.rs2;
    Bit#(XLEN) rd  = inp.rd;
    Bit#(1)    ov  = 0;
    Bool valid = False;
    Bit#(7) f7 = inp.instr[31:25];
    Bit#(3) f3 = inp.instr[14:12];

    // 8 bit multiplications
    Bit#(1) is8BitMul = 0;
    // 16 bit multiplications
    Bit#(1) isMul16 = 0, is16bitMulAcc = 0, isMul16A32 = 0, isMul16A64 = 0;
    // 32 bit multiplications
    Bit#(1) is32BitMulAcc = 0, isMul32A64 = 0, isMSW32Mul = 0;
    case(f3) matches
        3'b000: begin
            isMul16 = (f7[6] & ~f7[5] & f7[4] & ~f7[2]) | (f7[6] & ~f7[5] & ~f7[2] & f7[1] & f7[0]);
            is8BitMul = (f7[6] & ~f7[5] & ~f7[4] & f7[2] & f7[1] & f7[0]) | (f7[6] & ~f7[5] & f7[4] & f7[2] & ~f7[1]);
        end
        3'b001: begin
            is16bitMulAcc = (~f7[6] & f7[4] & f7[3] & f7[2] & ~f7[1]) | (~f7[6] & f7[5] & ~f7[4] & f7[2]) | (~f7[6] & f7[5] & f7[2] & ~f7[1]) | (~f7[6] & f7[5] & f7[2] & ~f7[0]) | (f7[6] & ~f7[5] & ~f7[4] & f7[2] & ~f7[1]) | (f7[6] & ~f7[5] & ~f7[3] & f7[2] & ~f7[1]) | (f7[6] & ~f7[5] & f7[2] & f7[1] & ~f7[0]) | (~f7[6] & f7[2] & ~f7[1] & ~f7[0]);
            isMul16A32 = (~f7[6] & ~f7[1]) | (~f7[6] & ~f7[3]) | (~f7[6] & ~f7[0]);
            isMul16A64 = (f7[3] & f7[1] & f7[0]) | (f7[6]);
            isMul32A64 = (~f7[6] & f7[5] & ~f7[2] & ~f7[1]);
            isMSW32Mul = (f7[6] & ~f7[5] & ~f7[2] & f7[1]);
        end
        3'b010: begin
            is32BitMulAcc = (f7[2] & ~f7[1]) | (f7[5] & f7[2]);
        end
    endcase
    Bit#(1) is16BitMul = is16bitMulAcc|isMul16;
    Bit#(1) is32BitMul = is32BitMulAcc|isMul32A64|isMSW32Mul;
    Bit#(1) isMul = is16BitMul|is32BitMul;
    //End of setting bool values
    
    // Start of assigning multiplicands to appropriate registers
    // Zpsfoperand:

    if (is8BitMul == 1) begin
        Bit#(8) byt0_ip1 = rv1[7:0];
        Bit#(8) byt1_ip1 = rv1[15:8];
        Bit#(8) byt2_ip1 = rv1[23:16];
        Bit#(8) byt3_ip1 = rv1[31:24];
        Bit#(8) byt4_ip1 = rv1[39:32];
        Bit#(8) byt5_ip1 = rv1[47:40];
        Bit#(8) byt6_ip1 = rv1[55:48];
        Bit#(8) byt7_ip1 = rv1[63:56];

        Bit#(8) byt0_ip2 = rv2[7:0];
        Bit#(8) byt1_ip2 = rv2[15:8];
        Bit#(8) byt2_ip2 = rv2[23:16];
        Bit#(8) byt3_ip2 = rv2[31:24];
        Bit#(8) byt4_ip2 = rv2[39:32];
        Bit#(8) byt5_ip2 = rv2[47:40];
        Bit#(8) byt6_ip2 = rv2[55:48];
        Bit#(8) byt7_ip2 = rv2[63:56];
        
        Bit#(16) isSign = zeroExtend(~(f7[4] & f7[3]));
        Bit#(1) isCross = f7[0];
        Bit#(1) isSat = f7[1];

        if (isCross == 1) begin // UMULX8
            byt0_ip2 = rv2[15:8];
            byt1_ip2 = rv2[7:0];
            byt2_ip2 = rv2[31:24];
            byt3_ip2 = rv2[23:16];
            byt4_ip2 = rv2[47:40];
            byt5_ip2 = rv2[39:32];
            byt6_ip2 = rv2[63:56];
            byt7_ip2 = rv2[55:48];
        end

        let prod0 = (usMult({8'b0, byt1_ip1, 8'b0, byt0_ip1}, {8'b0, byt1_ip2, 8'b0, byt0_ip2}, 0, isSign))[15:0];
        let prod1 = (usMult({8'b0, byt1_ip1, 8'b0, byt0_ip1}, {8'b0, byt1_ip2, 8'b0, byt0_ip2}, 0, isSign))[47:32];
        let prod2 = (usMult({8'b0, byt3_ip1, 8'b0, byt2_ip1}, {8'b0, byt3_ip2, 8'b0, byt2_ip2}, 0, isSign))[15:0];
        let prod2 = (usMult({8'b0, byt3_ip1, 8'b0, byt2_ip1}, {8'b0, byt3_ip2, 8'b0, byt2_ip2}, 0, isSign))[47:32];

        result = {prod3, prod2, prod1, prod0};
        valid = True;

    end

    else if (is16BitMul == 1) begin
        Bit#(16) mul0_ip1 = rv1[15: 0];
        Bit#(16) mul1_ip1 = rv1[31:16];
        Bit#(16) mul2_ip1 = rv1[47:32];
        Bit#(16) mul3_ip1 = rv1[63:48];

        Bit#(16) mul0_ip2 = rv2[15: 0];
        Bit#(16) mul1_ip2 = rv2[31:16];
        Bit#(16) mul2_ip2 = rv2[47:32];
        Bit#(16) mul3_ip2 = rv2[63:48];

        Bit#(1) isSMUL = 0;

        // Decode instruction and select inputs for multiplier

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
            // `ifdef debug $display("isMul16A32 %b, isMul16A64 %b", isMul16A32, isMul16A64); `endif
            isSMUL = 1;
            // Cross Inputs?
            Bit#(1) isX           = (~f7[6] & ~f7[5] & ~f7[4] & f7[3]) | (f7[5] & f7[4] & f7[3] & ~f7[0]) | (~f7[5] & f7[4] & f7[0]) | (~f7[6] & ~f7[3] & f7[0]) | (~f7[5] & f7[3] & f7[1]);
            // Single multiplication or double?
            Bit#(1) isSingle      = (~f7[5] & ~f7[4] & ~f7[1] & ~f7[0]) | (~f7[5] & ~f7[3] & ~f7[1] & ~f7[0]) | (~f7[6] & ~f7[4] & f7[3] & ~f7[1] & f7[0]) | (f7[5] & f7[4] & f7[0]);
            Bit#(1) isInvStraight = (f7[5] & f7[4] & f7[3] & f7[0]) | (~f7[5] & f7[4] & ~f7[3] & ~f7[1] & ~f7[0]) | (~f7[5] & ~f7[4] & ~f7[3] & f7[0]);
            
            // `ifdef debug $display("isSingle %b, isInvStraight %b, isX %b", isSingle, isInvStraight, isX); `endif

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
            let mul0 = usMult(mul0_ip1, mul0_ip2, isSMUL, 0);
            let mul1 = usMult(mul1_ip1, mul1_ip2, isSMUL, 0);
            let mul2 = usMult(mul2_ip1, mul2_ip2, isSMUL, 0);
            let mul3 = usMult(mul3_ip1, mul3_ip2, isSMUL, 0);

        // `ifdef debug $display("w0 = %b = %d = -%d\nw1 = %b = %d = -%d", mul0, mul0, ~mul0+1, mul1, mul1, ~mul1+1); `endif
        // `ifdef debug $display("w2 = %b = %d = -%d\nw3 = %b = %d = -%d", mul2, mul2, ~mul2+1, mul3, mul3, ~mul3+1); `endif
        
        // Decode instruction and process outputs of multiplier
        if(isMul16 == 1) begin
            if(f7[4] == 0) result = {mul3[30:15], mul2[30:15],mul1[30:15], mul0[30:15]};
            else result = {mul1, mul0};
            valid  = True;
        end
        else if(isMul16A32 == 1) begin
            // Post multiplication, whether to add or subtract mul's with each other
            Bit#(1) isAdd  = (~f7[5] & f7[4] & f7[3]) | (f7[5] & ~f7[4] & ~f7[3]);
            Bit#(1) isSub  = (f7[5] & f7[3] & ~f7[0]);
            Bit#(1) isiSub = (f7[5] & f7[4] & ~f7[3] & ~f7[0]);

            // `ifdef debug $display("isAdd %b, isSub %b, isiSub %b", isAdd, isSub, isiSub); `endif

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
                {c0, res0} = qnadd(mul0, mul1);
                {c1, res1} = qnadd(mul2, mul3);
                ov = c0 | c1;
            end

            // Whether accumulating or not
            Bit#(1) isAccAdd = (f7[5] & ~f7[4] & ~f7[3] & ~f7[1]) | (f7[3] & f7[1]) | (f7[4] & f7[1]) | (f7[5] & ~f7[1] & f7[0]);
            Bit#(1) isAccSub = (~f7[4] & ~f7[3] & f7[1]);

            // `ifdef debug $display("isAccAdd %b, isAccSub %b", isAccAdd, isAccSub); `endif

            if(isAccSub == 1) begin
                res0 = ~res0 + 1;
                res1 = ~res1 + 1;
            end

            if((isAccAdd | isAccSub) == 1) result = {tpl_2(qnadd(rd[63:32], res1)), tpl_2(qnadd(rd[31:0], res0))};
            else result = {res1, res0};
            valid = True;
        end
        else if(isMul16A64 == 1) begin
            Bit#(1) isAcc64 = (~f7[5] & f7[0]) | (~f7[5] & f7[1]);
            Bit#(1) ism1_neg = (f7[4]) | (f7[3] & ~f7[1]);
            Bit#(1) ism0_neg = (f7[4] & ~f7[0]);

                if(~isAcc64 == 1) begin
                    result = rd+signExtend(mul0)+signExtend(mul1);
                    valid  = True;
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
                    result = rd+signExtend(mul0)+signExtend(mul1)+signExtend(mul2)+signExtend(mul3);
                    valid  = True;
                end
            end
        end
    
    else if (is32BitMul == 1) begin
            Bit#(32) t0_ip1 = rv1[31: 0];
            Bit#(32) t1_ip1 = rv1[63:32];

        Bit#(32) t0_ip2 = rv2[31: 0];
        Bit#(32) t1_ip2 = rv2[63:32];

        Bit#(1) is32BitMulAcc_isSwitchB = (~f7[5] & ~f7[4]) | (~f7[5] & ~f7[3]) | (f7[5] & f7[4] & f7[3]) | (~f7[5] & f7[0]) | (~f7[3] & f7[0]);
        Bit#(1) is32BitMulAcc_isSwitchT = (f7[5] & f7[3] & f7[0]) | (~f7[5] & f7[4] & ~f7[0]);
        Bit#(1) is32BitMulAcc_isDirect  = (~f7[5] & ~f7[4]) | (~f7[5] & ~f7[3]);
        Bit#(1) is32BitMulAcc_isAcc     = (f7[1]) | (f7[5] & f7[0]);
        Bit#(1) is32BitMulAcc_ist0neg = (f7[5] & f7[3] & ~f7[0]) | (~f7[4] & f7[1]);
        Bit#(1) is32BitMulAcc_ist1neg = (f7[5] & ~f7[3] & ~f7[0]) | (~f7[3] & f7[1]);

        Bit#(1) isMSW32Mul_isU = (f7[4]);

        if(is32BitMulAcc == 1) begin
            if(is32BitMulAcc_isSwitchB == 1) begin
                t0_ip2 = rv2[63:32];
                t1_ip2 = rv2[31: 0];
                if(is32BitMulAcc_isSwitchT == 1) begin
                    t0_ip1 = rv1[63:32];
                    t1_ip1 = rv1[31: 0];
                end
            end
        end

        let t0 = usMult(t0_ip1, t0_ip2, ~(isMSW32Mul&isMSW32Mul_isU), 0);
        let t1 = usMult(t1_ip1, t1_ip2, ~(isMSW32Mul&isMSW32Mul_isU), 0);

        if(is32BitMulAcc == 1)begin
            if(is32BitMulAcc_isDirect == 1) begin
                result = t0;
                valid  = True;
            end
            else begin
                if(is32BitMulAcc_ist0neg == 1) t0 = ~t0+1;
                if(is32BitMulAcc_ist1neg == 1) t1 = ~t1+1;
                Bit#(XLEN) res;
                {ov, res} = qnadd(t0, t1);
                if((is32BitMulAcc_isAcc&~ov) == 1) {ov, res} = qnadd(rd, t0+t1);
                result = res;
            end
        end
        else if (isMul32A64 == 1) begin
            Bit#(1) isRound = (f7[3]);
            Bit#(1) isAcc   = (~f7[4] & f7[0]) | (f7[4] & ~f7[0]);
            Bit#(1) isDoub  = (f7[4] & f7[0]);
            Bit#(1) isAcc_isSub   = (~f7[4]);

            Bit#(32) res0;
            Bit#(32) res1;
            if(isRound == 1) begin
                res0 = round(t0);
                res1 = round(t1);
            end
            else begin
                res0 = t0[63:32];
                res1 = t1[63:32];
            end
        end
    end
    else begin
      result = ?;
      valid = False;
    end
    return PBoxOut{valid: valid, data: result};
  endfunction

// Compute Qn saturating additions
function Tuple2#(Bit#(1), Bit#(n)) qnadd(Bit#(n) a, Bit#(n)  b)
    provisos(Add#(1, a__, n));
    Bit#(1) ov = 0;
    let sum = a + b;
    if(a[valueOf(n)-1] == b[valueOf(n)-1] && sum[valueOf(n)-1] != a[valueOf(n)-1]) begin
        ov = 1;
        case(a[valueOf(n)-1]) matches
            1'b1: sum = {1'b1,'0};
            1'b0: sum = {1'b0,'1};
        endcase
    end
    return tuple2(ov, sum);
endfunction

function Bit#(m) round(Bit#(n) a);
    Bit#(TAdd#(m,1)) r = a[valueOf(TSub#(n,1)):valueOf(TSub#(TSub#(n,1),m))] + 1;
    return r[valueOf(m):1];
endfunction