`include "pkg.sv"
`include "interfs.sv"
`include "alu.v"
module top();
	import pkg ::*;
	bit clk, rst;

	always
		#5 clk = ~clk;
	
	initial
	begin
		clk = 1'b0;

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
		$finish;
	end
endmodule
