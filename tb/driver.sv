package driver_pkg::*;

// importing packages
import transaction_pkg::*;
import generator_pkg::*;
import apb_slave_ifc::*;

class Driver;
	Transaction trnx, trnx_c;
	mailbox #(Transaction) agt2drv;

	virtual apb_slave_ifc vif();

//  class constructor 
//  parameterized new function with mailbox and virtual apb_slave_ifc
	function new(input mailbox #(Transaction) agt2drv, virtual apb_slave_ifc vif);
		this.agt2drv = agt2drv;
		this.vif 	 = vif;
	endfunction : new

//----------------------------------------
// Functions
//----------------------------------------
	extern virtual function void drv_dp();
	
//----------------------------------------
// APB Slave Reset task
//----------------------------------------
	extern virtual task rst_apb();

//----------------------------------------
// APB Slave Main run task
//----------------------------------------
	extern virtual task run();


endclass : Driver

//----------------------------------------
// Extern Definitions
//----------------------------------------

// drv_dp function
function void Driver::drv_dp(int tt);
	$display("@%0d :: PKT_ID [%0d] PADDR = 0x%0h, PWDATA = 0x%0h \n",tt, vif.PADDR, vif.PWDATA);
endfunction

// rst_apb task
task Driver::rst_apb();

	// wait for PRESETn to transit low and drive default '0' 
	// value to inputs and remain in IDLE state
	wait(!vif.PRESETn)
	begin
		vif.PWDATA <= 8'h0000_0000;
		vif.PADDR  <= 8'h0000_0000;
		vif.ENABLE <= 1'b0;
		vif.PWRITE <= 1'b0;
		$display("@%0t :: PRESETn ACTIVE",$time);
		$display("----------------------------\n",);
	end

	// After Four clock edges drive the data
	repeat(4) @(vif.drv_cb);

endtask : rst_apb

// run task
task run();
	forever 
	begin
		// creating new transaction object
		trnx = new();

		// Using get method to get pin activity for DUT
		agt2drv.get(trnx);

		// Deep copying trnx object to trnx_c
		trnx_c = trnx.copy();

		// Driving at drv_cb clocking block
		@(vif.drv_cb) 
		begin
			vif.PENABLE <= trnx_c.PENABLE;
			vif.PREADY  <= trnx_c.PREADY;
			vif.PADDR   <= trnx_c.PADDR;
			vif.PWRITE  <= trnx_c.PWRITE;
			vif.PWDATA	<= trnx_c.PWDATA;
		end

		// Displaying the contents to be driven
		drv_dp($time);

		end
	endtask : run
endpackage : driver_pkg