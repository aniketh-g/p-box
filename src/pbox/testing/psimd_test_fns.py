import warnings
import numpy as np
warnings.filterwarnings("ignore")

debug = False
sep = ''

def sm8(a, b, isSigned, isSaturate):
    ov = 0
    # Ensure the input values are 8-bit
    a = a & 0xFF
    b = b & 0xFF

    if(isSigned):
        # Convert to signed values
        a = a if a < 128 else a - 256
        b = b if b < 128 else b - 256

    # Perform multiplication
    result = a * b
    if(isSaturate):
        if (result >= 2**15):
            result = 2**15-1
            ov = 1
        elif (result < -2**15):
            result = -2**15
            ov = 1
        else:
            ov = 0

    # Handle overflow by taking the least significant 8 bits
    return [format(result & 0xFFFF, "016b"), ov]

def smul8(a, b, i): #1010100AAAAABBBBB000DDDDD1110111
    funct7 = "1010100"
    funct3 = "000"
    f = open("../computeTB.bsv", "a")
    f.write("""\n\t\tif(counter == {j}) $display("[TB {j}] %b", fn_compute(PBoxIn{o}instr: 32'b{f7}{rs1addr}{rs2addr}{f3}{rdaddr}{opcode}, rs1: 64'd{rs1}, rs2: 64'd{rs2}, rd:  64'd{rd}{c}).data);"""\
            .format(f7=funct7, f3=funct3, rs1=a, rs2=b, rd=0, rs1addr="00000", rs2addr="00000", rdaddr="00000", opcode="1110111", o='{', c='}', j=i))
    f.close()

    a8s = list((a >> i) & 0xFF for i in range(0,64,8))
    b8s = list((b >> i) & 0xFF for i in range(0,64,8))
    if(debug): print(a8s, b8s)
    res = sm8(a8s[3], b8s[3], True, False)[0] + sep +\
          sm8(a8s[2], b8s[2], True, False)[0] + sep +\
          sm8(a8s[1], b8s[1], True, False)[0] + sep +\
          sm8(a8s[0], b8s[0], True, False)[0]
    if(debug): print(res)
    return res