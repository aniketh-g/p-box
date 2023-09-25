`include "multiplier.bsv"
`include "dadda_8.bsv"

typedef enum {Idle, Multiply, Next, Finish} TbState deriving (Bits, Eq);

(*synthesize*)
module mkTest(Empty);
    Ifc_Mult#(16) multiplier <- mkMult;
    Reg#(TbState) tbstate <- mkReg(Idle);

    (* descending_urgency = "multiply, multiplier_initialize" *)
    rule idle(tbstate == Idle);
        tbstate <= Multiply;
        $display("Dadda output for 255*123 = %d", dadda_8(255, 123));
        $display("TB Idle");
    endrule
    rule multiply(tbstate == Multiply);
        $display("TB multiply");
        multiplier.start(16'd7, 16'd3);
        tbstate <= Next;
    endrule

    rule display_ans ( tbstate == Next );
        let ans <- multiplier.result();
        tbstate <= Finish;
        $display("TB Next; ans = %d", ans);
    endrule : display_ans
endmodule : mkTest