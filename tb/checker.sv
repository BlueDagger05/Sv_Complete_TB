package checker_pkg;
import transaction_pkg::*;
	
class Checker;
	mailbox #(Transaction) mon2chkr;
	mailbox #(Transaction) chkr2scb;	
	
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
	extern virtual task run(int);
	
endclass: Checker	

// Run task
task Checker:: run(int numofPackets);
    // Creating object 
	Transaction trnx_chkr2scb, trnx_mon2chkr = new;
	Transaction is_good_wr, is_good_rd = new;
	repeat(numofPackets)
	begin
		mon2chkr.get(trnx_mon2chkr);

		// forwarding those packets having valid read
		is_good_rd.copy(trnx_mon2chkr);

		// forwarding those packets having valid write
		is_good_wr.copy(trnx_mon2chkr);

		// valid read if not in reset state
		if( ~is_good_rd.PWRITE && is_good_rd.PRESETn )
			chkr2scb.put(is_good_rd);

		// valid write if not in reset state
		else if( is_good_wr.PWRITE && is_good_wr.PRESETn )
			chkr2scb.put(is_good_wr);

		// experimental
		// Discarding bad packets
		else 
		begin
			is_good_rd = null;
			is_good_wr = null;
        end
	end
endtask

endpackage : checker_pkg