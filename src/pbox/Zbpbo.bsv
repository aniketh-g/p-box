/* Subset of Bit manipulation extension instructions 
which are needed in the application domains covered by P extension.
Contains instructions from Zbb, Zbt, Zbp of B-extension.
*/

/* doc: func: Function to implement CLZ instruction
 * Returns number of leading zeros (before first set bit) in the input, from MSB
 */
 function UInt#(XLEN) fn_clz(Bit#(XLEN) rs1);
    // zero extend for type compatibility
    return zeroExtend(countZerosMSB(rs1));
  endfunction

/* doc: func: Function to implement MAX instruction
 * Returns the maximum value (signed) among both inputs
 */
function Int#(XLEN) fn_max(Int#(XLEN) rs1, Int#(XLEN) rs2);
    return (rs1 > rs2) ? rs1:rs2;
  endfunction

/* doc: func: Function to implement MIN instruction
 * Returns the minimum value (signed) among both inputs
 */
 function Int#(XLEN) fn_min(Int#(XLEN) rs1, Int#(XLEN) rs2);
    return (rs1 < rs2) ? rs1:rs2;
  endfunction  