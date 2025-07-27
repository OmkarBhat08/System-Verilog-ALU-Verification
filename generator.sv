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
			$display("@time = %0t Randomized: inp_valid=%0d | mode = %0d | cmd = %0d | ce = %0d | opa =%0d | opb = %0d | cin=%0d",&time,blueprint.inp_valid,blueprint.mode,blueprint.cmd,blueprint.ce,blueprint.opa,blueprint.opb.blueprint.cin);
		end
	endtask
endclass
