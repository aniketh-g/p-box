interface Ifc_Mult#(numeric type n);
    method Action start(Bit#(n) inpA, Bit#(n) inpB);
    method ActionValue#(Bit#(TMul#(n, 2))) result;
endinterface : Ifc_Mult

typedef enum {Idle, Mux, AddPPs, Ready} MultState deriving (Bits, Eq);

module mkMult(Ifc_Mult#(m))
    provisos(
        Add#(a__, TMul#(TDiv#(m, 2), 2), TMul#(m, 2)), Add#(b__, TDiv#(m, 2), TMul#(TDiv#(m, 2), 2)),  Div#(m, 2, 8), Add#(m, 0, 16)
    );
    Reg#(MultState) state <- mkReg(Idle);

    Reg#(Bit#(2)) counter <- mkReg(0);

    Reg#(Bit#(TDiv#(m,2))) aL <- mkReg(0);
    Reg#(Bit#(TDiv#(m,2))) aH <- mkReg(0);
    Reg#(Bit#(TDiv#(m,2))) bL <- mkReg(0);
    Reg#(Bit#(TDiv#(m,2))) bH <- mkReg(0);

    Reg#(Bit#(m)) pp1 <- mkReg(0);
    Reg#(Bit#(m)) pp2 <- mkReg(0);
    Reg#(Bit#(m)) pp3 <- mkReg(0);
    Reg#(Bit#(m)) pp4 <- mkReg(0);

    Reg#(Bit#(TMul#(m,2))) fp <- mkReg(0);

    rule initialize (state == Idle);
        state <= Idle;
        aL <= 0; aH <= 0;
        bL <= 0; bH <= 0;
        pp1 <= 0;
        pp2 <= 0;
        pp3 <= 0;
        pp4 <= 0;
        counter <= 0;
        fp <= 0;
    endrule : initialize

    rule multiplex (state == Mux);
        counter <= counter + 1;

        Bit#(TDiv#(m,2)) inpAsel = 0;
        Bit#(TDiv#(m,2)) inpBsel = 0;
        Bit#(m) dadda_out;
        Bit#(4) y = 4'b0000;

        // Mux 1
        case (counter[1]) matches
            1'b0: inpAsel = aL;
            1'b1: inpAsel = aH;
        endcase

        // Mux 2
        case (counter[0]) matches
            1'b0: inpBsel = bL;
            1'b1: inpBsel = bH;
        endcase

        dadda_out = dadda_8(inpAsel, inpBsel);

        // Decoder
        case (counter) matches
            2'b00: pp1 <= dadda_out;
            2'b01: pp2 <= dadda_out;
            2'b10: pp3 <= dadda_out;
            2'b11: pp4 <= dadda_out;
        endcase

        if(counter == 2'b11) begin state <= AddPPs; end
        $display("mkMult rule; Mux (state %d)", state);
        $display("\tcounter = %d", counter);
        $display("\tpp1=%d, pp2=%d, pp3=%d, pp4=%d", pp1, pp2, pp3, pp4);
    endrule : multiplex

    rule addPPs (state == AddPPs);
        $display("mkMult rule; AddPs (state %d)", state);
        $display("\tpp1=%d, pp2=%d, pp3=%d, pp4=%d, fp=%d", pp1, pp2, pp3, pp4, fp);
        fp <= {pp4[15:8],
               pp4[7: 0] + pp2[15:8] + pp3[15:8],
               pp1[15:8] + pp2[7: 0] + pp3[7: 0],
               pp1[7: 0]};
        state <= Ready;
    endrule : addPPs

    method Action start(Bit#(m) inpA, Bit#(m) inpB) if(state == Idle);
        $display("mkMult method start; Idle (state %d)", state);
        aH <= inpA[valueOf(m)-1:valueOf(TDiv#(m,2))];
        aL <= inpA[valueOf(TDiv#(m,2))-1:0];
        bH <= inpB[valueOf(m)-1:valueOf(TDiv#(m,2))];
        bL <= inpB[valueOf(TDiv#(m,2))-1:0];
        state <= Mux;
        $display("\tinpA = %d, inpB = %d", inpA, inpB);
    endmethod

    method ActionValue#(Bit#(TMul#(m,2))) result if(state == Ready);
        $display("mkMult method result; AddPPs (state %d)", state);
        counter <= 0;
        state <= Idle;
        return fp;
    endmethod

endmodule : mkMult