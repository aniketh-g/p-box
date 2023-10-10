.PHONY: testmultiplier
testmultiplier: 
	@bsc dadda_8.bsv
	@bsc multiplier.bsv
	@bsc -verilog testbench.bsv
	@bsc -e mkTest mkTest.v
	@./a.out

.PHONY: testmul16
testmul16:
	@bsc pbox_types.bsv
	@bsc dadda_8.bsv
	@bsc multiplier.bsv
	@bsc Zpsfoperand.bsv
	@echo "Compiled Successfully, Running Testbench"
	@bsc -verilog Zpsfoperand_TB.bsv
	@bsc -e mkTest mkTest.v
	@./a.out

.PHONY: clean
clean:
	@rm -r *.bo *.v *.out
	@echo "Cleaned"
