package fulladder;
export fulladder::*;

// `define debug

function Bit#(2) fullAdd(Bit#(1) a, Bit#(1) b, Bit#(1) c);
    
    Bit#(1) s;
    Bit#(1) cout;
    
    s = ((a)^(b)^(c));
    cout = (a&b)|(b&c)|(c&a);
    return {s, cout};

endfunction

endpackage : fulladder
