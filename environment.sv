`include "defines.sv"
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "reference_model.sv"
`include "scoreboard.sv"

class environment;
	virtual interfs driver_vif;
	virtual interfs monitor_vif;
	virtual interfs reference_model_vif;

	mailbox #(transaction) gen2drv_mbx;
	mailbox #(transaction) drv2ref_mbx;
	mailbox #(transaction) ref2scb_mbx;
	mailbox #(transaction) mon2scb_mbx;

	generator gen;
	driver drv;
	monitor mon;
	reference_model ref_model;
	scoreboard scb;

	function new(virtual interfs driver_vif,
							 virtual interfs monitor_vif,
							 virtual interfs reference_model_vif
							);
		this.driver_vif = driver_vif;
		this.monitor_vif = monitor_vif;
	 	this.reference_model_vif = reference_model_vif;
	endfunction	

	task build_components();
		begin
			gen2drv_mbx = new();
			drv2ref_mbx = new();
			ref2scb_mbx = new();
			mon2scb_mbx = new();

			gen = new(gen2drv_mbx);
			drv = new(gen2drv_mbx, drv2ref_mbx, driver_vif);
			ref_model = new(drv2ref_mbx, ref2scb_mbx, reference_model_vif);
			mon = new(monitor_vif, mon2scb_mbx);
			scb = new(ref2scb_mbx,mon2scb_mbx);
		end	
	endtask

	task run_all();
		fork
			gen.run();
			drv.run();
			mon.run();
			ref_model.run();
			scb.run();
		join
		scb.compare_report();
	endtask
endclass
