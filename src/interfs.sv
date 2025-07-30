`include "defines.sv"

interface interfs(input bit clk);
	//inputs
	logic rst,ce,cin,mode;
	logic [1:0] inp_valid;
	logic [3:0] cmd;
	logic [`WIDTH-1:0] opa, opb;

	//outputs
	logic err, oflow, cout, g,l,e;
	logic [`WIDTH:0] res;

	//Clocking blocks
	clocking driver_cb @(posedge clk);
		default input #0 output #0;
		//Output
		inout rst, ce, inp_valid, mode, cmd, opa, opb, cin;
	endclocking

	clocking monitor_cb @(posedge clk);
		default input #0 output #0;
		input rst;
		input ce,inp_valid, mode, cmd, opa, opb, cin;
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


	property reset_assert;
		@(posedge clk) rst |=> res !=0;
	endproperty

	assert property (reset_assert)
		$display("Result is not cleared when reset asserted");
	else
		$display("Result cleared when reset asserted");
	
	property invalid_inputs;
		@(posedge clk) (inp_valid == 0) |-> err;
	endproperty

	assert property (invalid_inputs)
		$display("Error flag is high when inp_valid is 0");
	else
		$display("Error flag is low when inp_valid is 0");
	//--------------------
	property latch_outputs;
		@(posedge clk) ((ce == 0) |=> res == $past(res));
	endproperty

	assert property (latch_outputs)
		$display("\n\nWhen CE=0 past value is retained");
	else
		$display("When CE=0 past value is not retained");
endinterface	
