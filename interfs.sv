`include "defines.sv"

interface interfs(input bit clk,rst);
	//inputs
	logic ce,cin,mode;
	logic [1:0] inp_valid;
	logic [3:0] cmd;
	logic [`WIDTH-1:0] opa, opb;

	//outputs
	logic err, oflow, cout, g,l,e;
	logic [`WIDTH:0] res;

	//Clocking blocks
	clocking driver_cb @(posedge clk);
		default input #0 output #0;
		input rst;
		//Output
		inout inp_valid, mode, cmd, opa, opb, cin;
	endclocking

	clocking monitor_cb @(posedge clk);
		default input #0 output #0;
		input rst;
		input inp_valid, mode, cmd, opa, opb, cin;
		input err, res, oflow, cout, g, l, e;
	endclocking

	clocking ref_model_cb @(posedge clk);
		default input #0 output #0;
		input rst;
	endclocking

	//Modports
	modport DRV (clocking driver_cb);	
	modport MON (clocking monitor_cb);	
	modport REF (clocking ref_model_cb);	
endinterface	
