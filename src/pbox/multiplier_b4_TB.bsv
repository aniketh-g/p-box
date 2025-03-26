import multiplier_by4::*;
import multiplier_by4_module::*;
typedef enum {Idle, Multiply, Next, Finish} TbState deriving (Bits, Eq);

// `define isModule

(*synthesize*)
module mkTest(Empty);
    Reg#(TbState) tbstate <- mkReg(Idle);
    Reg#(Bit#(8)) counter <- mkReg(0);

    `ifdef isModule
    Ifc_Mult#(8) usMult <- mkMult;
    `endif

    rule count;
        counter <= counter+1;
        if(counter == 50) $finish;
    endrule : count

    `ifndef isModule
    rule test;
        if(counter == 1) begin
            let ans = usMult(64'd7830065054738571350[31:0],
            64'd4112085165966938706[31:0], 1'b0, 1'b0);
            $display("Direct: ans = %b = %d = -%d", ans[63:48], ans, ~ans+1);
        end
        if(counter == 2) begin
            let ans = usMult(8'b00100011,
                             8'b00010010, 1'b0, 1'b1);
            $display("By4: ans = %b: %b, %b", ans, ans[11:8], ans[3:0]);
        end
    endrule
    `endif

    `ifdef isModule
    rule test_module;
        if(counter == 1) begin
            usMult.start(8'b00100011,
                         8'b00010010, 1'b1, 16'b0);
        end
        if(counter == 2) begin
            let ans = usMult.result;
            $display("Direct: ans = %b = %d = -%d", ans, ans, ~ans+1);
        end
        if(counter == 3) begin
            usMult.start(8'b00100011,
                         8'b00010010, 1'b0, 16'b1);
        end
        if(counter == 4) begin
            let ans = usMult.result;
            $display("By4: ans = %b: %b, %b", ans, ans[11:8], ans[3:0]);
        end
    endrule : test_module
    `endif
endmodule : mkTest