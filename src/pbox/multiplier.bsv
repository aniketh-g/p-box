interface Ifc_Mult#(numeric type n);
    method Action start(Bit#(n) inpA, Bit#(n) inpB);
    method Bit#(TMul#(n, 2)) result;
endinterface : Ifc_Mult

typedef enum {Idle, Dadda} State deriving (Bits, Eq);

module mkMult(Ifc_Mult#(nlen))
    provisos(
        Mul#(nlen, 2, TAdd#(TDiv#(nlen, 2), TAdd#(TDiv#(nlen, 2), TAdd#(TDiv#(nlen, 2), TDiv#(nlen, 2)))))
    );

    Integer nLen = valueOf(nlen);
    Integer hLen = valueOf(TDiv#(nlen, 2));

    State state = Dadda;

    Reg#(Bit#(TDiv#(nlen, 2))) inpA0 <- mkReg(0);
    Reg#(Bit#(TDiv#(nlen, 2))) inpA1 <- mkReg(0);
    Reg#(Bit#(TDiv#(nlen, 2))) inpB0 <- mkReg(0);
    Reg#(Bit#(TDiv#(nlen, 2))) inpB1 <- mkReg(0);

    rule dadda(state == Dadda);
        Ifc_Mult#(TDiv#(nlen,2)) dadda <- mkDadda;
    endrule

    method Action start(Bit#(nlen) inpA, Bit#(nlen) inpB);
        inpA1 <= inpA[nLen-1:hLen];
        inpA0 <= inpA[hLen-1:0];
        inpB1 <= inpB[nLen-1:hLen];
        inpB0 <= inpB[hLen-1:0];
    endmethod
    method Bit#(TMul#(nlen,2)) result;
        let temp = {inpA1,inpB1,inpA0,inpB0};
        return temp;
    endmethod

endmodule : mkMult


module mkDadda (Ifc_Mult#(n))
    provisos(
        Add#(a__, n, TMul#(n, 2))
    );
    Reg#(Bit#(TMul#(n, 2))) product  <- mkReg(0);
    Reg#(Bit#(n)) d  <- mkReg(0);
    Reg#(Bit#(n)) r   <- mkReg(0);
  
    rule cycle (r != 0);
       if ((r&1) !=0) product <= product + {'0,d};
       d <= d << 1;
       r <= r >> 1;
    endrule
  
   method Action start (x, y) if (r == 0);
      d <= x; r <= y; product <= 0;
    endmethod
          
    method result () if (r == 0);
       return product;
    endmethod
endmodule: mkDadda