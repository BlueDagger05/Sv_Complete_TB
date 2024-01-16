package driver_pkg;

// importing packages
import transaction_pkg::*;
import generator_pkg::*;
//import apb_pkg::*;

class Driver;
	Transaction trnx, trnx_c;
	mailbox #(Transaction) agt2drv;

	virtual apb_slave_ifc vif;

// local defines

// temporary varibles
static int ID;
int count;
//  class constructor 
//  parameterized new function with mailbox and virtual apb_slave_ifc
	function new(input mailbox #(Transaction) agt2drv, virtual apb_slave_ifc vif);
		this.agt2drv = agt2drv;
		this.vif 	 = vif;
	endfunction : new

//----------------------------------------
// Functions
//----------------------------------------
	extern virtual function void drv_dp(int , int, bit[7:0], bit[7:0]);
	
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
	//extern virtual task write(Transaction trnx, int, apb_slave_ifc);
task write(Transaction trnx, int ID);
	forever 
	begin
		Transaction wr_trnx = new;
		wr_trnx.copy(trnx);
		vif.DRV.drv_cb.PWDATA <= 8'haa;
		@(posedge vif.PCLK)
		begin

			// Setup Phase
			vif.PWRITE <= 1'b1;
			vif.PSELx  <= 1'b1;
			vif.PADDR  <= wr_trnx.PADDR;
			vif.PWDATA <= wr_trnx.PWDATA;

			// 	ACCESS PHASE
			// @(posedge vif.DRV.PCLK)
			vif.PENABLE <= 1'b1;
			vif.PREADY  <= 1'b1;

			// 	IDLE STATE
			// @(posedge vif.DRV.PCLK)
			vif.PENABLE <= 1'b0;

			// Displaying the contents to be driven
			drv_dp($time, ID, vif.PADDR, vif.PWDATA);
		end
	end
endtask

//----------------------------------------
// APB Slave read task
//----------------------------------------
	extern virtual task read(Transaction trnx, int);

endclass : Driver

//----------------------------------------
// Extern Definitions
//----------------------------------------

// drv_dp function
function void Driver::drv_dp(int tt, int ID, bit[7:0] PADDR, bit[7:0] PWDATA);
	$display("@%0d :: PKT_ID [%0d] PADDR = 0x%0h, PWDATA = 0x%0h \n",tt, ID, PADDR, PWDATA);
endfunction

// rst_apb task
task Driver::rst_apb();

	// wait for PRESETn to transit low and drive default '0' 
	// value to inputs and remain in IDLE state
	wait(!vif.PRESETn)
	begin
		vif.PWDATA 	<= 8'h0000_0000;
		vif.PADDR  	<= 8'h0000_0000;
		vif.PENABLE  <= 1'b0;
		vif.PWRITE   <= 1'b0;
		$display("@%0t :: PRESETn ACTIVE",$time);
		$display("----------------------------\n",);
	end

	// After Four clock edges drive the data
	repeat(4) @(vif.PCLK);

endtask : rst_apb

// main_run task
task Driver::main_run();
	// creating new transaction object
	Transaction trnx_c = new;
	Transaction trnx   = new;

	forever 
	begin

		// Using get method to get pin activity for DUT
		agt2drv.get(trnx);

		// Deep copying trnx object to trnx_c
		trnx_c.copy(trnx);

		// calling write task
		if(trnx_c.is_wr)
			write(trnx_c, ID);
		// calling read task
		else
			read(trnx_c, ID);
		// ID = count++;
	end
endtask : main_run

// write task



task Driver :: read(Transaction trnx, int ID);
forever 	
begin
	Transaction rd_trnx = new;
	rd_trnx.copy(trnx);
	
	@(posedge vif.DRV.PCLK)
	begin
		// Setup Phase
		vif.PWRITE <= 1'b0;
		vif.PSELx  <= 1'b1;
		vif.PADDR  <= rd_trnx.PADDR;

		// ACCESS PHASE
		// @(posedge vif.DRV.PCLK)
		vif.PENABLE <= 1'b1;
		vif.PREADY  <= 1'b1;

		// IDLE STATE
		// @(posedge vif.DRV.PCLK)
		vif.PENABLE <= 1'b0;

		// Displaying the contents to be driven
		drv_dp($time, ID, vif.PADDR, vif.PWDATA);
	end
	
end
endtask 	
endpackage : driver_pkg
