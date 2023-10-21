package usmultiplier;
import Vector :: *;
export usmultiplier::*;

`define debug

function Bit#(x) gen_carry(Bit#(x) snew_prev, Bit#(x) s, Bit#(x) cin);
    Bit#(x) cout = 0;
    for(Integer i=0; i<valueOf(x)-1; i=i+1)
        if(i != valueOf(x) - 1) cout[i] = (snew_prev[i+1]&s[i])|(snew_prev[i+1]&cin[i])|(s[i]&cin[i]);
        else                    cout[i] = (s[i]&cin[i]);
    return cout;
endfunction
function Bit#(x) gen_sum(Bit#(x) snew_prev, Bit#(x) s, Bit#(x) cin);
    Bit#(x) sout;
    for(Integer i=0; i<valueOf(x); i=i+1)
        if(i != valueOf(x) - 1) sout[i] = snew_prev[i+1]^s[i]^cin[i];
        else                    sout[i] = (s[i]^cin[i]);
    return sout;
endfunction

interface Ifc_Mult#(numeric type n, numeric type m);
    method Action start(Bit#(n) inpA, Bit#(m) inpB, Bit#(1) sign_config);
    method ActionValue#(Bit#(TAdd#(n, m))) result;
endinterface : Ifc_Mult

typedef enum {Idle, Compute, Ready} MultState deriving (Bits, Eq);

module mkUSMult16(Ifc_Mult#(n, m))
    provisos(Add#(1, b__, n));
    Reg#(MultState)         state <- mkReg(Idle);
    Reg#(Bit#(TAdd#(n, m))) p <- mkReg(0);
    Reg#(Bit#(n))           a <- mkReg(0);
    Reg#(Bit#(m))           b <- mkReg(0);
    Reg#(Bit#(1))           sgn <- mkReg(0);

    rule compute (state == Compute);
        `ifdef debug $display("mkMult16 method compute; Compute (state %b)", state); `endif
        Vector#(m, Bit#(n)) s = newVector();
        Vector#(m, Bit#(n)) snew = newVector();
        Vector#(m, Bit#(n)) carries = newVector();
        
        `ifdef debug $display("sign_config = ", sgn); `endif

        for(Integer i = 0; i < valueOf(m); i = i + 1)
            for(Integer j = 0; j < valueOf(n); j = j + 1)
                if(((j == valueOf(n) - 1) || (i == valueOf(m) - 1)) && 
                    !((j == valueOf(n) - 1) && (i == valueOf(m) - 1))) s[i][j] = (a[j] & b[i])^sgn;
                else s[i][j] = a[j] & b[i];

        `ifdef debug for(Integer i = 0; i < valueOf(m); i = i + 1) $display("s[%d] = %b", i, s[i]); `endif

        carries[0] = 0;
        if(valueOf(n) == valueOf(m)) carries[0][valueOf(n)-1] = sgn;
        else begin
            carries[0][valueOf(n)-2] = sgn;
            carries[0][valueOf(m)-2] = sgn;
        end

        snew[0] = s[0];
        Bit#(TSub#(m,0)) direct_sum = 0;
        for(Integer v = 0; v < valueOf(m); v = v + 1)
            if(v != valueOf(m) - 1) begin
                direct_sum[v] = snew[v][0];
                carries[v+1] = gen_carry(snew[v], s[v+1], carries[v]);
                snew[v+1] = gen_sum(snew[v], s[v+1], carries[v]);
                `ifdef debug $display("carries[%d] = %b, snew[%d] = %b", v, carries[v], v, snew[v]); `endif
            end
            else begin
                direct_sum[v] = snew[v][0];
                `ifdef debug $display("carries[%d] = %b, snew[%d] = %b", v, carries[v], v, snew[v]); `endif
            end

        Bit#(n) final_sum = {sgn, snew[valueOf(m)-1][valueOf(n)-1:1]}+carries[valueOf(m)-1];
        `ifdef debug $display("fs:%ba:%b", final_sum, direct_sum); `endif

        p <= {final_sum, direct_sum};
        state <= Ready;
    endrule : compute

    method Action start(Bit#(n) inpA, Bit#(m) inpB, Bit#(1) sign_config) if(state == Idle);
        a <= inpA;
        b <= inpB;
        sgn <= sign_config;
        state <= Compute;
        `ifdef debug $display("mkMult16 method start; Idle (state %b)", state); `endif
    endmethod

    method ActionValue#(Bit#(TAdd#(n,m))) result if(state == Ready);
        `ifdef debug $display("mkMult16 method result; AddPPs (state %b)", state); `endif
        state <= Idle;
        return p;
    endmethod

endmodule : mkUSMult16
endpackage : usmultiplier