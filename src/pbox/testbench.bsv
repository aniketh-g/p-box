`include "multiplier.bsv"

(*synthesize*)
module mkTest(Empty);
    Ifc_Mult#(32) multiplier <- mkMult;
    rule test;
        multiplier.start(32'd2147483647, 32'd3);
        $display("%d", multiplier.result);
    endrule
endmodule : mkTest