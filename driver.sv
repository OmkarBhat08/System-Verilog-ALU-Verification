`include "defines.sv"
class driver;

	transaction drv_trans;

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
					vif.driver_cb.input_valid <= 2'b0;	
					vif.driver_cb.mode <= 1'b0;	
					vif.driver_cb.cmd <= 4'b0;	
					vif.driver_cb.opa <= {`WIDTH-1{1'b0}};	
					vif.driver_cb.opb <= {`WIDTH-1{1'b0}};	
					vif.driver_cb.cin <= 1'b0;	
					repeat(2) @(vif.driver_cb);
					$display("--------------------------------Driver during reset----------------------------------------\n
			inp_valid = %0d | mode = %0d | cmd = %0d | opa = %0d | opb = %0d | cin = %0d",input_valid, mode,cmd,opa,opb,cin);
				end
			end
			else
			begin
				repeat(1) @(vif.driver_cb);
				begin
					vif.driver_cb.input_valid <= drv_trans.input_valid;	
					vif.driver_cb.mode <= drv_trans.mode;	
					vif.driver_cb.cmd <= drv_trans.cmd;	
					vif.driver_cb.opa <= drv_trans.opa;	
					vif.driver_cb.opb <= drv_trans.opb;	
					vif.driver_cb.cin <= drv_trans.cin;	
					repeat(2) @(vif.driver_cb);
					$display("--------------------------------Driver-----------------------------------------------------\n
			inp_valid = %0d | mode = %0d | cmd = %0d | opa = %0d | opb = %0d | cin = %0d",input_valid, mode,cmd,opa,opb,cin);
					drv2ref_mbx(drv_trans);
					//Sample the covergroup  drv_cg.sample();
					//$display("Input Functional Coverage = %0d", drv_cg.get_coverage());
				end
			end
		end
	endtask
endclass
