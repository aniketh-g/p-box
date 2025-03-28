import numpy as np
import psimd_test_fns
from psimd_test_fns import *
import random
from random import randrange

N = 5

computeTB = open("../computeTB.bsv", "w")
computeTB.write("""\
`include "compute.bsv"\n\
import pbox_types     :: * ;\n\
\n\
(*synthesize*)\n\
module mkTest(Empty);\n\
    Reg#(Bit#(8)) counter <- mkReg(0);\n\
\n\
    rule count;\n\
        counter <= counter + 1;\n\
        if(counter >= {N}) begin\n\
            $display("[TB] Timeout");\n\
            $finish;\n\
        end\n\
    endrule\n\
\
    rule compute;"""\
.format(N=N*4+10))
computeTB.close()

pyout = open("/home/vaibhav/Documents/testingfiles/outputs/pyout.txt", "w")

i=0
for k in range(N):
    pyout.write("[TB {j}] {ans}\n".format(ans=khmx16(np.int64(randrange(-2**63,2**63-1)),np.int64(randrange(-2**63,2**63-1)), i), j=i))
   # i=i+1
   # pyout.write("[TB {j}] {ans}\n".format(ans=umulx8(np.int64(randrange(-2**63,2**63-1)),np.int64(randrange(-2**63,2**63-1)), i), j=i))
    i=i+1
   # pyout.write("[TB {j}] {ans}\n".format(ans=umul16(np.int64(randrange(-2**63,2**63-1)),np.int64(randrange(-2**63,2**63-1)), i), j=i))
   # i=i+1
   # pyout.write("[TB {j}] {ans}\n".format(ans=umulx16(np.int64(randrange(-2**63,2**63-1)),np.int64(randrange(-2**63,2**63-1)), i), j=i))
   # i=i+1
   # pyout.write("[TB {j}] {ans}\n".format(ans=umul8(np.int64(randrange(-2**63,2**63-1)),np.int64(randrange(-2**63,2**63-1)), i), j=i))

pyout.close()
pyout = open("/home/vaibhav/Documents/testingfiles/outputs/pyout.txt", "a")
pyout.write("[TB] Timeout\n")
computeTB = open("../computeTB.bsv", "a")
computeTB.write("\n\tendrule\nendmodule")
computeTB.close()
print("Generated {N} test cases".format(N=N))