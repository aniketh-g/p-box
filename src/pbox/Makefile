.PHONY: test_pbox
test_pbox:
	@bsc pbox_types.bsv
	@bsc -verilog pboxtest.bsv
	@bsc -e mkPboxTest mkPboxTest.v
	@./a.out

.PHONY: clean
clean:
	@rm -r *.bo
	@rm -r *.out