import usmultiplier::*;
//import usmultiplier_debug::*;
typedef enum {Idle, Multiply, Next, Finish} TbState deriving (Bits, Eq);

`define isModule

(*synthesize*)
module mkTest(Empty);
    //`ifdef isModule Ifc_Mult#(4,4) usMult <- mkUSMult16; `endif
    Reg#(TbState) tbstate <- mkReg(Idle);

    rule idle(tbstate == Idle);
        tbstate <= Next;
        //`ifdef isModule usMult.start(-4'd5, -4'd7, 1'b1);`endif
        //`ifndef isModule
        let ans = usMult(-4'd5, -4'd7, 1'b1);
        $display("ans = %b = %d = -%d", ans, ans, ~ans+1);
        //`endif
    endrule
    //`ifdef isModule
    //rule printans ( tbstate == Next );
      //  let ans <- usMult.result;
       // $display("ans = %b = %d = -%d", ans, ans, ~ans+1);
    //endrule : printans
    //`endif
endmodule : mkTest
