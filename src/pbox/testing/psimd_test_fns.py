import warnings
import numpy as np
warnings.filterwarnings("ignore")

debug = False
sep = ''

def mul8(a, b, isSigned, isSaturate):
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
        return [format((result >> 7) & 0xFF, "08b"), ov]

    # Handle overflow by taking the least significant 8 bits
    return [format(result & 0xFFFF, "016b"), ov]

def smul8(a, b, i):
    funct7 = "1010100"
    funct3 = "000"
    f = open("../computeTB.bsv", "a")
    f.write("""\n\t\tif(counter == {j}) $display("[TB {j}] %b", fn_compute(PBoxIn{o}instr: 32'b{f7}{rs1addr}{rs2addr}{f3}{rdaddr}{opcode}, rs1: 64'd{rs1}, rs2: 64'd{rs2}, rd:  64'd{rd}{c}).data);"""\
            .format(f7=funct7, f3=funct3, rs1=a, rs2=b, rd=0, rs1addr="00000", rs2addr="00000", rdaddr="00000", opcode="1110111", o='{', c='}', j=i))
    f.close()

    a8s = list((a >> j) & 0xFF for j in range(0,64,8))
    b8s = list((b >> j) & 0xFF for j in range(0,64,8))
    if(debug): print(a8s, b8s)
    res = mul8(a8s[3], b8s[3], True, False)[0] + sep +\
          mul8(a8s[2], b8s[2], True, False)[0] + sep +\
          mul8(a8s[1], b8s[1], True, False)[0] + sep +\
          mul8(a8s[0], b8s[0], True, False)[0]
    if(debug): print(res)
    return res

def smulx8(a, b, i):
    funct7 = "1010101"
    funct3 = "000"
    f = open("../computeTB.bsv", "a")
    f.write("""\n\t\tif(counter == {j}) $display("[TB {j}] %b", fn_compute(PBoxIn{o}instr: 32'b{f7}{rs1addr}{rs2addr}{f3}{rdaddr}{opcode}, rs1: 64'd{rs1}, rs2: 64'd{rs2}, rd:  64'd{rd}{c}).data);"""\
            .format(f7=funct7, f3=funct3, rs1=a, rs2=b, rd=0, rs1addr="00000", rs2addr="00000", rdaddr="00000", opcode="1110111", o='{', c='}', j=i))
    f.close()

    a8s = list((a >> j) & 0xFF for j in range(0,64,8))
    b8s = list((b >> j) & 0xFF for j in range(0,64,8))
    if(debug): print(a8s, b8s)
    res = mul8(a8s[3], b8s[2], True, False)[0] + sep +\
          mul8(a8s[2], b8s[3], True, False)[0] + sep +\
          mul8(a8s[1], b8s[0], True, False)[0] + sep +\
          mul8(a8s[0], b8s[1], True, False)[0]
    if(debug): print(res)
    return res

def umul8(a, b, i):
    funct7 = "1011100"
    funct3 = "000"
    f = open("../computeTB.bsv", "a")
    f.write("""\n\t\tif(counter == {j}) $display("[TB {j}] %b", fn_compute(PBoxIn{o}instr: 32'b{f7}{rs1addr}{rs2addr}{f3}{rdaddr}{opcode}, rs1: 64'd{rs1}, rs2: 64'd{rs2}, rd:  64'd{rd}{c}).data);"""\
            .format(f7=funct7, f3=funct3, rs1=a, rs2=b, rd=0, rs1addr="00000", rs2addr="00000", rdaddr="00000", opcode="1110111", o='{', c='}', j=i))
    f.close()

    a8s = list((a >> j) & 0xFF for j in range(0,64,8))
    b8s = list((b >> j) & 0xFF for j in range(0,64,8))
    if(debug): print(a8s, b8s)
    res = mul8(a8s[3], b8s[3], False, False)[0] + sep +\
          mul8(a8s[2], b8s[2], False, False)[0] + sep +\
          mul8(a8s[1], b8s[1], False, False)[0] + sep +\
          mul8(a8s[0], b8s[0], False, False)[0]
    if(debug): print(res)
    return res

