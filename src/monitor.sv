`include "defines.sv"

class monitor;
	transaction mon_trans;
	mailbox #(transaction) mon2scb_mbx;
	virtual interfs.MON vif;

	covergroup monitor_cover;
		error: coverpoint vif.monitor_cb.err;
		over_flow: coverpoint vif.monitor_cb.oflow;
		carry_out: coverpoint vif.monitor_cb.cout;
		greater: coverpoint vif.monitor_cb.g;
		lesser: coverpoint vif.monitor_cb.l;
		equal: coverpoint vif.monitor_cb.e;
	endgroup
	
	
	function new( virtual interfs.MON vif, mailbox #(transaction) mon2scb_mbx);
	
		this.vif = vif;
		this.mon2scb_mbx = mon2scb_mbx;
		monitor_cover = new();
	endfunction

	task run();
		repeat(2)@(vif.monitor_cb);
		for(int i=0;i<`trans_number;i=i+1)
		begin
			mon_trans = new();
			repeat(3) @(vif.monitor_cb);
			begin
			if(((vif.monitor_cb.cmd ==9) || (vif.monitor_cb.cmd ==10)) && (vif.monitor_cb.mode ==1) && (vif.monitor_cb.inp_valid == 3))
				repeat(1) @(vif.monitor_cb);
				mon_trans.rst = vif.monitor_cb.rst;
				mon_trans.ce = vif.monitor_cb.ce;
				mon_trans.inp_valid = vif.monitor_cb.inp_valid;
				mon_trans.mode = vif.monitor_cb.mode;
				mon_trans.cmd = vif.monitor_cb.cmd;
				mon_trans.opa = vif.monitor_cb.opa;
				mon_trans.opb = vif.monitor_cb.opb;
				mon_trans.cin = vif.monitor_cb.cin;
				mon_trans.res = vif.monitor_cb.res;
				mon_trans.err = vif.monitor_cb.err;
				mon_trans.oflow = vif.monitor_cb.oflow;
				mon_trans.cout = vif.monitor_cb.cout;
				mon_trans.g = vif.monitor_cb.g;
				mon_trans.l = vif.monitor_cb.l;
				mon_trans.e = vif.monitor_cb.e;
				mon2scb_mbx.put(mon_trans);
			end
			$display("----------------------------------------------------Monitor @time = %0t----------------------------------------------------\n res= %0d | err = %0d | oflow = %0d | cout = %0d | g = %0d | l = %0d | e = %0d",$time,mon_trans.res,mon_trans.err, mon_trans.oflow, mon_trans.cout, mon_trans.g, mon_trans.l, mon_trans.e);

			monitor_cover.sample();
			$display("Output Functional Coverage: %0d",monitor_cover.get_coverage());
		end	
	endtask
endclass


