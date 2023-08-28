`include "pbox.defines"
import pbox_types     :: * ;
import ccore_types    :: * ;
`include "Zbpbo.bsv"
`include "Zpn.bsv"
`include "Zpsfoperand.bsv"


/*doc: function: The top function where depending on the instruction the
  required function is called, get the result and return it. */
  function PBoxOut fn_compute(PBoxIn inp);
    Bit#(XLEN) result;
    Bool valid;
    case(inp.instr) matches
      // Zbpbo:
      `ifdef RV32
      `CLZ: begin
        result = pack(fn_clz(inp.rs1));
        valid = True;
      end
      `endif
      `MAX: begin
        result = pack(fn_max(unpack(inp.rs1), unpack(inp.rs2)));
        valid = True;
      end
      `MIN: begin
        result = pack(fn_min(unpack(inp.rs1), unpack(inp.rs2)));
        valid = True;
      end
      // `REV8H: begin
      //   result = fn_rev8(inp.rs1);
      //   valid = True;
      // end
      // Zpn:
      `ADD16: begin
        result = fn_add16(inp.rs1, inp.rs2);
        valid = True;
    end
      `RADD16: begin
        result = fn_radd16(inp.rs1, (inp.rs2));
        valid = True;
    end
     `URADD16: begin
       result = fn_uradd16(inp.rs1, inp.rs2);
       valid = True;
    end
    //  `KADD16: begin
    //    result = fn_kadd16(inp.rs1, inp.rs2);
    //    valid = True;
    // end 
    `ifdef RV64
    `ADD32: begin
      result = fn_add32(inp.rs1, inp.rs2);
      valid = True;
    end
    `endif
      // Zpsfoperand:

  // `ifdef RV64
  //     // Zbpbo:
  //     `CLZW: begin
  //       result = pack(fn_clzw(inp.rs1));
  //       valid = True;
  //     end
  // `endif
      default: begin
        result = 0;
        valid = False;
      end
    endcase
    return PBoxOut{valid: valid, data: result};
  endfunction