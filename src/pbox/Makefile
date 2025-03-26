.PHONY: testnby2multiplier
testnby2multiplier: 
	@bsc dadda_8.bsv
	@bsc nby2multiplier.bsv
	@bsc -verilog testbench.bsv
	@bsc -e mkTest mkTest.v
	@./a.out

.PHONY: testUSmultiplier
testUSmultiplier: 
	@bsc usmultiplier.bsv
	@bsc usmultiplier_debug.bsv
	@bsc -verilog usmultiplierTB.bsv
	@bsc -e mkTest mkTest.v
	@./a.out +RTS -K40000M +RTS

.PHONY: testMultiplier_by4
testMultiplier_by4: 
	@bsc multiplier_by4.bsv
	@bsc multiplier_by4_module.bsv
	@bsc -verilog multiplier_b4_TB.bsv +RTS -K40000M +RTS
	@bsc -e mkTest mkTest.v +RTS -K40000M +RTS
	@./a.out

.PHONY: testmul
testmul:
	@bsc pbox_types.bsv
	@bsc dadda_8.bsv
	@bsc nby2multiplier.bsv
	@bsc usmultiplier.bsv
	@bsc Zpsfoperand.bsv
	@echo "Compiled Successfully, Running Testbench"
	@bsc -verilog Zpsfoperand_TB.bsv +RTS -K40000M -RTS
	@bsc -e mkTest mkTest.v +RTS -K40000M -RTS
	@./a.out

TESTOUT= ./testing/outputs/

.PHONY: testcompute
testcompute:
	@echo "Generating testbench..."
	@cd testing; python3 gen_test.py
	@echo "\033[0;32mTestbench generated: computeTB.bsv\033[0m"
	@echo "Running tests..."
	@bsc pbox_types.bsv
	@bsc usmultiplier.bsv
	@bsc multiplier_by4.bsv
	@bsc compute.bsv
	@bsc -verilog -steps 10000000 computeTB.bsv +RTS -K1000000M -RTS
	@bsc -e mkTest mkTest.v +RTS -K1000000M -RTS
	@./a.out > $(TESTOUT)/tbout.txt
	@echo "\033[0;32mGenerated testbench outputs\033[0m"
	@cmp $(TESTOUT)/tbout.txt $(TESTOUT)/pyout.txt && echo "\033[0;32m--- ALL TESTS PASSED !!! ---" || echo "\033[0;31m--- TEST FAILED ---"

VERILOG = ../../build/hw/verilog
SYNTHOUT = ./synthout

.PHONY: synthesize
synthesize:
	@yosys -o $(SYNTHOUT)/mbox.blif -S $(VERILOG)/mkmbox.v > $(SYNTHOUT)/mbox.txt
	@yosys -o $(SYNTHOUT)/pbox.blif -S $(VERILOG)/mkpbox.v > $(SYNTHOUT)/pbox.txt

.PHONY: clean
clean:
	@rm -r *.bo *.v *.out
	@cd $(TESTOUT); rm -r *.txt
	@echo "Cleaned"
