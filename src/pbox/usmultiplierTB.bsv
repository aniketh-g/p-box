import usmultiplier::*;
typedef enum {Idle, Multiply, Next, Finish} TbState deriving (Bits, Eq);

(*synthesize*)
module mkTest(Empty);
    Reg#(TbState) tbstate <- mkReg(Idle);

    rule idle(tbstate == Idle);
        tbstate <= Multiply;
        $display("TB Idle");
    endrule
endmodule : mkTest