`include "defines.sv"
class generator;
	transaction blueprint;
	mailbox #(transaction) gen2drv_mbx;

	function new(mailbox #(transaction) gen2drv_mbx);
		this.gen2drv_mbx = gen2drv_mbx;
		blueprint = new();
	endfunction

	task run();
		for(int i=0;i<`trans_number;i++)
		begin
			blueprint.randomize();
			gen2drv_mbx.put(blueprint.copy());
			$display("Randomized:");
		end
	endtask
endclass
