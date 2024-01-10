`include "compute.bsv"
import pbox_types     :: * ;

(*synthesize*)
module mkTest(Empty);
    Reg#(Bit#(8)) counter <- mkReg(0);

    rule count;
        counter <= counter + 1;
        if(counter >= 50) begin
            $display("[TB] Timeout");
            $finish;
        end
    endrule

    rule compute;
        if(counter == 1) $display("[TB] %b", fn_compute(PBoxIn{instr: 32'b00111010000000000001000001110111, rs1: 64'd335432534512, rs2: 64'd5435435634532, rd:  64'd0}));
    endrule
endmodule