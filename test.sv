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

//Regression testing cases
