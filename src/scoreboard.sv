`include "defines.sv"

class scoreboard;
	int match, mismatch;
	transaction ref2scb_trans;
	transaction mon2scb_trans;

	mailbox #(transaction) ref2scb_mbx;
	mailbox #(transaction) mon2scb_mbx;

	function new(mailbox #(transaction) ref2scb_mbx,
               mailbox #(transaction) mon2scb_mbx);
    this.ref2scb_mbx = ref2scb_mbx;
    this.mon2scb_mbx = mon2scb_mbx;
  endfunction

	task run();
    for(int i=0;i<`trans_number;i++)
		begin
			ref2scb_trans = new();
			mon2scb_trans = new();
			fork
				begin
        	//MBX -> reference model transaction
        	ref2scb_mbx.get(ref2scb_trans);
        	$display("In scoreboard @time = %0t from Reference: \n res=%0d |err=%b | oflow=%b | cout=%b | g=%b | l=%b | e=%b",$time,ref2scb_trans.res,ref2scb_trans.err,ref2scb_trans.oflow,ref2scb_trans.cout,ref2scb_trans.g,ref2scb_trans.l,ref2scb_trans.e);
				end
				begin		
					//MBX -> monitor transaction
        	mon2scb_mbx.get(mon2scb_trans);
					$display("----------------------------------------------Scoreboard @time=%0t---------------------------------------------------------",$time);
        	$display("In scoreboard @time = %0t from Monitor: \n res=%0d |err=%b | oflow=%b | cout=%b | g=%b | l=%b | e=%b",$time,mon2scb_trans.res,mon2scb_trans.err,mon2scb_trans.oflow,mon2scb_trans.cout,mon2scb_trans.g,mon2scb_trans.l,mon2scb_trans.e);
      	end
			join
      compare_report();
		end
  endtask

	task compare_report();
		if((ref2scb_trans.res == mon2scb_trans.res) && (ref2scb_trans.err == mon2scb_trans.err) && (ref2scb_trans.oflow == mon2scb_trans.oflow) && (ref2scb_trans.cout == mon2scb_trans.cout) && (ref2scb_trans.g == mon2scb_trans.g) && (ref2scb_trans.l == mon2scb_trans.l) && (ref2scb_trans.e == mon2scb_trans.e))
    begin
			$display("------------------------------------Report------------------------------------");

			$display("From Reference:");
			ref2scb_trans.disp();
			$display("From Monitor:");
			mon2scb_trans.disp();

		 match++;
		 $display("Test passed = %0d",match);
		 $display("############################################################################################################################");
		end
    else
    begin
			$display("------------------------------------Report------------------------------------");

			$display("From Reference:");
			ref2scb_trans.disp();
			$display("From Monitor:");
			mon2scb_trans.disp();

			mismatch++;
			$display("Test failed = %0d",mismatch);
		 $display("############################################################################################################################");
		end
	endtask
endclass
