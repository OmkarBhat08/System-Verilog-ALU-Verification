`include "defines.sv"

class monitor;
	transaction mon_trans;
	mailbox #(transaction) mon2scb_mbx;
	virtual interfs.MON vif;

	// Write covergroup
	
	function new( virtual interfs.MON vif, mailbox #(transaction) mon2scb_mbx);
	
		this.vif = vif;
		this.mon2scb_mbx = mon2scb_mbx;
		// Create an object for cover group
		// mon_cg = new();
	endfunction

	task run();
		repeat(2)@(vif.monitor_cb);
		for(int i=0;i<`trans_number;i=i+1)
		begin
			mon_trans = new();
			repeat(3) @(vif.monitor_cb);
			begin
				mon_trans.res = vif.monitor_cb.res;
				mon_trans.err = vif.monitor_cb.err;
				mon_trans.oflow = vif.monitor_cb.oflow;
				mon_trans.cout = vif.monitor_cb.cout;
				mon_trans.g = vif.monitor_cb.g;
				mon_trans.l = vif.monitor_cb.l;
				mon_trans.e = vif.monitor_cb.e;
			end
			$display("----------------------------------------------------Monitor @time = %0t----------------------------------------------------\n res= %0d | err = %0d | oflow = %0d | cout = %0d | g = %0d | l = %0d | e = %0d",$time,mon_trans.res,mon_trans.err, mon_trans.oflow, mon_trans.cout, mon_trans.g, mon_trans.l, mon_trans.e);

			mon2scb_mbx.put(mon_trans);
			// Sample covergroup
			// mon_cg.sample();
			// $display("Output Functional Coverage: %0d",mon_cg.get_coverage());
		end	
	endtask
endclass
