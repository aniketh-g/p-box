`include "multiplier.bsv"

typedef enum {Idle, Multiply, Next, Finish} TbState deriving (Bits, Eq);

(*synthesize*)
module mkTest(Empty);
    Ifc_Mult#(16) multiplier <- mkMult;
    Reg#(TbState) state <- mkReg(Multiply);
    rule test(state == Multiply);
        multiplier.start(16'd7, 16'd3);
        $display("here");
        state <= Next;
    endrule

    rule display_ans ( state == Next );
        let ans <- multiplier.result();
        $display("%d", ans);
        state <= Finish;
    endrule : display_ans
endmodule : mkTest