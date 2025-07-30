`include "defines.sv"
class driver;
	int i;
	transaction drv_trans;
	transaction temp_trans;

	mailbox #(transaction) gen2drv_mbx;
	mailbox #(transaction) drv2ref_mbx;

	virtual interfs.DRV vif;

	covergroup driver_cover;
		reset: coverpoint vif.driver_cb.rst;
		clock_en: coverpoint vif.driver_cb.ce;
		inp_valid: coverpoint vif.driver_cb.inp_valid;
		arithmetic: coverpoint vif.driver_cb.cmd iff(vif.driver_cb.mode ==1)
		{
			bins add = {0};
		 	bins sub = {1};
			bins add_cin = {2};
			bins sub_cin = {3};
			bins inc_a = {4};
			bins dec_a = {5};
			bins inc_b = {6};
			bins dec_b = {7};
			bins cmp = {8};
			bins inc_mul = {9};
			bins sh_mul = {10};
		}
		logical: coverpoint vif.driver_cb.cmd iff(vif.driver_cb.mode ==0)
		{
			bins and_cov = {0};
		 	bins nand_cov = {1};
			bins or_cov = {2};
			bins nor_cov = {3};
			bins xor_cov = {4};
			bins xnor_cov = {5};
			bins not_a = {6};
			bins not_b = {7};
			bins shr1_a = {8};
			bins shl1_a = {9};
			bins shr1_b = {10};
			bins shl1_b = {11};
			bins rol_a_b = {12};
			bins ror_a_b = {13};
		}
		arithmeticXinp_valid: cross arithmetic,inp_valid;
		logicalXinp_valid: cross logical,inp_valid;
	endgroup
	//Mention input covergroups
	
	function new(mailbox #(transaction) gen2drv_mbx,
							 mailbox #(transaction) drv2ref_mbx,
							 virtual interfs.DRV vif );
		this.gen2drv_mbx = gen2drv_mbx;
		this.drv2ref_mbx = drv2ref_mbx;
		this.vif = vif;

		driver_cover = new();
	endfunction

	task run();
		repeat(2) @(vif.driver_cb);
		for(i=0;i<`trans_number;i++)
		begin
			drv_trans = new();
			gen2drv_mbx.get(drv_trans);

			if(drv_trans.rst)
			begin
				repeat(1) @(vif.driver_cb);
				begin
					vif.driver_cb.rst <= drv_trans.rst;	
					vif.driver_cb.ce <= drv_trans.ce;	
					vif.driver_cb.inp_valid <= drv_trans.inp_valid;	
					vif.driver_cb.mode <= drv_trans.mode;	
					vif.driver_cb.cmd <= drv_trans.cmd;	
					vif.driver_cb.opa <= drv_trans.opa;	
					vif.driver_cb.opb <= drv_trans.opb;	
					vif.driver_cb.cin <= drv_trans.cin;	
					$display("--------------------------------Driver during reset @ time = %0t---------------------------------\nrst = %b |inp_valid = %b | mode = %b | cmd = %0d | opa = %0d | opb = %0d | cin = %0d",$time,vif.driver_cb.rst,vif.driver_cb.inp_valid, vif.driver_cb.mode,vif.driver_cb.cmd,vif.driver_cb.opa,vif.driver_cb.opb,vif.driver_cb.cin);
					drv2ref_mbx.put(drv_trans);
				end
			end
			else
			begin
				repeat(1) @(vif.driver_cb);
				begin
					vif.driver_cb.rst <= drv_trans.rst;	
					vif.driver_cb.inp_valid <= drv_trans.inp_valid;	
					vif.driver_cb.mode <= drv_trans.mode;	
					vif.driver_cb.cmd <= drv_trans.cmd;	
					vif.driver_cb.opa <= drv_trans.opa;	
					vif.driver_cb.opb <= drv_trans.opb;	
					vif.driver_cb.cin <= drv_trans.cin;	
					vif.driver_cb.ce <= drv_trans.ce;	
					repeat(1) @(vif.driver_cb);
					$display("----------------------------------------------------Driver @ time = %0t----------------------------------------------------\nrst = %b | ce= %0d | inp_valid = %b | mode = %0d | cmd = %0d | opa = %0d | opb = %0d | cin = %0d",$time,vif.driver_cb.rst,vif.driver_cb.ce,vif.driver_cb.inp_valid, vif.driver_cb.mode,vif.driver_cb.cmd,vif.driver_cb.opa,vif.driver_cb.opb,vif.driver_cb.cin);

					drv2ref_mbx.put(drv_trans);

					driver_cover.sample();
					$display("Input Functional Coverage = %0d", driver_cover.get_coverage());
				end
			end
			if(((vif.driver_cb.cmd ==9) || (vif.driver_cb.cmd ==10)) && (vif.driver_cb.mode ==1) && (vif.driver_cb.inp_valid == 3))
				repeat(2) @(vif.driver_cb);
			else
				repeat(1) @(vif.driver_cb);
		end
	endtask
endclass
