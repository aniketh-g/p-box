#!/bin/sh
echo "Generating testbench..."
cd testing
sudo python3 gen_test.py
cd ..
echo "\033[0;32mTestbench generated: computeTB.bsv\033[0m"
echo "Running tests..."
bsc pbox_types.bsv
bsc compute.bsv
bsc -verilog -steps 10000000 computeTB.bsv +RTS -K40000M -RTS
bsc -e mkTest mkTest.v +RTS -K40000M -RTS
sudo ./a.out > /home/vaibhav/Documents/testingfiles/outputs/tbout.txt
echo "\033[0;32mGenerated testbench outputs\033[0m"
sudo cmp --silent /home/vaibhav/Documents/testingfiles/outputs/tbout.txt /home/vaibhav/Documents/testingfiles/outputs/pyout.txt && echo "\033[0;32m--- ALL TESTS PASSED !!! ---" || echo "\033[0;31m--- TEST FAILED ---"
