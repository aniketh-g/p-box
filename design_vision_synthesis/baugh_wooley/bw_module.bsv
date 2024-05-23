package bw_module;
export bw_module::*;

import baughwooley::*;

interface Ifc_Mult#(numeric type n);
   method Action start(Bit#(n) _a, Bit#(n) _b, Bit#(1) _sgn);
    method Bit#(TAdd#(n, n)) result;
endinterface : Ifc_Mult

module mkMult(Ifc_Mult#(n))
	provisos(Add#(1, a__, n));
	Wire#(Bit#(n)) a <- mkWire();
    	Wire#(Bit#(n)) b <- mkWire();
    	Wire#(Bit#(1)) sgn <- mkWire();
    	//Wire#(Bit#(TMul#(n,2))) sgn_by_4 <- mkWire();

    	Reg#(Bit#(TAdd#(n, n))) p <- mkReg(0);
	
	rule compute;
		p <= bwMult(a, b, sgn);
	endrule : compute

method Action start(Bit#(n) _a, Bit#(n) _b, Bit#(1) _sgn);
        a <= _a;
        b <= _b;
        sgn <= _sgn;
        //sgn_by_4 <= _sgn_by_4;
    endmethod

    method Bit#(TAdd#(n,n)) result;
        return p;
    endmethod
    
endmodule
endpackage : bw_module
