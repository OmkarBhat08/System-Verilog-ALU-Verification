`include "defines.sv"
class transaction;
	//inputs
	
	bit ce = 1'b1;
	rand bit cin,mode;
	rand bit [1:0] inp_valid;
	rand bit [3:0] cmd;
	rand bit [`WIDTH-1:0] opa, opb;
	//outputs
	bit err, oflow, cout, g,l,e;
	bit [`WIDTH:0] res;
	constraint solve_mode_before_cmd {solve mode before cmd;}
	constraint mode_rand {mode inside {0,1};}
	constraint inp_valid_rand {inp_valid inside {[0:3]};}
	constraint cmd_in_range {if(mode)
															cmd < 11;
													 else
														 	cmd < 14;
													}
	constraint cin_rand{cin inside {0,1};}

	//Blueprint method
	virtual function transaction copy();
		copy = new();
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

	constraint mode_rand {mode == 0;}
	constraint inp_valid_rand {inp_valid == 3;}
	constraint cmd_in_range { cmd == 0;}
	constraint cin_rand{cin ==0;}
	virtual function transaction copy();
		transaction1 copy1;
		copy1 = new();
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
