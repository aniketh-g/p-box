`include "compute.bsv"
import pbox_types     :: * ;

(*synthesize*)
module mkTest(Empty);
    Reg#(Bit#(8)) counter <- mkReg(0);

    rule count;
        counter <= counter + 1;
        if(counter >= 30) begin
            $display("[TB] Timeout");
            $finish;
        end
    endrule
    rule compute;
		if(counter == 0) $display("[TB 0] %b", fn_compute(PBoxIn{instr: 32'b10111000000000000000000001110111, rs1: 64'd7830065056223090315, rs2: 64'd4112085164510827251, rd:  64'd0}).data);
	endrule
endmodule