`include "defines.sv"

class scoreboard;
	transaction trans_ref2scb, trans_mon2scb;

	mailbox #(transaction) ref2scb_mbx;
	mailbox #(transaction) mon2scb_mbx;

	// 
endclass
