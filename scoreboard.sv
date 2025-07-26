`include "defines.sv"

class scoreboard;
	transaction ref2scb_trans, mon2scb_trans;

	mailbox #(transaction) ref2scb_mbx;
	mailbox #(transaction) mon2scb_mbx;

	function new(mailbox #(ram_transaction) ref2scb_mbx,
               mailbox #(ram_transaction) mon2scb_mbx);
    this.ref2scb_mbx = ref2scb_mbx;
    this.mon2scb_mbx = mon2scb_mbx;
  endfunction

	task run();
    for(int i=0;i<`trans_number;i++)
      begin
        ref2sb_trans = new();
        mon2sb_trans = new();
        //MBX -> reference model transaction
        ref2scb_mbx.get(ref2sb_trans);
        $display("In scoreboard @time = %0t from Reference: \n res=%0d |err=%b | oflow=%b | cout=%b | g=%b | l=%b | e=%b",$time,ref2sb_trans.res,ref2sb_trans.err,ref2sb_trans.oflow,ref2sb_trans.cout,ref2sb_trans.g,ref2sb_trans.l,ref2sb_trans.e);
					
				//MBX -> monitor transaction
        mon2scb_mbx.get(mon2scb_trans);
        $display("In scoreboard @time = %0t from Monitor: \n res=%0d |err=%b | oflow=%b | cout=%b | g=%b | l=%b | e=%b",$time,mon2scb_trans.res,mon2scb_trans.err,mon2scb_trans.oflow,mon2scb_trans.cout,mon2scb_trans.g,mon2scb_trans.l,mon2scb_trans.e);
      	compare_report();
      end
		end
  endtask

	task compare_report();
     if(ref2sbc_trans == mon2scb_trans)
     begin
			 $display("------------------------------------Report------------------------------------");
       $display("@time = %0t from Reference: \n res=%0d |err=%b | oflow=%b | cout=%b | g=%b | l=%b | e=%b",$time,ref2sb_trans.res,ref2sb_trans.err,ref2sb_trans.oflow,ref2sb_trans.cout,ref2sb_trans.g,ref2sb_trans.l,ref2sb_trans.e);
       $display("@time = %0t from Monitor: \n res=%0d |err=%b | oflow=%b | cout=%b | g=%b | l=%b | e=%b",$time,mon2scb_trans.res,mon2scb_trans.err,mon2scb_trans.oflow,mon2scb_trans.cout,mon2scb_trans.g,mon2scb_trans.l,mon2scb_trans.e);
			 MATCH++;
			 $display("Test passed = %d",MATCH);
			 $display("------------------------------------------------------------------------------");
		 end
     else
     begin
			 $display("------------------------------------Report------------------------------------");
       $display("@time = %0t from Reference: \n res=%0d |err=%b | oflow=%b | cout=%b | g=%b | l=%b | e=%b",$time,ref2sb_trans.res,ref2sb_trans.err,ref2sb_trans.oflow,ref2sb_trans.cout,ref2sb_trans.g,ref2sb_trans.l,ref2sb_trans.e);
       $display("@time = %0t from Monitor: \n res=%0d |err=%b | oflow=%b | cout=%b | g=%b | l=%b | e=%b",$time,mon2scb_trans.res,mon2scb_trans.err,mon2scb_trans.oflow,mon2scb_trans.cout,mon2scb_trans.g,mon2scb_trans.l,mon2scb_trans.e);
			 MISMATCH++;
			 $display("Test failed = %d",MISMATCH);
			 $display("------------------------------------------------------------------------------");
		 end
	 endtask
endclass
