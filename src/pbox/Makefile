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

.PHONY: testcompute
testcompute:
	@bsc pbox_types.bsv
	@bsc usmultiplier.bsv
	@bsc compute.bsv

.PHONY: clean
clean:
	@rm -r *.bo *.v *.out
	@echo "Cleaned"
