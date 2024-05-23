import usmultiplier::*;
import usmultmodule::*;
//import usmultiplier_debug::*;
typedef enum {Idle, Multiply, Next, Finish} TbState deriving (Bits, Eq);

`define isModule

(*synthesize*)
module mkTest(Empty);
    `ifdef isModule Ifc_Mult#(32) usMult <- mkMult; `endif
    Reg#(TbState) tbstate <- mkReg(Idle);
    
    Wire#(Bit#(32)) a <- mkDWire(10);
    Wire#(Bit#(32)) b <- mkDWire(20);
    Wire#(Bit#(1)) sgn <- mkDWire(1);
    // Wire#(Bit#(TMul#(n,2))) sgn_by_4 <- mkDWire(0);

    Wire#(Bit#(TAdd#(32, 32))) p <- mkReg(0);


    rule idle(tbstate == Idle);
        tbstate <= Next;
        `ifdef isModule usMult.start(a, b, sgn);`endif
        //`ifndef isModule
        //let ans = usMult.start(-4'd5, -4'd7, 1'b1);
        // $display("ans = %b = %d = -%d", ans, ans, ~ans+1);
        //`endif
    endrule
    `ifdef isModule
    rule printans ( tbstate == Next );
        let ans = usMult.result;
        $display("ans = %b = %d = -%d", ans, ans, ~ans+1);
    endrule : printans
    `endif
endmodule : mkTest
