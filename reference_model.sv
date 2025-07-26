`include "defines.sv"
`include "transaction.sv"

class reference_model;
	transaction ref_trans;
	transaction ref2scb_trans;
	localparam POW_2_N = $clog2(`WIDTH);
	logic [POW_2_N - 1:0] SH_AMT;

	mailbox #(transaction) ref2scb_mbx;
	mailbox #(transaction) drv2ref_mbx;

	virtual interfs.REF vif;

	function new(mailbox #(transaction) ref2scb_mbx,
							 mailbox #(transaction) drv2ref_mbx,
							 virtual interfs.REF vif);
		this.ref2scb_mbx = ref2scb_mbx;
		this.drv2ref_mbx = drv2ref_mbx;
		this.vif = vif;
	endfunction
	
	function bit counter_for_b();
		int i = 0;
		for(i=0;i<16;i++)
		begin
			if (ref_trans.inp_valid == 2'b10)
				break;
			repeat(1) @(vif.ref_model_cb);
		end
		if(i == 15)
			counter_for_b = 1;
		else
			counter_for_b = 1'bz;
	endfunction

	function bit counter_for_a();
		int i = 0;
		for(i=0;i<16;i++)
		begin
			if (ref_trans.inp_valid == 2'b01)
				break;
			else
				repeat(1) @(vif.ref_model_cb);
		end
		if(i == 15)
			counter_for_a = 1;
		else
			counter_for_a = 1'bz;
	endfunction

	task run();
		transaction temp_trans;
		logic temp;
		for(int i=0; i< `trans_number;i=i+1)
		begin
			ref_trans = new();
			ref2scb_trans = new();
			drv2ref_mbx.get(ref_trans);
				
			repeat(1) @(vif.ref_model_cb)
			begin
				if(ref_trans.rst)
				begin
					ref2scb_trans.res = {`WIDTH{1'bz}};
					ref2scb_trans.oflow = 1'bz;
					ref2scb_trans.cout = 1'bz;
					ref2scb_trans.g = 1'bz;
					ref2scb_trans.l = 1'bz;
					ref2scb_trans.e = 1'bz;
					ref2scb_trans.err = 1'bz;
				end
				else
				begin
					if(ref_trans.ce)
					begin
						if(ref2scb_trans.mode)		// Arithmetic operations
						begin
							ref2scb_trans.res = {`WIDTH{1'b0}};
							ref2scb_trans.oflow = 1'b0;
							ref2scb_trans.cout = 1'b0;
							ref2scb_trans.g = 1'b0;
							ref2scb_trans.l = 1'b0;
							ref2scb_trans.e = 1'b0;
							ref2scb_trans.err = 1'b0;
							if((ref2scb_trans.cmd < 4) || (ref2scb_trans.cmd > 7 && ref2scb_trans.cmd <11))	// All 2 operand operations
							begin
								if(ref_trans.inp_valid == 2'b00)
									ref2scb_trans.err = 1'b1;
								else if(ref_trans.inp_valid != 2'b11) 
								begin
									for(int i = 0; i < 16; i++ ) 
									begin
										repeat(1) @ (vif.ref_cb);
										ref2scb_trans.inp_valid = vif.drv_cb.inp_valid;
										if(ref2scb_trans.inp_valid == 2'b11)
											break;
									end	
									if(i==15)
										ref2scb_trans.err = 1'b1;
									else
									begin
										case(ref_trans.cmd)
											4'd0:	//ADD
											begin
												ref2scb_trans.res = ref_trans.opa + ref_trans.opb;
												ref2scb_trans.cout = ref2scb_trans.res[`WIDTH];
												ref2scb_trans.oflow = ref2scb_trans.res[`WIDTH];
											end
											4'd1:	//SUB
											begin
												ref2scb_trans.res = ref_trans.opa - ref_trans.opb;
												ref2scb_trans.cout = (ref_trans.opa < ref_trans.opb);
												ref2scb_trans.oflow = ref2scb_trans.res[`WIDTH];
											end
											4'd2:	//ADD_CIN
											begin
												ref2scb_trans.res = ref_trans.opa + ref_trans.opb + ref_trans.cin;
												ref2scb_trans.cout = ref2scb_trans.res[`WIDTH];
												ref2scb_trans.oflow = ref2scb_trans.res[`WIDTH];
											end
											4'd3:	// SUB_CIN
											begin
												ref2scb_trans.res = (ref_trans.opa - ref_trans.opb) - ref_trans.cin;
												ref2scb_trans.oflow = ((ref_trans.opa < ref_trans.opb) || ((ref_trans.opa == ref_trans.opa) && (ref_trans.cin != 0)));
												ref2scb_trans.cout = ref2scb_trans.res[`WIDTH];
											end
											4'd8:	// CMP
											begin
												if(ref_trans.opa == ref_trans.opb)
                	    		{ref2scb_trans.g,ref2scb_trans.l,ref2scb_trans.e} = 3'bzz1;
                  			else if (ref_trans.opa > ref_trans.opb)
                    			{ref2scb_trans.g,ref2scb_trans.l,ref2scb_trans.e} = 3'b1zz;
                    		else
        	            		{ref2scb_trans.g,ref2scb_trans.l,ref2scb_trans.e} = 3'bz1z;
											end	
											4'd9:	//Increment and multiply
												ref2scb_trans.res = (ref_trans.opa + 1) * (ref_trans.opb+1);
											4'd10:	//Shift and multiply
												ref2scb_trans.res = (ref_trans.opa << 1) * ref_trans.opb;
										endcase
									end
								end
							end
							if((ref2scb_trans.cmd == 4) || (ref2scb_trans.cmd == 5))	// OPA operations
							begin
								if((ref_trans.inp_valid == 2'b00) || (ref_trans.inp_valid == 2'b10)
										ref2scb_trans.err = 1;
								else
								begin
									if(ref2scb_trans.cmd == 4)		// INC_A
									begin
										ref2scb_trans.res = ref_trans.opa + 1;
										ref2scb_trans.cout = ref2scb_trans.res[`WIDTH];
										ref2scb_trans.oflow = ref2scb_trans.res[`WIDTH];
									end
									else		// DEC_A
									begin
										ref2scb_trans.res = ref_trans.opa - 1;
										ref2scb_trans.cout = ref_trans.opb==0;
										ref2scb_trans.oflow = ref2scb_trans.res[`WIDTH];
									end
								end
							end

							if((ref2scb_trans.cmd == 6) || (ref2scb_trans.cmd == 7))	// OPB operations
							begin
								if((ref_trans.inp_valid == 2'b00) || (ref_trans.inp_valid == 2'b01)
										ref2scb_trans.err = 1;
								else
								begin
									if(ref2scb_trans.cmd == 6)		// INC_B
									begin
										ref2scb_trans.res = ref_trans.opb + 1;
										ref2scb_trans.cout = ref2scb_trans.res[`WIDTH];
										ref2scb_trans.oflow = ref2scb_trans.res[`WIDTH];
									end
									else		// DEC_B
									begin
										ref2scb_trans.res = ref_trans.opb - 1;
										ref2scb_trans.cout = ref_trans.opb==0;
										ref2scb_trans.oflow = ref2scb_trans.res[`WIDTH];
									end
								end
							end
						end		// Arithmetic opeation ends
						else	//logical operations
						begin

							ref2scb_trans.res = {`WIDTH{1'b0}};
							ref2scb_trans.oflow = 1'b0;
							ref2scb_trans.cout = 1'b0;
							ref2scb_trans.g = 1'b0;
							ref2scb_trans.l = 1'b0;
							ref2scb_trans.e = 1'b0;
							ref2scb_trans.err = 1'b0;
							if((ref2scb_trans.cmd < 6) || (ref2scb_trans.cmd > 11 && ref2scb_trans.cmd < 14))	// All 2 operand operations
							begin
								if(ref_trans.inp_valid == 2'b00)
									ref2scb_trans.err = 1'b1;
								else if(ref_trans.inp_valid != 2'b11) 
								begin
									for(int i = 0; i < 16; i++ ) 
									begin
										repeat(1) @ (vif.ref_cb);
										ref2scb_trans.inp_valid = vif.drv_cb.inp_valid;
										if(ref2scb_trans.inp_valid == 2'b11)
											break;
									end	
									if(i==15)
										ref2scb_trans.err = 1'b1;
									else
									begin
										case(ref_trans.cmd)
											4'd0:	//AND
												ref2scb_trans.res = ref_trans.opa & ref_trans.opb;
											4'd1:	// NAND
												ref2scb_trans.res = ~(ref_trans.opa & ref_trans.opb);
											4'd2:	// OR
												ref2scb_trans.res = ref_trans.opa | ref_trans.opb;
											4'd3:	// NOR
												ref2scb_trans.res = ~(ref_trans.opa | ref_trans.opb);
											4'd4:	// XOR
												ref2scb_trans.res = ref_trans.opa ^ ref_trans.opb;
											4'd5:	// XNOR
												ref2scb_trans.res = ~(ref_trans.opa ^ ref_trans.opb);
											4'd6:	// NOT_A
												ref2scb_trans.res = ~(ref_trans.opa);
											4'd7:	// NOT_B
												ref2scb_trans.res = ~(ref_trans.opb);
											4'd8:	// SHR1_A
												ref2scb_trans.res = ref_trans.opa >> 1;
											4'd9:	// SHL1_A
												ref2scb_trans.res = ref_trans.opa << 1;
											4'd10:	// SHR1_B
												ref2scb_trans.res = ref_trans.opb >> 1;
								4'd11:	// SHL1_B
										ref2scb_trans.res = ref_trans.opb << 1;
								4'd12:	// ROL_A_B
									begin
										SH_AMT = ref_trans.opb;
										ref2scb_trans.res = 16'h00FF & ({1'b0,(ref_trans.opa << SH_AMT | ref_trans.opa >> (`WIDTH - SH_AMT))});
										ref2scb_trans.err = |ref_trans.opb[`WIDTH - 1 : POW_2_N +1];
									end
								4'd13:	// ROR_A_B
									begin
										SH_AMT = ref_trans.opb;
										ref2scb_trans.res = 16'h00FF & ({1'b0,ref_trans.opa << (`WIDTH- SH_AMT) | ref_trans.opa >> SH_AMT});
										ref2scb_trans.err = |ref_trans.opb[`WIDTH - 1 : POW_2_N +1];
									end
								default:
									begin
										ref2scb_trans.res = {`WIDTH{1'bz}};
										ref2scb_trans.oflow = 1'bz;
										ref2scb_trans.cout = 1'bz;
										ref2scb_trans.g = 1'bz;
										ref2scb_trans.l = 1'bz;
										ref2scb_trans.e = 1'bz;
										ref2scb_trans.err = 1'bz;
									end
							endcase
						end
					end
					else
					begin	// Latch on to previous values
						ref2scb_trans.res = temp_trans.res;
						ref2scb_trans.oflow = temp_trans.oflow;
						ref2scb_trans.cout = temp_trans.cout;
						ref2scb_trans.g = temp_trans.g;
						ref2scb_trans.l = temp_trans.l;
						ref2scb_trans.e = temp_trans.e;
						ref2scb_trans.err = temp_trans.err;
					end	
				end
				temp_trans = new ref2scb_trans; 
			end
		end
	endtask
endclass
