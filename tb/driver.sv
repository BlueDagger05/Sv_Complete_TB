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
	extern virtual function void drv_dp(int tt);
	
//----------------------------------------
// APB Slave Reset task
//----------------------------------------
	extern virtual task rst_apb();

//----------------------------------------
// APB Slave Main run task
//----------------------------------------
	extern virtual task main_run();

//----------------------------------------
// APB Slave write task
//----------------------------------------
	extern virtual task write(Transaction wr_trnx);

//----------------------------------------
// APB Slave read task
//----------------------------------------
	extern virtual task read(Transaction rd_trnx);

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

// main_run task
task main_run();
	forever 
	begin
		// creating new transaction object
		trnx = new();

		// Using get method to get pin activity for DUT
		agt2drv.get(trnx);

		// Deep copying trnx object to trnx_c
		trnx_c = trnx.copy();

		// calling write task
		if(trnx_c.id_wr)
			write(trnx_c);

		// calling read task
		else
			read(trnx_c);

		// Displaying the contents to be driven
		drv_dp($time);

	end
endtask : main_run

// write task

task Driver:: write(Transaction wr_trnx);
	forever 
	begin
		@(vif.drv_cb)
		begin
			// Setup Phase
			vif.PWRITE <= 1'b1;
			vif.PSEL   <= 1'b1;
			vif.PADDR  <= wr_trnx.PADDR;
			vif.PWDATA <= wr_trnx.PWDATA;

			// ACCESS PHASE
			@(vif.PCLK)
			vif.PENABLE <= 1'b1;
			vif.PREADY  <= 1'b1;

			// IDLE STATE
			@(vif.PCLK)
			vif.PENABLE <= 1'b0;
		end
	end
endtask

task Driver:: read(Transaction rd_trnx);
forever 
begin
	@(vif.drv_cb)
	begin
		// Setup Phase
		vif.PWRITE <= 1'b0;
		vif.PSEL   <= 1'b1;
		vif.PADDR  <= rd_trnx.PADDR;

		// ACCESS PHASE
		@(vif.PCLK)
		vif.PENABLE <= 1'b1;
		vif.PREADY  <= 1'b1;

		// IDLE STATE
		@(vif.PCLK)
		vif.PENABLE <= 1'b0;
	end
end
endtask 	
endpackage : driver_pkg