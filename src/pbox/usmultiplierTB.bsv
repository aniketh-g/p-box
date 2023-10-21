import usmultiplier::*;
typedef enum {Idle, Multiply, Next, Finish} TbState deriving (Bits, Eq);

// `define isModule

(*synthesize*)
module mkTest(Empty);
    `ifdef isModule Ifc_Mult#(8,4) usMult <- mkUSMult16; `endif
    Reg#(TbState) tbstate <- mkReg(Idle);

    rule idle(tbstate == Idle);
        tbstate <= Next;
        `ifdef isModule usMult.start(-8'd46, 4'd7, 1'b1);`endif
        `ifndef isModule let ans = usMult(-8'd89, -4'd6, 1'b1); `endif
        $display("ans = %b = %d = -%d", ans, ans, ~ans+1);
    endrule
    `ifdef isModule
    rule printans ( tbstate == Next );
        let ans <- usMult.result;
        $display("ans = %b = %d = -%d", ans, ans, ~ans+1);
    endrule : printans
    `endif
endmodule : mkTest