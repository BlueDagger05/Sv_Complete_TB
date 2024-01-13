package monitor_pkg;

// Importing packages	
import transaction_pkg::*;
import apb_pkg::*;
		
class Monitor;
	Transaction trnx, trnx_c;
	mailbox #(Transaction) mon2chkr;

	virtual apb_slave_ifc vif;

// New Constructor	
//  parameterized new function with mailbox and virtual apb_slave_ifc
	function new(input mailbox #(Transaction) mon2chkr, virtual apb_slave_ifc vif);
		this.mon2chkr = mon2chkr;
		this.vif 	  = vif;
	endfunction : new

//----------------------------------------
// Functions
//----------------------------------------
	extern virtual function void mon_dp();

//----------------------------------------
// APB Slave Main run task
//----------------------------------------
	extern virtual task run();

endclass: Monitor		

//----------------------------------------
// Extern Definitions
//----------------------------------------

	// mon_dp function
function void Monitor::mon_dp(int tt);
	$display("@%0d :: PKT_ID [%0d] PADDR = 0x%0h, PWDATA = 0x%0h \n",tt, vif.PADDR, vif.PWDATA);
endfunction


// run task
task Monitor::run();
	forever begin

		trnx = new();
		// Getting data from vif and storing in trnx objects

		@(vif.mon_cb)
		begin
			trnx.PADDR 	 = vif.PADDR;
			trnx.PWDATA  = vif.PWDATA;	
			trnx.PRESETn = vif.PRESETn;
			trnx.PENABLE = vif.PENABLE;
			trnx.PWRITE  = vif.PWRITE;
			trnx.PREADY  = vif.PREADY;
		end

		// Copying trnx object into trnx_c
		trnx_c = trnx.copy();

		// Using put method to send data object to checker
		mon2chkr.put(trnx_c);
	end
endtask
endpackage : monitor_pkg