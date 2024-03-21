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
		if(counter == 0) $display("[TB 0] %b", fn_compute(PBoxIn{instr: 32'b10010110000000000000000001110111, rs1: 64'd-3553853771712429421, rs2: 64'd1788620915780492940, rd:  64'd0}).data);
		if(counter == 1) $display("[TB 1] %b", fn_compute(PBoxIn{instr: 32'b10010110000000000000000001110111, rs1: 64'd7032031820933117380, rs2: 64'd-6157805992505108441, rd:  64'd0}).data);
		if(counter == 2) $display("[TB 2] %b", fn_compute(PBoxIn{instr: 32'b10010110000000000000000001110111, rs1: 64'd-5466469145498337575, rs2: 64'd6783330468557074739, rd:  64'd0}).data);
		if(counter == 3) $display("[TB 3] %b", fn_compute(PBoxIn{instr: 32'b10010110000000000000000001110111, rs1: 64'd5228612751417242621, rs2: 64'd2586921091222162107, rd:  64'd0}).data);
		if(counter == 4) $display("[TB 4] %b", fn_compute(PBoxIn{instr: 32'b10010110000000000000000001110111, rs1: 64'd7898653154592458327, rs2: 64'd6836979712931834467, rd:  64'd0}).data);
	endrule
endmodule