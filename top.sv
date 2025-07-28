`include "test.sv"
`include "interfs.sv"
`include "alu.v"
module top();
	bit clk, rst;
	
	initial
	begin
		forever #10 clk =~clk;
	end

	initial
	begin
		@(posedge clk);
			rst = 1'b1;
		
		@(posedge clk);
			rst = 1'b0;
	end

	interfs intf(clk,rst);

	alu DUT (
		.CLK(clk),
		.RST(rst),
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

	//test tb = new(intf.DRV, intf.MON, intf.REF);
	test1 tb1 = new(intf.DRV, intf.MON, intf.REF);
	
	initial
	begin
		//tb.run();
		tb1.run();
		$finish();
	end
endmodule
