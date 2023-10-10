`include "pbox.defines"
import pbox_types     :: * ;
import ccore_types    :: * ;
`include "Zbpbo.bsv"
// `include "Zpn.bsv"
`include "Zpsfoperand.bsv"


/*doc: function: The top function where depending on the instruction the
  required function is called, get the result and return it. */
  function PBoxOut fn_compute(PBoxIn inp);
    Bit#(XLEN) result;
    Bool valid;
    case(inp.instr) matches
      // Zpsfoperand:
  `ifdef RV64
      // Zbpbo:
      `CLZW: begin
        result = pack(fn_clzw(inp.rs1));
        valid = True;
      end
      
  `endif
      default: begin
        result = 0;
        valid = False;
      end
    endcase
    return PBoxOut{valid: valid, data: result};
  endfunction