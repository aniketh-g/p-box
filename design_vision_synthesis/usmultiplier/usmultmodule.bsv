package usmultmodule;
export usmultmodule::*;

import usmultiplier::*;

interface Ifc_Mult#(numeric type n);
    method Action start(Bit#(n) _a, Bit#(n) _b, Bit#(1) _sgn);
    method Bit#(TMul#(n, 2)) result;
endinterface : Ifc_Mult

module mkMult(Ifc_Mult#(n))
	provisos(Add#(1, a__, n));
	Wire#(Bit#(n)) a <- mkDWire(0);
    	Wire#(Bit#(n)) b <- mkDWire(0);
    	Wire#(Bit#(1)) sgn <- mkDWire(0);
    	// Wire#(Bit#(TMul#(n,2))) sgn_by_4 <- mkDWire(0);

    	Reg#(Bit#(TAdd#(n, n))) p <- mkReg(0);
	
	rule compute;
		p <= usMult(a, b, sgn);
	endrule : compute

method Action start(Bit#(n) _a, Bit#(n) _b, Bit#(1) _sgn);
        a <= _a;
        b <= _b;
        sgn <= _sgn;
        // sgn_by_4 <= _sgn_by_4;
    endmethod

    method Bit#(TAdd#(n,n)) result;
        return p;
    endmethod
    
endmodule
endpackage : usmultmodule