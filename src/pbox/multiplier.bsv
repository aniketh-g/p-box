interface Ifc_Mult#(numeric type n);
    method Action start(Bit#(n) inpA, Bit#(n) inpB);
    method ActionValue#(Bit#(TMul#(n, 2))) result;
endinterface : Ifc_Mult

typedef enum {Idle, Mult, Result, Ready} State deriving (Bits, Eq);

module mkMult(Ifc_Mult#(16));
    // provisos(
    //     Mul#(nlen, 2, TAdd#(TDiv#(nlen, 2), TAdd#(TDiv#(nlen, 2), TAdd#(TDiv#(nlen, 2), TDiv#(nlen, 2))))),
    //     Add#(a__, TDiv#(nlen, 2), TMul#(TDiv#(nlen, 2), 2))
    // );


    Reg#(State) state <- mkReg(Idle);

    Reg#(Bit#(8)) inpA0 <- mkReg(0);
    Reg#(Bit#(8)) inpA1 <- mkReg(0);
    Reg#(Bit#(8)) inpB0 <- mkReg(0);
    Reg#(Bit#(8)) inpB1 <- mkReg(0);

    Reg#(Bit#(32)) answer <- mkReg(0);

    Ifc_Mult#(8) dadda_mult <- mkDadda;

    rule dadda(state == Mult);
        $display("mkMult rule dadda:\tinpA0=%d,inpA1=%d,inpB0=%d,inpB1=%d\n", inpA0, inpA1, inpB0, inpB1);
        dadda_mult.start(inpA0, inpB0);
        state <= Result;
    endrule

    method Action start(Bit#(16) inpA, Bit#(16) inpB);
        inpA1 <= inpA[15:8];
        inpA0 <= inpA[7:0];
        inpB1 <= inpB[15:8];
        inpB0 <= inpB[7:0];
        state <= Mult;
    endmethod
    method ActionValue#(Bit#(TMul#(16,2))) result;
        let ans <- dadda_mult.result();
        state <= Idle;
        return {'0, ans};
    endmethod

endmodule : mkMult


module mkDadda (Ifc_Mult#(n))
    provisos(
        Add#(a__, n, TMul#(n, 2))
    );
    Reg#(Bit#(TMul#(n, 2))) product  <- mkReg(0);
    Reg#(Bit#(n)) d  <- mkReg(0);
    Reg#(Bit#(n)) r   <- mkReg(0);

    Reg#(State) state <- mkReg(Idle);
  
    rule cycle (state == Mult);
       if ((r&1) !=0) product <= product + {'0,d};
       d <= d << 1;
       r <= r >> 1;
       if (r == 0) state <= Ready;
       $display("mkDadda rule cycle:\tstate =%d d=%d,r=%d,product=%d\n",state, d,r,product);
    endrule
  
    method Action start (x, y) if (state == Idle);
        d <= x; r <= y; product <= 0;
        state <= Mult;
        $display("mkDadda method start:\tstate =%d d=%d,r=%d,product=%d\n",state, d,r,product);
    endmethod
          
    method ActionValue#(Bit#(TMul#(n, 2))) result if (state == Ready);
        $display("here");
        state <= Idle;
        return product;
    endmethod : result
endmodule: mkDadda