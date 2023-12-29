package multiplier_by4_module;
import Vector :: *;
export multiplier_by4_module::*;

`define debug

interface Ifc_Mult#(numeric type n);
    method Action start(Bit#(n) _a, Bit#(n) _b, Bit#(1) _sgn, Bit#(TMul#(n,2)) _sgn_by_4);
    method Bit#(TMul#(n, 2)) result;
endinterface : Ifc_Mult

typedef enum {Idle, Compute, Ready} MultState deriving (Bits, Eq);

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


module mkMult(Ifc_Mult#(n))
    provisos(Add#(1, a__, n), Add#(b__, 1, TAdd#(n, n)),Add#(c__, 2, TAdd#(n, n)),Add#(d__, 3, TAdd#(n, n)),Add#(e__, 16, TAdd#(n, n)),Add#(f__, TMul#(n, 2), TAdd#(n, n)));

    Wire#(Bit#(n)) a <- mkDWire(0);
    Wire#(Bit#(n)) b <- mkDWire(0);
    Wire#(Bit#(1)) sgn <- mkDWire(0);
    Wire#(Bit#(TMul#(n,2))) sgn_by_4 <- mkDWire(0);

    Reg#(Bit#(TAdd#(n, n))) p <- mkReg(0);

    rule compute;

        Vector#(n, Bit#(n)) s = newVector();
        Vector#(n, Bit#(n)) snew = newVector();
        Vector#(n, Bit#(n)) carries = newVector();
        
        // `ifdef debug $display("sign_config = ", sgn); `endif

        for(Integer i = 0; i < valueOf(n); i = i + 1)
            for(Integer j = 0; j < valueOf(n); j = j + 1) begin
                if(((j == valueOf(n) - 1) || (i == valueOf(n) - 1)) && !((j == valueOf(n) - 1) && (i == valueOf(n) - 1))) s[i][j] = (a[j] & b[i])^sgn;
                else if(((j == valueOf(TDiv#(TMul#(n,3),4)) - 1) || (i == valueOf(TDiv#(TMul#(n,3),4)) - 1)) && //border adders
                    !((j == valueOf(TDiv#(TMul#(n,3),4)) - 1) && (i == valueOf(TDiv#(TMul#(n,3),4)) - 1) &&  //intersection
                        (i >= valueOf(TDiv#(n,2)) && (j >= valueOf(TDiv#(n,2)))))) //avoiding cross product
                        s[i][j] = (a[j] & b[i])^(sgn_by_4[0]);
                else if(((j == valueOf(TDiv#(n,4)) - 1) || (i == valueOf(TDiv#(n,4)) - 1)) && //border adders
                    !((j == valueOf(TDiv#(n,4)) - 1) && (i == valueOf(TDiv#(n,4)) - 1) &&  //intersection
                        (i < valueOf(TDiv#(n,4)) && (j < valueOf(TDiv#(n,4)))))) //avoiding cross product
                        s[i][j] = (a[j] & b[i])^(sgn_by_4[0]);
                else if(((i <  valueOf(TDiv#(n,4)) && j >= valueOf(TDiv#(n,4))) ||
                        (i >= valueOf(TDiv#(n,4)) && j <  valueOf(TDiv#(n,4)))))
                        s[i][j] = (a[j] & b[i]) & (~sgn_by_4[0]);
                else s[i][j] = a[j] & b[i];
            end
        `ifdef debug for(Integer i = 0; i < valueOf(n); i = i + 1) $display("s[%d] = %b", i, s[i]); `endif

        carries[0] = 0;
        carries[0][valueOf(n)-1] = sgn;
        //carries[0][valueOf(TDiv#(TMul#(n,3),4))-1] = sgn_by_4[0];
        //carries[0][valueOf(TDiv#(n,4))-1] = sgn_by_4[0];

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

        p <= {final_sum, direct_sum} + {0,sgn_by_4<<(valueOf(TDiv#(TMul#(n,3),2))-1)} + {0,sgn_by_4<<(valueOf(TDiv#(n,2))-1)} + {0,sgn_by_4<<(valueOf(TDiv#(TMul#(n,5),4)))} + {0,sgn_by_4<<(valueOf(TDiv#(n,4)))};

    endrule : compute
    
    method Action start(Bit#(n) _a, Bit#(n) _b, Bit#(1) _sgn, Bit#(TMul#(n,2)) _sgn_by_4);
        a <= _a;
        b <= _b;
        sgn <= _sgn;
        sgn_by_4 <= _sgn_by_4;
    endmethod

    method Bit#(TMul#(n,2)) result;
        return p;
    endmethod
    
endmodule

endpackage : multiplier_by4_module