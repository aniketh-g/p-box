/*
The instructions of RV32P and RV64P not in Zbpbo, and Zpsfoperand extensions will be included in
this sub-extension.
*/
import pbox_types     :: * ;

/* doc: func: Function to implement ADD16 
 * 
 */
 function Bit#(`xlen) fn_add16(Bit#(`xlen) rs1, Bit#(`xlen) rs2);
  Bit#(`xlen) rd = 0;
  for(Integer i = 0; i<`xlen; i = i+16) begin
    Bit#(16) temp = rs1[i+15:i] + rs2[i+15:i];
    rd[i+15:i] = temp;
  end
  return rd;
endfunction

/* doc: func: Function to implement RADD16 
 * 
 */
 function Bit#(`xlen) fn_radd16(Bit#(`xlen) rs1, Bit#(`xlen) rs2);
  Bit#(`xlen) rd = 0;
  // Bit#(TAdd#(`xlen, TDiv#(`xlen,16))) t = 0;
  // for(Integer i = 0; i<=valueOf(XLEN); i = i+16) begin
  //   Int#(17) a = signExtend(unpack(rs1[i+15:i]));
  //   Int#(17) b = signExtend(unpack(rs2[i+15:i]));
  //   Int#(17) temp = a + b;
  //   rd[i+15:i]= temp>>1; 
  // end
  return rd;
endfunction

/* doc: func: Function to implement URADD16 
 * 
 */
 function Bit#(`xlen) fn_uradd16(Bit#(`xlen) rs1, Bit#(`xlen) rs2);
  Bit#(`xlen) rd = 0;
  // Bit#(TAdd#(`xlen, TDiv#(`xlen,16))) t = 0;
  // //make 'xlen/16 and change following ops
  // for(Integer i = 0; i<`xlen; i = i+16) begin
  //   t[i+16:i] = (zeroExtend(rs1[i+15:i]) + zeroExtend(rs2[i+15:i]))>>1;
  //   rd[i+15:i] = t[i+15:i];
  // end
  return rd;
endfunction

/* doc: func: Function to implement KADD16 
 * 
 */
//  function Bit#(`xlen) fn_kadd16(Bit#(`xlen) rs1, Bit#(`xlen) rs2);
//   Bit#(`xlen) rd = 0;
//   Bit#(TAdd#(`xlen, TDiv#(`xlen,16))) t = 0;
//   for(Integer i = 0; i<`xlen; i = i+16) begin
//     t[i+16:i] = signExtend(rs1[i+15:i]) + signExtend(rs2[i+15:i]);
//     if (t[i+16:i] > (2^15)-1) 
//     //tbd-signed comparison for both if and else if blocks
//         t[i+16:i] = 32767;
//         //OV = 1;
          //tbd on csrbox
//     else if (t[i+16:i] < -(2^15)) 
//         t[i+16:i] = -32768;
//         //OV = 1;
//     rd[i+15:i]= t[i+15:i];
//   end
//   return rd;
// endfunction

`ifdef RV64
/* doc: func: Function to implement ADD32 
 * Note: RV64 Only
 */
 function Bit#(`xlen) fn_add32(Bit#(`xlen) rs1, Bit#(`xlen) rs2);
  Bit#(`xlen) rd = 0;
  rd[31:0] = rs1[valueOf(XLEN_WORD)-1:0] + rs2[valueOf(XLEN_WORD)-1:0];
  rd[63:32] = rs1[`xlen-1:valueOf(XLEN_WORD)] + rs2[`xlen-1:valueOf(XLEN_WORD)];
  return rd;
  
endfunction
`endif

