import numpy as np
import psimd_test_fns
from psimd_test_fns import smul8

computeTB = open("../computeTB.bsv", "w")
computeTB.write("`include \"compute.bsv\"\n\
import pbox_types     :: * ;\n\
\n\
(*synthesize*)\n\
module mkTest(Empty);\n\
    Reg#(Bit#(8)) counter <- mkReg(0);\n\
\n\
    rule count;\n\
        counter <= counter + 1;\n\
        if(counter >= 50) begin\n\
            $display(\"[TB] Timeout\");\n\
            $finish;\n\
        end\n\
    endrule\n\
\
    rule compute;")
computeTB.close()

pyout = open("./outputs/pyout.txt", "w")
i=1
pyout.write("[TB {j}] {ans}\n".format(ans=smul8(np.int64(35134353456),np.int64(435346546), i), j=i))


pyout.close()
pyout = open("./outputs/pyout.txt", "a")
pyout.write("[TB] Timeout")
computeTB = open("../computeTB.bsv", "a")
computeTB.write("\n\tendrule\nendmodule")
computeTB.close()
print("finished")