package fulladdermodule;
export fulladdermodule::*;

import fulladder::*;

interface Ifc_Mult#(numeric type n);
   method Action start(Bit#(1) _a, Bit#(1) _b, Bit#(1) _c);
    method Bit#(2) result;
endinterface : Ifc_Mult

module mkMult(Ifc_Mult#(n))
	provisos(Add#(1, a__, n));
	Wire#(Bit#(1)) a <- mkWire();
    	Wire#(Bit#(1)) b <- mkWire();
    	Wire#(Bit#(1)) c <- mkWire();
    	// Wire#(Bit#(TMul#(n,2))) sgn_by_4 <- mkDWire(0);

    	Reg#(Bit#(1)) s <- mkReg(0);
    	Reg#(Bit#(1)) cout <- mkReg(0);
    	
	
	rule compute;
		s <= (fullAdd(a, b, c))[1];
		cout <= (fullAdd(a, b, c))[0];
		
	endrule : compute

method Action start(Bit#(1) _a, Bit#(1) _b, Bit#(1) _c);
        a <= _a;
        b <= _b;
        c <= _c;
        // sgn_by_4 <= _sgn_by_4;
    endmethod

    method Bit#(2) result;
        return {s,cout};
    endmethod
    
endmodule
endpackage : fulladdermodule
