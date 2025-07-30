`include "environment.sv"
class test;
	virtual interfs driver_vif;
	virtual interfs monitor_vif;
	virtual interfs reference_model_vif;

	environment env;

	function new(virtual interfs driver_vif,
							 virtual interfs monitor_vif,
							 virtual interfs reference_model_vif
							);
		this.driver_vif = driver_vif;
		this.monitor_vif = monitor_vif;
		this.reference_model_vif = reference_model_vif;
	endfunction

	task run();
		env = new(driver_vif, monitor_vif, reference_model_vif);
		env.build_components;
		env.run_all;
	endtask
endclass

// Regression testing cases
class test1 extends test;			// Normal
	transaction1 trans;

	function new(virtual interfs driver_vif,
							 virtual interfs monitor_vif,
							 virtual interfs reference_model_vif
							);
		super.new(driver_vif,monitor_vif,reference_model_vif);
	endfunction
	
	task run();
		env = new(driver_vif,monitor_vif,reference_model_vif);
		env.build_components;
		begin
			trans = new();
			env.gen.blueprint = trans;
		end
		env.run_all;
	endtask
endclass

class test2 extends test;		// Latch
	transaction2 trans;

	function new(virtual interfs driver_vif,
							 virtual interfs monitor_vif,
							 virtual interfs reference_model_vif
							);
		super.new(driver_vif,monitor_vif,reference_model_vif);
	endfunction
	
	task run();
		env = new(driver_vif,monitor_vif,reference_model_vif);
		env.build_components;
		begin
			trans = new();
			env.gen.blueprint = trans;
		end
		env.run_all;
	endtask
endclass

class test3 extends test;			// Error
	transaction3 trans;

	function new(virtual interfs driver_vif,
							 virtual interfs monitor_vif,
							 virtual interfs reference_model_vif
							);
		super.new(driver_vif,monitor_vif,reference_model_vif);
	endfunction
	
	task run();
		env = new(driver_vif,monitor_vif,reference_model_vif);
		env.build_components;
		begin
			trans = new();
			env.gen.blueprint = trans;
		end
		env.run_all;
	endtask
endclass

class test4 extends test;			// Arithmetic
	transaction4 trans;

	function new(virtual interfs driver_vif,
							 virtual interfs monitor_vif,
							 virtual interfs reference_model_vif
							);
		super.new(driver_vif,monitor_vif,reference_model_vif);
	endfunction
	
	task run();
		env = new(driver_vif,monitor_vif,reference_model_vif);
		env.build_components;
		begin
			trans = new();
			env.gen.blueprint = trans;
		end
		env.run_all;
	endtask
endclass

class test5 extends test;				// Logical
	transaction5 trans;

	function new(virtual interfs driver_vif,
							 virtual interfs monitor_vif,
							 virtual interfs reference_model_vif
							);
		super.new(driver_vif,monitor_vif,reference_model_vif);
	endfunction
	
	task run();
		env = new(driver_vif,monitor_vif,reference_model_vif);
		env.build_components;
		begin
			trans = new();
			env.gen.blueprint = trans;
		end
		env.run_all;
	endtask
endclass
