package multiplier_by4;
import Vector :: *;
export multiplier_by4::*;

// `define debug

function Bit#(x) gen_carry(Bit#(x) snew_prev, Bit#(x) s, Bit#(x) cin);
    Bit#(x) cout = 0;
    for(Integer i=0; i<valueOf(x); i=i+1)
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


function Bit#(TAdd#(n,n)) usMult(Bit#(n) a, Bit#(n) b, Bit#(1) sgn, Bit#(1) sgn_by_4)
    provisos(Add#(1, a__, n), Add#(b__, 1, TAdd#(n, n)));
    
    Bit#(TAdd#(n, n)) p;

    Vector#(n, Bit#(n)) s = newVector();
    Vector#(n, Bit#(n)) snew = newVector();
    Vector#(n, Bit#(n)) carries = newVector();
    
    // `ifdef debug $display("sign_config = ", sgn); `endif

    for(Integer i = 0; i < valueOf(n); i = i + 1)
        for(Integer j = 0; j < valueOf(n); j = j + 1) begin
            if(((j == valueOf(n) - 1) || (i == valueOf(n) - 1)) && !((j == valueOf(n) - 1) && (i == valueOf(n) - 1))) s[i][j] = (a[j] & b[i])^sgn;
            else if(((j == valueOf(TDiv#(TMul#(n,3),4)) - 1) || (i == valueOf(TDiv#(TMul#(n,3),4)) - 1)) && !((j == valueOf(TDiv#(TMul#(n,3),4)) - 1) && (i == valueOf(TDiv#(TMul#(n,3),4)) - 1))) s[i][j] = (a[j] & b[i])^sgn_by_4;
            else if(((j == valueOf(TDiv#(n,4)) - 1) || (i == valueOf(TDiv#(n,4)) - 1)) && !((j == valueOf(TDiv#(n,4)) - 1) && (i == valueOf(TDiv#(n,4)) - 1))) s[i][j] = (a[j] & b[i])^sgn_by_4;
            else s[i][j] = a[j] & b[i];
        end
    // `ifdef debug for(Integer i = 0; i < valueOf(n); i = i + 1) $display("s[%d] = %b", i, s[i]); `endif

    carries[0] = 0;
    carries[0][valueOf(n)-1] = sgn;
    carries[0][valueOf(TDiv#(TMul#(n,3),4))-1] = sgn_by_4;
    carries[0][valueOf(TDiv#(n,4))-1] = sgn_by_4;

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
            direct_sum[v] = snew[v][0];
            // `ifdef debug $display("carries[%d] = %b, snew[%d] = %b", v, carries[v], v, snew[v]); `endif
        end

    Bit#(n) final_sum = {sgn, snew[valueOf(n)-1][valueOf(n)-1:1]}+carries[valueOf(n)-1];
    // `ifdef debug $display("fs:%ba:%b", final_sum, direct_sum); `endif

    p = {final_sum, direct_sum};
    p = p + {0,sgn_by_4<<(valueOf(TDiv#(TMul#(n,3),2))-1)} + {0,sgn_by_4<<(valueOf(TDiv#(n,2))-1)};

    return {0,(sgn_by_4<<1)};
endfunction

endpackage : multiplier_by4