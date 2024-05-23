import usmultiplier::*;
import usmultmodule::*;
//import usmultiplier_debug::*;
typedef enum {Idle, Multiply, Next, Finish} TbState deriving (Bits, Eq);

`define isModule
(*synthesize*)
module mkTest(Ifc_Mult#(32));
    let clk <- exposeCurrentClock;
    let rst <- exposeCurrentReset;
    let ifc();
    mkMult _temp(ifc);
    return ifc;
endmodule
