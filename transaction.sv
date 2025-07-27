`include "defines.sv"
class transaction;
	//inputs
	bit rst = 1'b0;
	bit ce = 1'b1;
	rand bit cin,mode;
	rand bit [1:0] inp_valid;
	rand bit [3:0] cmd;
	rand bit [`WIDTH-1:0] opa, opb;
	//outputs
	bit err, oflow, cout, g,l,e;
	bit [`WIDTH:0] res;
	//constraint solve_mode_before_cmd {solve mode before cmd;}
	constraint cmd_in_range {if(mode)
															cmd < 11;
													 else
														 	cmd < 14;
													}

	//Blueprint method
	virtual function transaction copy();
		copy = new();
		copy.clk = this.clk;
		copy.rst = this.rst;
		copy.ce = this.ce;
		copy.cin = this.cin;
		copy.mode = this.mode;
		copy.inp_valid = this.inp_valid;
		copy.cmd = this.cmd;
		copy.opa = this.opa;
		copy.opb = this.opb;
		return copy;
	endfunction
endclass

class transaction1 extends transaction;	// Addition
	super.cin = 0;
	super.mode = 1;
	super.cmd = 0;
	super.inp_valid = 2'b11;

	virtual function transaction copy();
		transaction1 copy1;
		copy1 = new();
		copy.clk = this.clk;
		copy.rst = this.rst;
		copy.ce = this.ce;
		copy.cin = this.cin;
		copy.mode = this.mode;
		copy.inp_valid = this.inp_valid;
		copy.cmd = this.cmd;
		copy.opa = this.opa;
		copy.opb = this.opb;
		return copy;

	endfunction
endclass
