`include "defines.sv"
class reference_model;
	int i;
	logic temp;
	transaction ref_trans;
	transaction ref2scb_trans;
	localparam POW_2_N = $clog2(`WIDTH);
	logic [POW_2_N - 1:0] SH_AMT;

	mailbox #(transaction) ref2scb_mbx;
	mailbox #(transaction) drv2ref_mbx;

	virtual interfs.REF vif;

	function new(mailbox #(transaction) drv2ref_mbx,
							 mailbox #(transaction) ref2scb_mbx,
							 virtual interfs.REF vif);
		this.ref2scb_mbx = ref2scb_mbx;
		this.drv2ref_mbx = drv2ref_mbx;
		this.vif = vif;
	endfunction

	task run();
		transaction temp_trans;
		transaction temp1_trans;
	 	temp_trans	= new();
		//repeat(3) @(vif.ref_model_cb);
		for(int i=0; i< `trans_number;i=i+1)
		begin
			ref_trans = new();
			ref2scb_trans = new();

			drv2ref_mbx.get(ref_trans);
			begin
				if(vif.ref_model_cb.rst)
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
						if(ref_trans.mode)		// Arithmetic operations
						begin
							ref2scb_trans.res = {`WIDTH{1'b0}};
							ref2scb_trans.oflow = 1'b0;
							ref2scb_trans.cout = 1'b0;
							ref2scb_trans.g = 1'b0;
							ref2scb_trans.l = 1'b0;
							ref2scb_trans.e = 1'b0;
							ref2scb_trans.err = 1'b0;
							if((ref_trans.cmd < 4) || (ref_trans.cmd > 7 && ref_trans.cmd <11))	// All 2 operand operations
							begin
								if(ref_trans.inp_valid == 2'b00)
									ref2scb_trans.err = 1'b1;
								else if(ref_trans.inp_valid == 2'b11)
								begin
										case(ref_trans.cmd)
											4'd0:	//ADD
											begin
												ref2scb_trans.res = ref_trans.opa + ref_trans.opb;
												ref2scb_trans.cout = ref2scb_trans.res[`WIDTH];
											end
											4'd1:	//SUB
											begin
												ref2scb_trans.res = ref_trans.opa - ref_trans.opb;
												ref2scb_trans.oflow = (ref_trans.opa < ref_trans.opb);
											end
											4'd2:	//ADD_CIN
											begin
												ref2scb_trans.res = ref_trans.opa + ref_trans.opb + ref_trans.cin;
												ref2scb_trans.cout = ref2scb_trans.res[`WIDTH];
											end
											4'd3:	// SUB_CIN
											begin
												ref2scb_trans.res = (ref_trans.opa - ref_trans.opb) - ref_trans.cin;
												ref2scb_trans.oflow = ref_trans.opa < ref_trans.opb || ( ref_trans.opa == ref_trans.opb && ref_trans.cin);
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
								else 
								begin
									for(int i = 0; i < 16; i++ ) 
									begin
										repeat(1) @ (vif.ref_model_cb);
										if(ref_trans.inp_valid == 2'b11)
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
											end
											4'd1:	//SUB
											begin
												ref2scb_trans.res = ref_trans.opa - ref_trans.opb;
												ref2scb_trans.oflow = (ref_trans.opa < ref_trans.opb);
											end
											4'd2:	//ADD_CIN
											begin
												ref2scb_trans.res = ref_trans.opa + ref_trans.opb + ref_trans.cin;
												ref2scb_trans.cout = ref2scb_trans.res[`WIDTH];
											end
											4'd3:	// SUB_CIN
											begin
												ref2scb_trans.res = (ref_trans.opa - ref_trans.opb) - ref_trans.cin;
												ref2scb_trans.oflow = ref_trans.opa < ref_trans.opb || ( ref_trans.opa == ref_trans.opb && ref_trans.cin);
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
											begin
												repeat(1) @ (vif.ref_model_cb);
												ref2scb_trans.res = (ref_trans.opa + 1) * (ref_trans.opb+1);
											end
											4'd10:	//Shift and multiply
											begin
												repeat(1) @ (vif.ref_model_cb);
												ref2scb_trans.res = (ref_trans.opa << 1) * ref_trans.opb;
											end
										endcase
									end
								end
							end
							if((ref_trans.cmd == 4) || (ref_trans.cmd == 5))	// OPA operations
							begin
								if((ref_trans.inp_valid == 2'b00) || (ref_trans.inp_valid == 2'b10))
										ref2scb_trans.err = 1;
								else
								begin
									if(ref_trans.cmd == 4)		// INC_A
									begin
										ref2scb_trans.res = ref_trans.opa + 1;
										ref2scb_trans.cout = ref2scb_trans.res[`WIDTH];
									end
									else		// DEC_A
									begin
										ref2scb_trans.res = ref_trans.opa - 1;
										ref2scb_trans.oflow = ref_trans.opb==0;
									end
								end
							end

							if((ref_trans.cmd == 6) || (ref_trans.cmd == 7))	// OPB operations
							begin
								if((ref_trans.inp_valid == 2'b00) || (ref_trans.inp_valid == 2'b01))
										ref2scb_trans.err = 1;
								else
								begin
									if(ref_trans.cmd == 6)		// INC_B
									begin
										ref2scb_trans.res = ref_trans.opb + 1;
										ref2scb_trans.cout = ref2scb_trans.res[`WIDTH];
									end
									else		// DEC_B
									begin
										ref2scb_trans.res = ref_trans.opb - 1;
										ref2scb_trans.oflow = ref_trans.opb==0;
									end
								end
							end
							repeat(1)@(vif.ref_model_cb);
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
							if((ref_trans.cmd < 6) || (ref_trans.cmd > 11 && ref_trans.cmd < 14))	// All 2 operand operations
							begin
								if(ref_trans.inp_valid == 2'b00)
									ref2scb_trans.err = 1'b1;
								else if(ref_trans.inp_valid == 2'b11) 
								begin
										case(ref_trans.cmd)
											4'd0:	//AND
												ref2scb_trans.res = {1'b0,ref_trans.opa & ref_trans.opb};
											4'd1:	// NAND
												ref2scb_trans.res = {1'b0,~(ref_trans.opa & ref_trans.opb)};
											4'd2:	// OR
												ref2scb_trans.res = {1'b0,ref_trans.opa | ref_trans.opb};
											4'd3:	// NOR
												ref2scb_trans.res = {1'b0,~(ref_trans.opa | ref_trans.opb)};
											4'd4:	// XOR
												ref2scb_trans.res = {1'b0,ref_trans.opa ^ ref_trans.opb};
											4'd5:	// XNOR
												ref2scb_trans.res = {1'b0,~(ref_trans.opa ^ ref_trans.opb)};
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
										endcase
								end
								else
								begin
									for(int i = 0; i < 16; i++ ) 
									begin
										repeat(1) @ (vif.ref_model_cb);
										if(ref_trans.inp_valid == 2'b11)
											break;
									end	
									if(i==15)
										ref2scb_trans.err = 1'b1;
									else
									begin
										case(ref_trans.cmd)
											4'd0:	//AND
												ref2scb_trans.res = {1'b0,ref_trans.opa & ref_trans.opb};
											4'd1:	// NAND
												ref2scb_trans.res = {1'b0,~(ref_trans.opa & ref_trans.opb)};
											4'd2:	// OR
												ref2scb_trans.res = {1'b0,ref_trans.opa | ref_trans.opb};
											4'd3:	// NOR
												ref2scb_trans.res = {1'b0,~(ref_trans.opa | ref_trans.opb)};
											4'd4:	// XOR
												ref2scb_trans.res = {1'b0,ref_trans.opa ^ ref_trans.opb};
											4'd5:	// XNOR
												ref2scb_trans.res = {1'b0,~(ref_trans.opa ^ ref_trans.opb)};
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
										endcase
									end
								end
							end
							if((ref_trans.cmd == 6) || (ref_trans.cmd == 8) || (ref_trans.cmd == 9))	// OPA operations
							begin
								if((ref_trans.inp_valid == 2'b00) || (ref_trans.inp_valid == 2'b10))
										ref2scb_trans.err = 1;
								else
								begin
									if(ref_trans.cmd == 6)		// NOT_A
										ref2scb_trans.res = {1'b0,~(ref_trans.opa)};
									else if(ref_trans.cmd == 8)		// SHR1_A
									begin
										ref2scb_trans.res = {1'b0,ref_trans.opa >> 1};
									end
									else		// SHL1_A
									begin
										ref2scb_trans.res = {1'b0,ref_trans.opa << 1};
									end
								end
							end

							if((ref_trans.cmd == 7) || (ref_trans.cmd == 10) || (ref_trans.cmd == 11))	// OPB  operations
							begin
								if((ref_trans.inp_valid == 2'b00) || (ref_trans.inp_valid == 2'b01))
										ref2scb_trans.err = 1;
								else
								begin
									if(ref_trans.cmd == 7)		// NOT_B
										ref2scb_trans.res = {1'b0,~(ref_trans.opb)};
									else if(ref_trans.cmd == 10)		// SHR1_B
										ref2scb_trans.res = {1'b0,ref_trans.opb >> 1};
									else		// SHL1_B
										ref2scb_trans.res = {1'b0,ref_trans.opb << 1};
								end
							end
							repeat(1)@(vif.ref_model_cb);
						end		// logical opeation ends
					end
					else
					begin	// Latch on to previous values
						$display("In CE=0");
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
			
			if(((ref_trans.cmd ==9) || (ref_trans.cmd ==10)) && (ref_trans.mode ==1) && (ref_trans.inp_valid == 3))
			begin
				temp1_trans = new ref2scb_trans; 
				repeat(1)@(vif.ref_model_cb);
				ref2scb_mbx.put(temp1_trans);
			end
			else
				ref2scb_mbx.put(ref2scb_trans);
			
				$display("----------------------------------------------Reference model @time = %0t-----------------------------------------------",$time);
				if(ref_trans.mode)
				begin
				$display("@time=%0t | inp_valid=%b | mode=%b | cmd=%0d | ce=%b | opa=%0d | opb=%0d | cin=%b",$time, ref_trans.inp_valid, ref_trans.mode,ref_trans.cmd,ref_trans.ce,ref_trans.opa,ref_trans.opb,ref_trans.cin);
				$display("@time=%0t | err=%b | res=%0d | oflow=%b | cout=%b | g=%b | l=%b | e=%b",$time,ref2scb_trans.err,ref2scb_trans.res,ref2scb_trans.oflow,ref2scb_trans.cout,ref2scb_trans.g,ref2scb_trans.l,ref2scb_trans.e);
				end
			else
				begin
				$display("@time=%0t | inp_valid=%b | mode=%b | cmd=%0d | ce=%b | opa=%b | opb=%b | cin=%b",$time, ref_trans.inp_valid, ref_trans.mode,ref_trans.cmd,ref_trans.ce,ref_trans.opa,ref_trans.opb,ref_trans.cin);
				$display("@time=%0t | err=%b | res=%b | oflow=%b | cout=%b | g=%b | l=%b | e=%b",$time,ref2scb_trans.err,ref2scb_trans.res,ref2scb_trans.oflow,ref2scb_trans.cout,ref2scb_trans.g,ref2scb_trans.l,ref2scb_trans.e);
				end
		end
	endtask
endclass
