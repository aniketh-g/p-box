package pbox_types;

typedef 8 BYTELEN;
typedef Bit#(BYTELEN) Byte;
//usage of #define for xlen param - tbd
`ifdef RV64

 typedef 64 XLEN;
 typedef 32 XLEN_WORD;
//  typedef 68 XLEN_SIXTEENTH;
`else
 typedef 32 XLEN;
//  typedef 34 XLEN_SIXTEENTH;
`endif

typedef TLog#(XLEN) SHAMTLEN;

`ifdef RV64
typedef TLog#(XLEN_WORD) SHAMTLEN_WORD;
`endif

typedef struct {
  Bit#(32) instr;   // 32-bit Instruction
  Bit#(XLEN) rs1;   // Data of register addressed by rs1
  Bit#(XLEN) rs2;   // Data of register addressed by rs2
} PBoxIn deriving (Bits, Eq, FShow);

typedef struct {
  Bool valid;       // A bool indicating that the data is valid.
  Bit#(XLEN) data;  // The computed data
} PBoxOut deriving (Bits, Eq, FShow);

endpackage: pbox_types