`include "defines.sv"
class driver;
	int i;
	transaction drv_trans;
	transaction temp_trans;

	mailbox #(transaction) gen2drv_mbx;
	mailbox #(transaction) drv2ref_mbx;

	virtual interfs.DRV vif;

	//Mention input covergroups
	
	function new(mailbox #(transaction) gen2drv_mbx,
							 mailbox #(transaction) drv2ref_mbx,
							 virtual interfs.DRV vif );
		this.gen2drv_mbx = gen2drv_mbx;
		this.drv2ref_mbx = drv2ref_mbx;
		this.vif = vif;
		//Create object for cover group
	endfunction

	task run();
		repeat(2) @(vif.driver_cb);
		for(i=0;i<`trans_number;i++)
		begin
			drv_trans = new();
			gen2drv_mbx.get(drv_trans);

			if(vif.driver_cb.rst)
			begin
				repeat(1) @(vif.driver_cb);
				begin
					vif.driver_cb.inp_valid <= drv_trans.inp_valid;	
					vif.driver_cb.mode <= drv_trans.mode;	
					vif.driver_cb.cmd <= drv_trans.cmd;	
					vif.driver_cb.opa <= drv_trans.opa;	
					vif.driver_cb.opb <= drv_trans.opb;	
					vif.driver_cb.cin <= drv_trans.cin;	
					vif.driver_cb.ce <= drv_trans.ce;	
					repeat(1) @(vif.driver_cb);
					$display("--------------------------------Driver during reset @ time = %0t---------------------------------\ninp_valid = %b | mode = %b | cmd = %0d | opa = %0d | opb = %0d | cin = %0d",$time,vif.driver_cb.inp_valid, vif.driver_cb.mode,vif.driver_cb.cmd,vif.driver_cb.opa,vif.driver_cb.opb,vif.driver_cb.cin);
				end
			end
			else
			begin
				repeat(1) @(vif.driver_cb);
				begin
					vif.driver_cb.inp_valid <= drv_trans.inp_valid;	
					vif.driver_cb.mode <= drv_trans.mode;	
					vif.driver_cb.cmd <= drv_trans.cmd;	
					vif.driver_cb.opa <= drv_trans.opa;	
					vif.driver_cb.opb <= drv_trans.opb;	
					vif.driver_cb.cin <= drv_trans.cin;	
					vif.driver_cb.ce <= drv_trans.ce;	
					repeat(1) @(vif.driver_cb);
					$display("----------------------------------------------------Driver @ time = %0t----------------------------------------------------\nce= %0d | inp_valid = %b | mode = %0d | cmd = %0d | opa = %0d | opb = %0d | cin = %0d",$time,vif.driver_cb.ce,vif.driver_cb.inp_valid, vif.driver_cb.mode,vif.driver_cb.cmd,vif.driver_cb.opa,vif.driver_cb.opb,vif.driver_cb.cin);

					drv2ref_mbx.put(drv_trans);
					//Sample the covergroup  drv_cg.sample();
					//$display("Input Functional Coverage = %0d", drv_cg.get_coverage());
				repeat(1) @(vif.driver_cb);
				end
			end
		end
	endtask
endclass
