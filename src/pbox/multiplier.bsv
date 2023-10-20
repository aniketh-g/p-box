package multiplier;
export multiplier::*;
import dadda_8 :: *;

// `define debug

interface Ifc_Mult#(numeric type n);
    method Action start(Bit#(n) inpA, Bit#(n) inpB);
    method ActionValue#(Bit#(TMul#(n, 2))) result;
endinterface : Ifc_Mult

typedef enum {Idle, Mux, AddPPs, Ready} MultState deriving (Bits, Eq);

module mkMult16(Ifc_Mult#(m))
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
        
        `ifdef debug
        $display("mkMult16 rule; Mux (state %b)", state);
        $display("\tcounter = %b", counter);
        $display("\npp1=%b\npp2=%b\npp3=%b\npp4=%b\n", {16'b0,pp1}, {8'b0,pp2,8'b0}, {8'b0,pp3,8'b0}, {pp4,16'b0});
        `endif
    endrule : multiplex

    rule addPPs (state == AddPPs);

        Bit#(9) adder_1 = {0, pp1[15:8]} + {0, pp2[7: 0]} + {0, pp3[7: 0]};
        Bit#(9) adder_2 = {0, adder_1[8]} + {0, pp4[7: 0]} + {0, pp2[15:8]} + {0, pp3[15:8]};
        Bit#(8) adder_3 = {0, adder_2[8]} + {0, pp4[15:8]};
        Bit#(32) ans = {adder_3, adder_2[7:0], adder_1[7:0], pp1[7:0]};

        fp <= ans;
        state <= Ready;

        `ifdef debug
        $display("mkMult16 rule; AddPs (state %b)", state);
        $display("\npp1=%b\npp2=%b\npp3=%b\npp4=%b", {16'b0,pp1}, {8'b0,pp2,8'b0}, {8'b0,pp3,8'b0}, {pp4,16'b0});
        `endif
        $display("Multiplier ans=%b=%d", ans, ans);
    endrule : addPPs

    method Action start(Bit#(m) inpA, Bit#(m) inpB) if(state == Idle);
        aH <= inpA[valueOf(m)-1:valueOf(TDiv#(m,2))];
        aL <= inpA[valueOf(TDiv#(m,2))-1:0];
        bH <= inpB[valueOf(m)-1:valueOf(TDiv#(m,2))];
        bL <= inpB[valueOf(TDiv#(m,2))-1:0];
        state <= Mux;
        `ifdef debug
        $display("mkMult16 method start; Idle (state %b)", state);
        $display("\tinpA = %b, inpB = %b", inpA, inpB);
        $display("\taH=%b, aL=%b; bH=%b, bL=%b\n", inpA[15:8], inpA[7:0], inpB[15:8], inpB[7:0]);
        `endif
    endmethod

    method ActionValue#(Bit#(TMul#(m,2))) result if(state == Ready);
        `ifdef debug $display("mkMult16 method result; AddPPs (state %b)", state); `endif
        counter <= 0;
        state <= Idle;
        return fp;
    endmethod

endmodule : mkMult16
endpackage : multiplier