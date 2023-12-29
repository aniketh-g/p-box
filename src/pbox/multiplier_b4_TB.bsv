import multiplier_by4::*;
typedef enum {Idle, Multiply, Next, Finish} TbState deriving (Bits, Eq);

// `define isModule

(*synthesize*)
module mkTest(Empty);
    Reg#(TbState) tbstate <- mkReg(Idle);
    Reg#(Bit#(8)) counter <- mkReg(0);


    rule count;
        counter <= counter+1;
        if(counter == 50) $finish;
    endrule : count

    rule test;
        if(counter == 1) begin
            let ans = usMult(8'b00100011,
                             8'b00010010, 1'b1, 16'b0);
            $display("Direct: ans = %b = %d = -%d", ans, ans, ~ans+1);
        end
        if(counter == 2) begin
            let ans = usMult(8'b00100011,
                             8'b00010010, 1'b0, 16'b1);
            $display("By4: ans = %b: %b, %b", ans, ans[11:8], ans[3:0]);
        end
    endrule
endmodule : mkTest