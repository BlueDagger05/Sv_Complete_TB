package monitor_pkg;

// Importing packages	
import transaction_pkg::*;
		
class Monitor;
	Transaction trnx, trnx_c;
	mailbox #(Transaction) mon2chkr;

	virtual apb_slave_ifc vif;

static int ID;
int count = 0;

// New Constructor	
//  parameterized new function with mailbox and virtual apb_slave_ifc
	function new(input mailbox #(Transaction) mon2chkr, virtual apb_slave_ifc vif);
		this.mon2chkr = mon2chkr;
		this.vif 	  = vif;
	endfunction : new

//----------------------------------------
// Functions
//----------------------------------------
	extern virtual function void mon_dp(int tt, int, bit[7:0], bit[7:0], bit [7:0]);

//----------------------------------------
// APB Slave Main run task
//----------------------------------------
	extern virtual task run();

endclass: Monitor		

//----------------------------------------
// Extern Definitions
//----------------------------------------

	// mon_dp function
function void Monitor::mon_dp(int tt, int ID, bit[7:0] PADDR, bit[7:0] PWDATA, bit [7:0] PRDATA);
	$display("@%0d :: PKT_ID [%0d] PADDR = 0x%0h, PWDATA = 0x%0h \n",tt, ID, PADDR, PWDATA, PRDATA);
endfunction


// run task
task Monitor::run();
    Transaction trnx, trnx_wr, trnx_rd;
	forever begin

		trnx 	= new;
		trnx_wr = new;
		trnx_rd = new;
		trnx_c  = new;
		// Getting data from vif and storing in trnx objects

		@(vif.mon_cb)
		begin
			if(vif.PWRITE)
			begin
				trnx.is_wr   = 1'b1;
				trnx.PADDR 	 = vif.PADDR;
				trnx.PWDATA  = vif.PWDATA;	
				trnx.PRESETn = vif.PRESETn;
				trnx.PENABLE = vif.PENABLE;
				trnx.PWRITE  = vif.PWRITE;
				trnx.PREADY  = vif.PREADY;

				// Copying trnx object ot trnx_wr object
				trnx_wr.copy(trnx);
				mon2chkr.put(trnx_wr);
				mon_dp($time, ID, vif.PADDR, vif.PWDATA, vif.PRDATA);
			end

			else 
			begin
				trnx.is_rd   = 1'b1;
				trnx.PADDR 	 = vif.PADDR;
				trnx.PWDATA  = vif.PWDATA;	
				trnx.PRESETn = vif.PRESETn;
				trnx.PENABLE = vif.PENABLE;
				trnx.PWRITE  = vif.PWRITE;
				trnx.PREADY  = vif.PREADY;

				// Copying trnx object ot trnx_rd object
				trnx_rd.copy(trnx);
				mon2chkr.put(trnx_rd);
				mon_dp($time, ID, vif.PADDR, vif.PWDATA, vif.PRDATA);
			end

			ID = count++;
		end

	end
endtask
endpackage : monitor_pkg