`include "test.sv"
`include "interfs.sv"
`include "alu.v"
module top();
	bit clk;
	
	initial
	begin
		forever #10 clk =~clk;
	end

	interfs intf(clk);

	alu DUT (
		.CLK(clk),
		.RST(intf.rst),
		.INP_VALID(intf.inp_valid),
		.MODE(intf.mode),
		.CMD(intf.cmd),
		.CE(intf.ce),
		.OPA(intf.opa),
		.OPB(intf.opb),
		.CIN(intf.cin),
		.ERR(intf.err),
		.RES(intf.res),
		.OFLOW(intf.oflow),
		.COUT(intf.cout),
		.G(intf.g),
		.L(intf.l),
		.E(intf.e)
	);

	test tb = new(intf.DRV, intf.MON, intf.REF);
	test1 tb1 = new(intf.DRV, intf.MON, intf.REF);
	test2 tb2 = new(intf.DRV, intf.MON, intf.REF);
	test3 tb3 = new(intf.DRV, intf.MON, intf.REF);
	test4 tb4 = new(intf.DRV, intf.MON, intf.REF);
	test5 tb5 = new(intf.DRV, intf.MON, intf.REF);
	
	initial
	begin
		tb.run();
		//tb1.run();
		//tb2.run();
		//tb3.run();
		//tb4.run();
		//tb5.run();
		$finish();
	end
endmodule
