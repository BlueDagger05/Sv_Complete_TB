package checker_pkg;
import apb_slave_ifc::*;
import transaction_pkg::*;
	
class Checker;
	mailbox #(Transaction) mon2chkr, #(Transaction) chkr2scb;	
	
	// Denotes number of packets
	int numofPackets = 0;

	// Constructor
	function new(mailbox #(Transaction) mon2chkr, mailbox #(Transaction) chkr2scb);
		this.mon2chkr = mon2chkr;
		this.chkr2scb = chkr2scb;
	endfunction : new

//------------------------------
// Run Task
//------------------------------
	extern virtual task run(numofPackets);
endclass: Checker	

// Run task
task virtual Checker:: run(int numofPackets);
	Transaction trnx_chkr2scb, trnx_mon2chkr;
	repeat(numofPackets)
	begin

		// Creating object 
		trnx_chkr2scb = new;
		trnx_mon2chkr = new;

		mon2chkr.get(trnx_mon2chkr);

		// forwarding those packets having valid read
		is_good_rd = trnx_mon2chkr.copy();

		// forwarding those packets having valid write
		is_good_wr = trnx_mon2chkr.copy();

		// valid read if not in reset state
		if( ~is_good_rd.PWRITE && is_good_rd.PRESETn )
			chkr2scb.put(is_good_rd);

		// valid write if not in reset state
		else if( is_good_wr.PWRITE && is_good_wr.PRESETn )
			chkr2scb.put(is_good_wr);

		// experimental
		// Discarding bad packets
		else
			{is_good_rd, is_good_wr} = null;

	end
endtask

endpackage : checker_pkg