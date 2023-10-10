`include "Zpsfoperand.bsv"


typedef enum {Idle, Compute, Next, Finish} TbState deriving (Bits, Eq);

(*synthesize*)
module mkTest(Empty);
    Reg#(TbState) tbstate <- mkReg(Idle);
    Ifc_binaryOp_PBox mul16a <- mkMul16;

    rule idle(tbstate == Idle);
        tbstate <= Compute;
        $display("TB Idle");
    endrule
    rule multiply(tbstate == Compute);
        $display("TB multiply");
        mul16a.writeInput(7'b1001011, { 16'd3321, -16'd2124,  16'd7432, -16'd7012},
                                      { 16'd9123, -16'd9523, -16'd3043, -16'd9561});
        tbstate <= Next;
    endrule

    rule display_ans ( tbstate == Next );
        let ansa <- mul16a.getOutput();
        tbstate <= Finish;
        $display("TB Next; ansa = %b", ansa.data);
        $display("ansa.data = %x = [0...0],%d,%d = %d, %d, %d, %d", ansa.data, ansa.data[31:16], ansa.data[15:0], ansa.data[63:48], ansa.data[47:32], ansa.data[31:16], ansa.data[15:0]);
        $display("\t\t\t\t\t\t   = -%d,-%d,-%d,-%d", 1+~ansa.data[63:48], 1+~ansa.data[47:32], 1+~ansa.data[31:16], 1+~ansa.data[15:0]);
    endrule : display_ans
endmodule : mkTest