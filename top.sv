`include "pkg.sv"
/*
	`include "transaction.sv"
	`include "generator.sv"
	`include "driver.sv"
	`include "monitor.sv"
	`include "reference_model.sv"
	`include "scoreboard.sv"
	`include "environment.sv"
	`include "test.sv"
*/
`include "interfs.sv"
`include "alu.v"
module top();
	import pkg ::*;
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

	test tb = new(intf.DRV, intf.MON, intf.REF);
	
	initial
	begin
		tb.run();
		$finish();
	end
endmodule
