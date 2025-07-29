`include "defines.sv"
class transaction;		// Base class can be used for coverage as well
	//inputs
	
	rand bit ce;
	rand bit cin,mode;
	rand bit [1:0] inp_valid;
	rand bit [3:0] cmd;
	rand bit [`WIDTH-1:0] opa, opb;
	//outputs
	bit err, oflow, cout, g,l,e;
	bit [`WIDTH:0] res;

	constraint solve_mode_before_cmd {solve mode before cmd;}
	constraint solve_inp_valid_before_cmd {solve inp_valid before cmd;}
	constraint solve_ce_before_mode{solve ce before mode;}

	constraint mode_rand {mode inside {0,1};}
	constraint inp_valid_rand {inp_valid inside {[0:3]};}
	/*	Use after 16 clock cycle fixed
	constraint cmd_in_range {if(mode)
															cmd < 11;
													 else
														 	cmd < 14;
													}
	*/
	constraint cmd_in_range1 {if((mode == 1) && (inp_valid == 1))
															cmd inside {[4:5]};
														else
															{
																if((mode == 1) && (inp_valid == 2))
																	cmd inside {[6:7]};
																else
																	cmd inside {[0:13]};
															}
													 }

	constraint cmd_in_range0 {if((mode == 0) && (inp_valid == 1))
															cmd inside {6,8,9};
														else
														{
															if((mode == 0) &&(inp_valid == 2))
																cmd inside {7,10,11};
															else
																cmd inside {[0:13]};
														}
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
	function void disp();
		$display("time=%0t | ce=%b | mode=%0d | cmd=%0d | inp_valid=%b | opa=%0d | opb=%0d | cin=%b | res=%0d | err=%b | oflow=%b | cout=%b | g=%b | l=%b | e=%b ",$time,ce,mode,cmd,inp_valid,opa,opb,cin,res,err,oflow,cout,g,l,e);	
	endfunction
endclass

class transaction1 extends transaction;	// Without any wait

	constraint inp_valid_rand {inp_valid == 3;}
	constraint ce_make_1 {ce ==1;}
	constraint cmd_in_range1 {if((mode == 1) && (inp_valid == 1))
															cmd inside {[4:5]};
														else
															{
																if((mode == 1) && (inp_valid == 2))
																	cmd inside {[6:7]};
																else
																	cmd inside {[0:10]};
															}
													 }

	constraint cmd_in_range0 {if((mode == 0) && (inp_valid == 1))
															cmd inside {6,8,9};
														else
														{
															if((mode == 0) && (inp_valid == 2))
																cmd inside {7,10,11};
															else
																cmd inside {[0:13]};
														}
													 }

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