def umulx8(a, b, i):
    funct7 = "1011101"
    funct3 = "000"
    f = open("../computeTB.bsv", "a")
    f.write("""\n\t\tif(counter == {j}) $display("[TB {j}] %b", fn_compute(PBoxIn{o}instr: 32'b{f7}{rs1addr}{rs2addr}{f3}{rdaddr}{opcode}, rs1: 64'd{rs1}, rs2: 64'd{rs2}, rd:  64'd{rd}{c}).data);"""\
            .format(f7=funct7, f3=funct3, rs1=a, rs2=b, rd=0, rs1addr="00000", rs2addr="00000", rdaddr="00000", opcode="1110111", o='{', c='}', j=i))
    f.close()

    a8s = list((a >> j) & 0xFF for j in range(0,64,8))
    b8s = list((b >> j) & 0xFF for j in range(0,64,8))
    if(debug): print(a8s, b8s)
    res = mul8(a8s[3], b8s[2], False, False)[0] + sep +\
          mul8(a8s[2], b8s[3], False, False)[0] + sep +\
          mul8(a8s[1], b8s[0], False, False)[0] + sep +\
          mul8(a8s[0], b8s[1], False, False)[0]
    if(debug): print(res)
    return res

def khm8(a, b, i):
    funct7 = "1000111"
    funct3 = "000"
    f = open("../computeTB.bsv", "a")
    f.write("""\n\t\tif(counter == {j}) $display("[TB {j}] %b", fn_compute(PBoxIn{o}instr: 32'b{f7}{rs1addr}{rs2addr}{f3}{rdaddr}{opcode}, rs1: 64'd{rs1}, rs2: 64'd{rs2}, rd:  64'd{rd}{c}).data);"""\
            .format(f7=funct7, f3=funct3, rs1=a, rs2=b, rd=0, rs1addr="00000", rs2addr="00000", rdaddr="00000", opcode="1110111", o='{', c='}', j=i))
    f.close()

    a8s = list((a >> j) & 0xFF for j in range(0,64,8))
    b8s = list((b >> j) & 0xFF for j in range(0,64,8))
    if(debug): print(a8s, b8s)
    res = mul8(a8s[7], b8s[7], True, True)[0] + sep +\
          mul8(a8s[6], b8s[6], True, True)[0] + sep +\
          mul8(a8s[5], b8s[5], True, True)[0] + sep +\
          mul8(a8s[4], b8s[4], True, True)[0] + sep +\
          mul8(a8s[3], b8s[3], True, True)[0] + sep +\
          mul8(a8s[2], b8s[2], True, True)[0] + sep +\
          mul8(a8s[1], b8s[1], True, True)[0] + sep +\
          mul8(a8s[0], b8s[0], True, True)[0]
    if(debug): print(res)
    return res

def khm8(a, b, i):
    funct7 = "1001111"
    funct3 = "000"
    f = open("../computeTB.bsv", "a")
    f.write("""\n\t\tif(counter == {j}) $display("[TB {j}] %b", fn_compute(PBoxIn{o}instr: 32'b{f7}{rs1addr}{rs2addr}{f3}{rdaddr}{opcode}, rs1: 64'd{rs1}, rs2: 64'd{rs2}, rd:  64'd{rd}{c}).data);"""\
            .format(f7=funct7, f3=funct3, rs1=a, rs2=b, rd=0, rs1addr="00000", rs2addr="00000", rdaddr="00000", opcode="1110111", o='{', c='}', j=i))
    f.close()

    a8s = list((a >> j) & 0xFF for j in range(0,64,8))
    b8s = list((b >> j) & 0xFF for j in range(0,64,8))
    if(debug): print(a8s, b8s)
    res = mul8(a8s[7], b8s[6], True, True)[0] + sep +\
          mul8(a8s[6], b8s[7], True, True)[0] + sep +\
          mul8(a8s[5], b8s[4], True, True)[0] + sep +\
          mul8(a8s[4], b8s[5], True, True)[0] + sep +\
          mul8(a8s[3], b8s[2], True, True)[0] + sep +\
          mul8(a8s[2], b8s[3], True, True)[0] + sep +\
          mul8(a8s[1], b8s[0], True, True)[0] + sep +\
          mul8(a8s[0], b8s[1], True, True)[0]
    if(debug): print(res)
    return res