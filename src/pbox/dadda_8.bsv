package dadda_8;
export dadda_8::*;
// 1-bit adders

function Tuple2#(Bit#(1), Bit#(1)) fadd_1(Bit#(1) a, Bit#(1) b, Bit#(1) cin); return tuple2(a^b^cin, (a&b)|(a&cin)|(b&cin)); endfunction
function Tuple2#(Bit#(1), Bit#(1)) hadd_1(Bit#(1) a, Bit#(1) b); return tuple2(a ^ b, a & b); endfunction

// dadda multiplier
// inpA - 8 bits , inpB - 8bits, y(output) - 16bits

function Bit#(16) dadda_8(Bit#(8) inpA, Bit#(8) inpB);
    Bit#(16) y = 0;
    Bit#( 1)  gen_pp[8][8];
    Bit#( 6)s1 = 0, c1 = 0; // stage-1 sum and carry
    Bit#(14)s2 = 0, c2 = 0; // stage-2 sum and carry
    Bit#(10)s3 = 0, c3 = 0; // stage-3 sum and carry
    Bit#(12)s4 = 0, c4 = 0; // stage-4 sum and carry
    Bit#(14)s5 = 0, c5 = 0; // stage-5 sum and carry
    
    // generating partial products

    for(int i = 0; i<8; i=i+1) begin
        for(int j = 0; j<8;j = j+1) begin
            gen_pp[i][j] = inpA[j]*inpB[i];
        end
    end

    // Reduction by stages.
    // di_values = 2,3,4,6,8,13...

    // Stage 1 - reducing fom 8 to 6

    s1[0] = tpl_1(hadd_1(gen_pp[6][0], gen_pp[5][1]));
    c1[0] = tpl_2(hadd_1(gen_pp[6][0], gen_pp[5][1]));
    s1[2] = tpl_1(hadd_1(gen_pp[4][3], gen_pp[3][4]));
    c1[2] = tpl_2(hadd_1(gen_pp[4][3], gen_pp[3][4]));
    s1[4] = tpl_1(hadd_1(gen_pp[4][4], gen_pp[3][5]));
    c1[4] = tpl_2(hadd_1(gen_pp[4][4], gen_pp[3][5]));

    s1[1] = tpl_1(fadd_1(gen_pp[7][0], gen_pp[6][1], gen_pp[5][2]));
    c1[1] = tpl_2(fadd_1(gen_pp[7][0], gen_pp[6][1], gen_pp[5][2]));
    s1[3] = tpl_1(fadd_1(gen_pp[7][1], gen_pp[6][2], gen_pp[5][3]));
    c1[3] = tpl_2(fadd_1(gen_pp[7][1], gen_pp[6][2], gen_pp[5][3]));
    s1[5] = tpl_1(fadd_1(gen_pp[7][2], gen_pp[6][3], gen_pp[5][4]));
    c1[5] = tpl_2(fadd_1(gen_pp[7][2], gen_pp[6][3], gen_pp[5][4]));

    // Stage 2 - reducing fom 6 to 4

    s2[0] = tpl_1(hadd_1(gen_pp[4][0], gen_pp[3][1]));
    c2[0] = tpl_2(hadd_1(gen_pp[4][0], gen_pp[3][1]));
    s2[2] = tpl_1(hadd_1(gen_pp[2][3], gen_pp[1][4]));
    c2[2] = tpl_2(hadd_1(gen_pp[2][3], gen_pp[1][4]));
    
    s2[1] = tpl_1(fadd_1(gen_pp[5][0], gen_pp[4][1], gen_pp[3][2]));
    c2[1] = tpl_2(fadd_1(gen_pp[5][0], gen_pp[4][1], gen_pp[3][2]));
    s2[3] = tpl_1(fadd_1(s1[0], gen_pp[4][2], gen_pp[3][3]));
    c2[3] = tpl_2(fadd_1(s1[0], gen_pp[4][2], gen_pp[3][3]));
    s2[4] = tpl_1(fadd_1(gen_pp[2][4], gen_pp[1][5], gen_pp[0][6]));
    c2[4] = tpl_2(fadd_1(gen_pp[2][4], gen_pp[1][5], gen_pp[0][6]));
    s2[5] = tpl_1(fadd_1(s1[1], s1[2], c1[0]));
    c2[5] = tpl_2(fadd_1(s1[1], s1[2], c1[0]));
    s2[6] = tpl_1(fadd_1(gen_pp[2][5], gen_pp[1][6], gen_pp[0][7]));
    c2[6] = tpl_2(fadd_1(gen_pp[2][5], gen_pp[1][6], gen_pp[0][7]));
    s2[7] = tpl_1(fadd_1(s1[3], s1[4], c1[1]));
    c2[7] = tpl_2(fadd_1(s1[3], s1[4], c1[1]));
    s2[8] = tpl_1(fadd_1(c1[2], gen_pp[2][6], gen_pp[1][7]));
    c2[8] = tpl_2(fadd_1(c1[2], gen_pp[2][6], gen_pp[1][7]));
    s2[9] = tpl_1(fadd_1(s1[5], c1[3], c1[4]));
    c2[9] = tpl_2(fadd_1(s1[5], c1[3], c1[4]));
    s2[10] = tpl_1(fadd_1(gen_pp[4][5], gen_pp[3][6], gen_pp[2][7]));
    c2[10] = tpl_2(fadd_1(gen_pp[4][5], gen_pp[3][6], gen_pp[2][7]));
    s2[11] = tpl_1(fadd_1(gen_pp[7][3], c1[5], gen_pp[6][4]));
    c2[11] = tpl_2(fadd_1(gen_pp[7][3], c1[5], gen_pp[6][4]));
    s2[12] = tpl_1(fadd_1(gen_pp[5][5], gen_pp[4][6], gen_pp[3][7]));
    c2[12] = tpl_2(fadd_1(gen_pp[5][5], gen_pp[4][6], gen_pp[3][7]));
    s2[13] = tpl_1(fadd_1(gen_pp[7][4], gen_pp[6][5], gen_pp[5][6]));
    c2[13] = tpl_2(fadd_1(gen_pp[7][4], gen_pp[6][5], gen_pp[5][6]));

    // Stage 3 - reducing fom 4 to 3

    s3[0] = tpl_1(hadd_1(gen_pp[3][0], gen_pp[2][1]));
    c3[0] = tpl_2(hadd_1(gen_pp[3][0], gen_pp[2][1]));

    s3[1] = tpl_1(fadd_1(s2[0], gen_pp[2][2], gen_pp[1][3]));
    c3[1] = tpl_2(fadd_1(s2[0], gen_pp[2][2], gen_pp[1][3]));
    s3[2] = tpl_1(fadd_1(s2[1], s2[2], c2[0]));
    c3[2] = tpl_2(fadd_1(s2[1], s2[2], c2[0]));
    s3[3] = tpl_1(fadd_1(c2[1], c2[2], s2[3]));
    c3[3] = tpl_2(fadd_1(c2[1], c2[2], s2[3]));
    s3[4] = tpl_1(fadd_1(c2[3], c2[4], s2[5]));
    c3[4] = tpl_2(fadd_1(c2[3], c2[4], s2[5]));
    s3[5] = tpl_1(fadd_1(c2[5], c2[6], s2[7]));
    c3[5] = tpl_2(fadd_1(c2[5], c2[6], s2[7]));
    s3[6] = tpl_1(fadd_1(c2[7], c2[8], s2[9]));
    c3[6] = tpl_2(fadd_1(c2[7], c2[8], s2[9]));
    s3[7] = tpl_1(fadd_1(c2[9], c2[10], s2[11]));
    c3[7] = tpl_2(fadd_1(c2[9], c2[10], s2[11]));
    s3[8] = tpl_1(fadd_1(c2[11], c2[12], s2[13]));
    c3[8] = tpl_2(fadd_1(c2[11], c2[12], s2[13]));
    s3[9] = tpl_1(fadd_1(gen_pp[7][5], gen_pp[6][6], gen_pp[5][7]));
    c3[9] = tpl_2(fadd_1(gen_pp[7][5], gen_pp[6][6], gen_pp[5][7]));

    // Stage 4 - reducing fom 3 to 2

    s4[0] = tpl_1(hadd_1(gen_pp[2][0], gen_pp[1][1]));
    c4[0] = tpl_2(hadd_1(gen_pp[2][0], gen_pp[1][1]));

    s4[1] = tpl_1(fadd_1(s3[0], gen_pp[1][2], gen_pp[0][3]));
    c4[1] = tpl_2(fadd_1(s3[0], gen_pp[1][2], gen_pp[0][3]));
    s4[2] = tpl_1(fadd_1(c3[0], s3[1], gen_pp[0][4]));
    c4[2] = tpl_2(fadd_1(c3[0], s3[1], gen_pp[0][4]));
    s4[3] = tpl_1(fadd_1(c3[1], s3[2], gen_pp[0][5]));
    c4[3] = tpl_2(fadd_1(c3[1], s3[2], gen_pp[0][5]));
    s4[4] = tpl_1(fadd_1(c3[2], s3[3], s2[4]));
    c4[4] = tpl_2(fadd_1(c3[2], s3[3], s2[4]));
    s4[5] = tpl_1(fadd_1(c3[3], s3[4], s2[6]));
    c4[5] = tpl_2(fadd_1(c3[3], s3[4], s2[6]));
    s4[6] = tpl_1(fadd_1(c3[4], s3[5], s2[8]));
    c4[6] = tpl_2(fadd_1(c3[4], s3[5], s2[8]));
    s4[7] = tpl_1(fadd_1(c3[5], s3[6], s2[10]));
    c4[7] = tpl_2(fadd_1(c3[5], s3[6], s2[10]));
    s4[8] = tpl_1(fadd_1(c3[6], s3[7], s2[12]));
    c4[8] = tpl_2(fadd_1(c3[6], s3[7], s2[12]));
    s4[9] = tpl_1(fadd_1(c3[7], s3[8], gen_pp[4][7]));
    c4[9] = tpl_2(fadd_1(c3[7], s3[8], gen_pp[4][7]));
    s4[10] = tpl_1(fadd_1(c3[8], s3[9], c2[13]));
    c4[10] = tpl_2(fadd_1(c3[8], s3[9], c2[13]));
    s4[11] = tpl_1(fadd_1(c3[9], gen_pp[7][6], gen_pp[6][7]));
    c4[11] = tpl_2(fadd_1(c3[9], gen_pp[7][6], gen_pp[6][7]));

    // Stage 5 - reducing fom 2 to 1
    // adding total sum and carry to get final output

    y[1] = tpl_1(hadd_1(gen_pp[1][0], gen_pp[0][1]));
    c5[0] = tpl_2(hadd_1(gen_pp[1][0], gen_pp[0][1]));

    y[2] = tpl_1(fadd_1(s4[0], gen_pp[0][2], c5[0]));
    c5[1] = tpl_2(fadd_1(s4[0], gen_pp[0][2], c5[0]));
    y[3] = tpl_1(fadd_1(c4[0], s4[1], c5[1]));
    c5[2] = tpl_2(fadd_1(c4[0], s4[1], c5[1]));
    y[4] = tpl_1(fadd_1(c4[1], s4[2], c5[2]));
    c5[3] = tpl_2(fadd_1(c4[1], s4[2], c5[2]));
    y[5] = tpl_1(fadd_1(c4[2], s4[3], c5[3]));
    c5[4] = tpl_2(fadd_1(c4[2], s4[3], c5[3]));
    y[6] = tpl_1(fadd_1(c4[3], s4[4], c5[4]));
    c5[5] = tpl_2(fadd_1(c4[3], s4[4], c5[4]));
    y[7] = tpl_1(fadd_1(c4[4], s4[5], c5[5]));
    c5[6] = tpl_2(fadd_1(c4[4], s4[5], c5[5]));
    y[8] = tpl_1(fadd_1(c4[5], s4[6], c5[6]));
    c5[7] = tpl_2(fadd_1(c4[5], s4[6], c5[6]));
    y[9] = tpl_1(fadd_1(c4[6], s4[7], c5[7]));
    c5[8] = tpl_2(fadd_1(c4[6], s4[7], c5[7]));
    y[10] = tpl_1(fadd_1(c4[7], s4[8], c5[8]));
    c5[9] = tpl_2(fadd_1(c4[7], s4[8], c5[8]));
    y[11] = tpl_1(fadd_1(c4[8], s4[9], c5[9]));
    c5[10] = tpl_2(fadd_1(c4[8], s4[9], c5[9]));
    y[12] = tpl_1(fadd_1(c4[9], s4[10], c5[10]));
    c5[11] = tpl_2(fadd_1(c4[9], s4[10], c5[10]));
    y[13] = tpl_1(fadd_1(c4[10], s4[11], c5[11]));
    c5[12] = tpl_2(fadd_1(c4[10], s4[11], c5[11]));
    y[14] = tpl_1(fadd_1(c4[11], gen_pp[7][7], c5[12]));
    c5[13] = tpl_2(fadd_1(c4[11], gen_pp[7][7], c5[12]));

    y[0] =  gen_pp[0][0];
    y[15] = c5[13];
    return y;

endfunction
endpackage : dadda_8