package pbox;

//This file does the BitManip computation and returns the result. 
`include "compute.bsv"
`include "Logger.bsv"
`include "pbox.defines"
// This file has the structures being used.
// Any new structures or enum or union tagged can be included here.
import pbox_types :: *;
import ccore_types :: *;
import SpecialFIFOs   :: * ;
import FIFOF          :: * ;
import TxRx           :: * ;
import Assert         :: * ;
import DReg :: * ;

typedef struct{
        Bit#(XLEN) operand1;
        Bit#(XLEN) operand2;
        Bit#(4) opcode;
        Bit#(7) funct7;
        Bit#(3) funct3;
        Bit#(2) imm;
        Bool    issp;
}Input_Packet deriving (Bits,Eq);

interface Ifc_pbox;
  (*prefix = ""*)
  // (*always_ready, always_enabled*)
  // method Action _start(Input_Packet m); never used
  //method Action ma_inputs(Bit#(7) instr, Bit#(`xlen) rs1, Bit#(`xlen) rs2);
  // (*result = "pbox_out"*)
  // (*prefix = ""*)
  // (*always_ready, always_enabled*)
  //method PBoxOut mv_output;
  method TXe#(PBoxOut) tx_output;
  method Bit#(1) pbox_ready;
  method Action flush;
  method Action ma_inputs(PBoxIn pbox_inp);
  method Bool mv_output_valid;
endinterface

(*synthesize*)
module mkpbox#(parameter Bit#(`xlen) hartid)(Ifc_pbox);
  
  /*doc:reg: Register to store input.
    Adding this register to make the design sequential so that multiple tests
    can be run at the same time from cocotb efficiently.
  */
  FIFOF#(Bool) ff_ordering <- mkUGSizedFIFOF(max(`PSIMDSTAGES_TOTAL,3));

  Reg#(PBoxOut) rg_result <- mkDReg(PBoxOut{valid: False, data:?});
  TX#(PBoxOut) tx_pbox_out <- mkTX;
  Reg#(Bool) rg_multicycle_op <-mkReg(False);

  FIFOF# (Input_Packet) ff_input   <- mkFIFOF1;
  Wire#(Bool) wr_flush<-mkDWire(False);
  Reg#(PBoxIn) rg_input <- mkReg(unpack(0));
  FIFOF#(PBoxIn) fifo_input   <- mkFIFOF1;
  Wire#(PBoxOut) wr_output <- mkDWire(unpack(0));
  /*doc:wire: Wire which returns the output.
  */
  /*doc:rule: */
  rule rl_fifo_full(!tx_pbox_out.u.notFull());
    `logLevel( pbox, 0, $format("[%2d]PBOX: Buffer is FULL",hartid))
    // dynamicAssert(!mv_output_valid ,"PSIMD provided result when O/P FIFO is full"); //mv_output_valid wasn't defined
  endrule:rl_fifo_full

  // /*doc:rule: */
  rule rl_capture_output(ff_ordering.notEmpty);
    if (ff_ordering.first) begin 
      // if (mv_output_valid) begin //mv_output_valid should be defined directly like has been done in combo. is this block even necessary?
      //   let _x <- mv_output;
      //   tx_pbox_out.u.enq(_x);
      //   ff_ordering.deq;
      //   `logLevel( pbox, 0, $format("PBOX: Collecting o/p"))
      // end
      // else
      //   `logLevel( pbox, 0, $format("PBOX: Waiting for o/p"))
    end
    endrule:rl_capture_output

  rule rl_compute;
    // $display("rg_input: %d, %d, %d",rg_input.rs1, rg_input.rs2, rg_input.rd);
    // let _x = fn_compute(rg_input);
    $display("fifo_input:\n%d, \n%d, \n%d\ninst: funct7=%b, funct3=%b",fifo_input.first.rs1, fifo_input.first.rs2, fifo_input.first.rd, fifo_input.first.instr[31:25], fifo_input.first.instr[14:12]);
    let _x = fn_compute(fifo_input.first);
    $display("output = %d", _x.data);
    fifo_input.deq;
    tx_pbox_out.u.enq(_x);
  endrule

  rule flush_fifo(wr_flush);
		rg_multicycle_op<=False;
	endrule

  method Action ma_inputs(PBoxIn pbox_inp);
    // rg_input <= pbox_inp;
    fifo_input.enq(pbox_inp);
  endmethod

  // method PBoxOut mv_output;
  //  return wr_output;
  // endmethod

  method pbox_ready = pack(fifo_input.notFull);
  method tx_output = tx_pbox_out.e;

endmodule: mkpbox

endpackage: pbox