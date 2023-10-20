package usmultiplier;
import Vector :: *;
export usmultiplier::*;

`define debug

function Bit#(x) gen_carry(Bit#(x) a, Bit#(x) b, Bit#(x) cin);
    Bit#(x) cout = 0;
    for(Integer i=0; i<valueOf(x)-1; i=i+1) begin
        cout[i+1] = (a[i]&b[i])|(a[i]&cin[i])|(b[i]&cin[i]);
    end
    return cout;
endfunction
function Bit#(x) gen_sum(Bit#(x) a, Bit#(x) b, Bit#(x) cin);
    Bit#(x) sout;
    for(Integer i=0; i<valueOf(x); i=i+1) begin
        sout[i] = a[i]^b[i]^cin[i];
    end
    return sout;
endfunction

interface Ifc_Mult#(numeric type n, numeric type m);
    method Action start(Bit#(n) inpA, Bit#(m) inpB, Bit#(1) sign_config);
    method ActionValue#(Bit#(TAdd#(n, m))) result;
endinterface : Ifc_Mult

typedef enum {Idle, Compute, Ready} MultState deriving (Bits, Eq);

module mkUSMult16(Ifc_Mult#(n, m));
    Reg#(MultState) state <- mkReg(Idle);
    Reg#(Bit#(TAdd#(n, m))) p <- mkReg(0);
    Reg#(Bit#(n)) a <- mkReg(0);
    Reg#(Bit#(m)) b <- mkReg(0);
    Reg#(Bit#(1)) sgn <- mkReg(0);

    rule compute (state == Compute);
        `ifdef debug $display("mkMult16 method compute; Compute (state %b)", state); `endif
        Vector#(m, Bit#(TAdd#(n,m))) s = newVector();
        Vector#(m, Bit#(TAdd#(n,m))) snew = newVector();
        Vector#(m, Bit#(TAdd#(n,m))) carries = newVector();
        
        `ifdef debug $display("sign_config = ", sgn); `endif

        for(Integer i = 0; i < valueOf(m); i = i + 1)
            for(Integer j = i; (j-i) < valueOf(n); j = j + 1)
                if(((j-i == valueOf(n)-1) || (i == valueOf(m) - 1)) && !((j-i == valueOf(n)-1) && (i == valueOf(m) - 1)))
                    s[i][j] = (a[j-i] & b[i])^sgn;
                else
                    s[i][j] = a[j-i] & b[i];
                
        for(Integer k = 1; k < valueOf(m); k = k + 1)
            for(Integer l = 0 ; l < k; l = l + 1)
                s[k][l] = 1'b0;

        for(Integer z = 0; z < valueOf(m); z = z + 1)
            for (Integer x = z + valueOf(n); x < valueOf(TAdd#(n, m)) - 1;  x= x + 1)
                    s[z][x] = 1'b0;

        `ifdef debug
        for(Integer i = 0; i < valueOf(m); i = i + 1)
            $display("s[%d] = %b", i, s[i]);
        `endif

        carries[0] = 0;
        carries[0][valueOf(m)+valueOf(n)-1] = sgn;
        if(valueOf(n) == valueOf(m)) carries[0][valueOf(n)] = sgn;
        else begin
            carries[0][valueOf(n)-1] = sgn;
            carries[0][valueOf(m)-1] = sgn;
        end
        snew[0] = s[0];

        for(Integer v = 0; v < valueOf(m) - 1; v = v + 1) begin
            carries[v+1] = gen_carry(snew[v], s[v+1], carries[v]);
            snew[v+1] = gen_sum(snew[v], s[v+1], carries[v]);
            $write("carries[%d] = %b, ", v, carries[v]);
            $write("snew[%d] = %b\n", v, snew[v]);
        end
        p <= snew[valueOf(m)-2]+carries[valueOf(m)-2]+s[valueOf(m)-1];
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