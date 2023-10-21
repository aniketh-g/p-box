import usmultiplier::*;
typedef enum {Idle, Multiply, Next, Finish} TbState deriving (Bits, Eq);

(*synthesize*)
module mkTest(Empty);
    Ifc_Mult#(8,4) usMult <- mkUSMult16;
    Reg#(TbState) tbstate <- mkReg(Idle);

    rule idle(tbstate == Idle);
        tbstate <= Next;
        usMult.start(-8'd46, 4'd7, 1'b1);
    endrule
    rule printans ( tbstate == Next );
        let ans <- usMult.result;
        $display("ans = %b = %d = -%d", ans, ans, ~ans+1);
    endrule : printans
endmodule : mkTest