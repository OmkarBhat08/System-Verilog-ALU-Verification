`include "defines.sv"
class transaction;
	//inputs
	bit clk,rst;
	rand bit ce,cin,mode;
	rand bit [1:0] inp_valid;
	rand bit [3:0] cmd;
	rand bit [`WIDTH-1:0] opa, opb;
	//outputs
	bit err, oflow, cout, g,l,e;
	bit [`WIDTH:0] res;

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
