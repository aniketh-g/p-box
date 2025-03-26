`include "Zpsfoperand.bsv"


typedef enum {Idle, Compute, Next, Finish} TbState deriving (Bits, Eq);

(*synthesize*)
module mkTest(Empty);
    Reg#(TbState) tbstate <- mkReg(Idle);
    Ifc_binaryOp_PBox mul_box <- mkMulIns;

    rule idle(tbstate == Idle);
        tbstate <= Compute;
        $display("TB Idle");
        Bit#(4) a = 4'b0110;
        Bit#(4) b = 4'b0011;
        $display("%d+%d=%b", a, b, tpl_2(qnadd(a,b)));
        Bit#(3) x = round(5'b01010);
        $display("%b", x);
    endrule
    rule multiply(tbstate == Compute);
        $display("TB multiply");
        mul_box.writeInput(7'b0011101, 3'b001,
                        { 16'd6524, -16'd4312,  16'd9214, -16'd8319},
                        { 16'd2842, -16'd5318, -16'd3034, -16'd7912});
        tbstate <= Next;
    endrule

    rule display_ans ( tbstate == Next );
        let ansa <- mul_box.getOutput();
        tbstate <= Finish;
        $display("TB Next; ansa = %b", ansa.data);
        // $display("ansa.data = %x = [0...0],%d,%d = %d, %d, %d, %d", ansa.data, ansa.data[31:16], ansa.data[15:0], ansa.data[63:48], ansa.data[47:32], ansa.data[31:16], ansa.data[15:0]);
        // $display("\t\t\t\t\t\t   = -%d,-%d,-%d,-%d", 1+~ansa.data[63:48], 1+~ansa.data[47:32], 1+~ansa.data[31:16], 1+~ansa.data[15:0]);
        $display("ans = %d, %d\n    = -%d, -%d", ansa.data[63:32], ansa.data[31:0], 1+~ansa.data[63:32], 1+~ansa.data[31:0]);
    endrule : display_ans
endmodule : mkTest

/*Explain temp variation as a concept in PVT & an issue in OCV?
in PVT: Gross, diff atm temp
in OCV: Subtle, changes within a die
*/