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
extern function void drv_dp();
	
//----------------------------------------
// APB Slave Reset task
//----------------------------------------
	task rst_sv();
		// wait for PRESETn to transit low and drive default '0' 
		// value to inputs and remain in IDLE state
		wait(!vif.PRESETn)
		begin
			vif.PWDATA <= 8'h0000_0000;
			vif.PADDR  <= 8'h0000_0000;
			vif.ENABLE <= 1'b0;
			$display("@%0t :: PRESETn ACTIVE",$time);
			$display("----------------------------\n",);
		end

		// After Two clock edges drive the data
		repeat(2) @(posedge vif.PCLK);

	endtask : rst_sv

// Main run task
	task run();
		forever 
		begin

			// creating new transaction object
			trnx = new();

			// Using get method to get pin activity for DUT
			agt2drv.get(trnx);

			// Deep copying trnx object to trnx_c
			trnx_c = trnx.copy();

			vif.PENABLE <= trnx.PREADY;
			vif.PADDR   <= trnx.PADDR;
			vif.PWRITE  <= trnx.PWRITE;
			vif.PWDATA	<= trnx.PWDATA;
		end
	endtask : run

endclass : Driver

function void Driver::drv_dp();
	$display("PKT_ID [%0d] ",);
endfunction

endpackage : driver_pkg