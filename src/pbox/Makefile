.PHONY: multiplier
multiplier: 
	@bsc multiplier.bsv

.PHONY: testmultiplier
testmultiplier: 
	@make multiplier.bsv
	@bsc -verilog testbench.bsv
	@bsc -e mkTest mkTest.v
	@./a.out

.PHONY: clean
clean:
	@rm -r *.bo *.v *.out
	@echo "Cleaned"
