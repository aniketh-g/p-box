import baughwooley::*;
import baughwooley_module::*;
typedef enum {Idle, Multiply, Next, Finish} TbState deriving (Bits, Eq);

//`define isModule

(*synthesize*)
module mkTest(Empty);
    Reg#(TbState) tbstate <- mkReg(Idle);
    Reg#(Bit#(8)) counter <- mkReg(0);

    `ifdef isModule
    Ifc_Mult#(8) bwMult <- mkMult;
    `endif

    rule count;
        counter <= counter+1;
        if(counter == 50) $finish;
    endrule : count

    `ifndef isModule
    rule test;
        if(counter == 1) begin
            let ans = bwMult(8'd37,
                         8'd42, 1'b1);
            $display("Direct: ans = %b = %d = -%d", ans, ans, ~ans+1);
        end
    endrule
    `endif

    `ifdef isModule
    rule test_module;
        if(counter == 1) begin
            bwMult.start(8'b00100011,
                         8'b00010010, 1'b1);
        end
        if(counter == 2) begin
            let ans = bwMult.result;
            $display("Direct: ans = %b = %d = -%d", ans, ans, ~ans+1);
        end
    endrule : test_module
    `endif
endmodule : mkTest