
`include "compute.bsv"
`include "pbox.defines"

import pbox_types :: *;

(*synthesize*)
module mkPboxTest(Empty);
    PBoxIn inp = PBoxIn{rs1: 64'b0000000000000000000000000000000000000000000000000000000000000001,
                        rs2: 64'b0000000000000000000000000000000000000000000000000000000000000001,
                        instr: 32'b01100000000000000001000000010011
                        };
    let out = fn_compute(inp);
    $display("\nrd: %b\nValid Bit: %b", out.data, out.valid);
endmodule