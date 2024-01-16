package scoreboard_pkg;

// importing packages	
import transaction_pkg::*;
import checker_pkg::*;
class Scoreboard;

	mailbox #(Transaction) agt2scb;
	mailbox #(Transaction) chkr2scb;

	function new(input mailbox #(Transaction) agt2scb, mailbox #(Transaction) chkr2scb);
		this.agt2scb  = agt2scb;
		this.chkr2scb = chkr2scb;
	endfunction : new		

//------------------------------
// Compare function
//------------------------------
	extern virtual function void compare(Transaction pkt_from_agt, pkt_from_chkr);

//------------------------------
// Run Task
//------------------------------
	extern virtual task run();
endclass : Scoreboard

// compare function
function void Scoreboard :: compare(Transaction pkt_from_agt, pkt_from_chkr);
	if( pkt_from_agt.PADDR == pkt_from_chkr.PADDR && pkt_from_agt.PWDATA  == pkt_from_chkr.PWDATA)
		$display(" PKT PASSED ");
	else
		$display(" PKT FAILED ");
endfunction 


// run task
task Scoreboard:: run();
	Transaction pkt_from_agt, pkt_from_chkr;
	forever begin
		pkt_from_agt  = new;
		pkt_from_chkr = new;

		fork
			agt2scb.get(pkt_from_agt);
			chkr2scb.get(pkt_from_chkr);
		join

		// comparing both of the packets
		compare(pkt_from_agt, pkt_from_chkr);
	end
endtask 

endpackage : scoreboard_pkg