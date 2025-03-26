package baughwooley;
import Vector :: *;
export baughwooley::*;

// `define debug

function Bit#(x) gen_carry(Bit#(x) snew_prev, Bit#(x) s, Bit#(x) cin);
    Bit#(x) cout = 0;
    for(Integer i=0; i<valueOf(x); i=i+1)
        if(i != valueOf(x) - 1) cout[i] = (snew_prev[i+1]&s[i])|(snew_prev[i+1]&cin[i])|(s[i]&cin[i]);
        else                    cout[i] = (s[i]&cin[i]);
    return cout;
endfunction
function Bit#(x) gen_sum(Bit#(x) snew_prev, Bit#(x) s, Bit#(x) cin);
    Bit#(x) sout = 0;
    for(Integer i=0; i<valueOf(x); i=i+1)
        if(i != valueOf(x) - 1) sout[i] = snew_prev[i+1]^s[i]^cin[i];
        else                    sout[i] = (s[i]^cin[i]);
    return sout;
endfunction


function Bit#(TAdd#(n,n)) bwMult(Bit#(n) a, Bit#(n) b, Bit#(1) sgn)
    provisos(Add#(1, a__, n));
    
    Bit#(TAdd#(n, n)) p;

    Vector#(n, Bit#(n)) s = newVector();
    Vector#(n, Bit#(n)) snew = newVector();
    Vector#(n, Bit#(n)) carries = newVector();
    
    // `ifdef debug $display("sign_config = ", sgn); `endif

    for(Integer i = 0; i < valueOf(n); i = i + 1)
        for(Integer j = 0; j < valueOf(n); j = j + 1)

            if((j == valueOf(n) - 1) && !((j == valueOf(n) - 1) && (i == valueOf(n) - 1)))

                s[i][j] = (a[j]^sgn) & b[i];
            
            else if ((i == valueOf(n) - 1) && !((j == valueOf(n) - 1) && (i == valueOf(n) - 1)))

                s[i][j] = (b[i]^sgn) & a[j];

            else s[i][j] = a[j] & b[i];

    // `ifdef debug for(Integer i = 0; i < valueOf(m); i = i + 1) $display("s[%d] = %b", i, s[i]); `endif

    carries[0] = 0;
    carries[0][valueOf(n)-1] = sgn;

    snew[0] = s[0];
    Bit#(TSub#(n,0)) direct_sum = 0;
    for(Integer v = 0; v < valueOf(n); v = v + 1)
        if(v != valueOf(n) - 1) begin
            direct_sum[v] = snew[v][0];
            carries[v+1] = gen_carry(snew[v], s[v+1], carries[v]);
            snew[v+1] = gen_sum(snew[v], s[v+1], carries[v]);
            // `ifdef debug $display("carries[%d] = %b, snew[%d] = %b", v, carries[v], v, snew[v]); `endif
        end
        else begin
            direct_sum[v] = gen_sum(snew[v][0], a[valueOf(n)-1], b[valueOf(n)-1]); // a[valueOf(n)-1] & b[valueOf(n)-1] addition before vector merge
            // `ifdef debug $display("carries[%d] = %b, snew[%d] = %b", v, carries[v], v, snew[v]); `endif
        end
    Bit#(TSub#(n,1)) x = 0;
   // Bit#(TSub#(n,1)) y = 0;
    snew[valueOf(n)-1] = snew[valueOf(n)-1] + {(gen_sum((~a[valueOf(n)-1]) & sgn, (~b[valueOf(n)-1]) & sgn, (a[valueOf(n)-1] & b[valueOf(n)-1]))), x}; // a[valueOf(n)-1] & b[valueOf(n)-1] addition just before vector merge (only for signed)
    carries[valueOf(n)-1] = carries[valueOf(n)-1] + {(gen_carry((~a[valueOf(n)-1]) & sgn, (~b[valueOf(n)-1]) & sgn, (a[valueOf(n)-1] & b[valueOf(n)-1]))), x};

    Bit#(n) final_sum = {sgn, snew[valueOf(n)-1][valueOf(n)-1:1]} + carries[valueOf(n)-1] + {x, gen_carry(snew[valueOf(n)-1][0], a[valueOf(n)-1], b[valueOf(n)-1])};
    // `ifdef debug $display("fs:%ba:%b", final_sum, direct_sum); `endif

    p = {final_sum, direct_sum};

    return p;
endfunction

endpackage : baughwooley