package usmultiplier;
import Vector::*;
export usmultiplier::*;

`define debug

function Bit#(TAdd#(n,m)) usMult(Bit#(n) inpA, Bit#(m) inpB, Bit#(1) sign_config);
    Bit#(TAdd#(n,m)) p;

    Vector#(m, Bit#(TAdd#(n,m))) s;
    Vector#(m, Bit#(TAdd#(n,m))) snew;
    Vector#(m, Bit#(TAdd#(n,m))) carries;
    
    for(Integer i = 0; i < valueOf(m); i = i + 1)
        for(Integer j = i; (j-i) < valueOf(n); j = j + 1)
            if(((j-i == valueOf(n)-1) || (i == valueOf(m) - 1)) && !((j-i == valueOf(n)-1) && (i == valueOf(m) - 1)))
                s[i][j] = (inpA[j-i] & inpB[i])^sign_config;
            else
                s[i][j] = inpA[j-i] & inpB[i];
            
    for(Integer k = 1; k < valueOf(m); k = k + 1)
        for(Integer l = 0 ; l < k; l = l + 1)
            s[k][l] = 1'b0;
            
    for(Integer z = 0; z < valueOf(m); z = z + 1)
        for (Integer x = z + valueOf(n); x < valueOf(TAdd#(n, m)) - 1;  x= x + 1)
            if(((x == valueOf(TAdd#(n, m)) - 1) && (z == valueOf(m) - 1)) || ((z == 0) && (x == valueOf(n))))
                s[z][x] = sign_config;
            else
                s[z][x] = 1'b0;

    for(Integer v =0; v < valueOf(m) - 1; v = v + 1) begin
        
    end

    return 0;
endfunction

endpackage : usmultiplier