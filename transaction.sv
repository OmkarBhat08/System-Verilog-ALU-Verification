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
//	constraint mode_rand {mode == 1;}
	constraint inp_valid_rand {inp_valid inside {[0:3]};}
	//constraint inp_valid_rand {inp_valid == 3;}
	constraint cmd_in_range {if(mode)
															cmd < 11;
													 else
														 	cmd < 14;
													}
	//constraint cmd_in_range {cmd == 0;}
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
	
	function void disp();
		$display("time=%0t | ce=%b | mode=%0d | cmd=%0d | inp_valid=%b | opa=%0d | opb=%0d | cin=%b | res=%0d | err=%b | oflow=%b | cout=%b | g=%b | l=%b | e=%b ",$time,ce,mode,cmd,inp_valid,opa,opb,cin,res,err,oflow,cout,g,l,e);	
	endfunction
endclass

class transaction1 extends transaction;	// Both operand operations and inp_valid=2'b11
	constraint inp_valid_rand {inp_valid == 3;}
	constraint cmd_in_range {if(mode)
														 cmd inside {[0:3],[9:10]};
													 else
														 cmd inside {[0:5],[10:12]};}
	virtual function transaction copy();
		//restrict the modes for both inputs
		transaction1 copy1;
		copy1 = new();
		copy1.ce = this.ce;
		copy1.cin = this.cin;
		copy1.mode = this.mode;
		copy1.inp_valid = this.inp_valid;
		copy1.cmd = this.cmd;
		copy1.opa = this.opa;
		copy1.opb = this.opb;
		return copy1;
	endfunction
endclass
