interface Ifc_Mult#(numeric type n);
    method Action start(Bit#(n) inpA, Bit#(n) inpB);
    method ActionValue#(Bit#(TMul#(n, 2))) result;
endinterface : Ifc_Mult

typedef enum {Idle, Compute, Ready} MultState deriving (Bits, Eq);

module mkMult(Ifc_Mult#(m))
    provisos(
        Add#(a__, TMul#(TDiv#(m, 2), 2), TMul#(m, 2)), Add#(b__, TDiv#(m, 2), TMul#(TDiv#(m, 2), 2))
    );


    Reg#(MultState) state <- mkReg(Idle);

    Reg#(Bit#(TDiv#(m,2))) inpA0 <- mkReg(0);
    Reg#(Bit#(TDiv#(m,2))) inpA1 <- mkReg(0);
    Reg#(Bit#(TDiv#(m,2))) inpB0 <- mkReg(0);
    Reg#(Bit#(TDiv#(m,2))) inpB1 <- mkReg(0);

    Reg#(Bit#(TMul#(m,2))) answer <- mkReg(0);

    Ifc_Mult#(TDiv#(m,2)) dadda_mult <- mkDadda;

    rule dadda(state == Compute);
        $display("mkMult rule dadda:\tinpA0=%d,inpA1=%d,inpB0=%d,inpB1=%d\n", inpA0, inpA1, inpB0, inpB1);
        dadda_mult.start(inpA0, inpB0);
        state <= Ready;
    endrule

    method Action start(Bit#(m) inpA, Bit#(m) inpB);
        inpA1 <= inpA[valueOf(m)-1:valueOf(TDiv#(m,2))];
        inpA0 <= inpA[valueOf(TDiv#(m,2))-1:0];
        inpB1 <= inpB[valueOf(m)-1:valueOf(TDiv#(m,2))];
        inpB0 <= inpB[valueOf(TDiv#(m,2))-1:0];
        state <= Compute;
    endmethod
    method ActionValue#(Bit#(TMul#(m,2))) result if(state == Ready);
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

    Reg#(MultState) state <- mkReg(Idle);
  
    rule cycle (state == Compute);
       if ((r&1) !=0) product <= product + {'0,d};
       d <= d << 1;
       r <= r >> 1;
       if (r == 0) state <= Ready;
       $display("mkDadda rule cycle:\tstate =%d d=%d,r=%d,product=%d\n",state, d,r,product);
    endrule
  
    method Action start (x, y) if (state == Idle);
        d <= x; r <= y; product <= 0;
        state <= Compute;
        $display("mkDadda method start:\tstate =%d d=%d,r=%d,product=%d\n",state, d,r,product);
    endmethod
          
    method ActionValue#(Bit#(TMul#(n, 2))) result if (state == Ready);
        $display("here");
        state <= Idle;
        return product;
    endmethod : result
endmodule: mkDadda