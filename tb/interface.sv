`include "defines.sv"
package apb_pkg;

// interface declaration and definition	
interface apb_slave_ifc (input bit PCLK, PRESETn);

//----------------------------------------
// add your signals
//----------------------------------------
	
// output signals	
	logic [`DATA_WIDTH -1:0] PRDATA;

// input signals
	logic 					 PENABLE;
	logic [`DATA_WIDTH -1:0] PREADY;
	logic [`ADDR_WIDTH -1:0] PADDR;
	logic 					 PWRITE;
	logic [`DATA_WIDTH -1:0] PWDATA;

//----------------------------------------	
// clocking blocks
//----------------------------------------

	// Driver CB
	clocking drv_cb @(posedge PCLK);
		input   PRDATA;
		output  PENABLE, PREADY, PADDR, PWDATA, PRESETn;
	endclocking: drv_cb

	// APB-Slave CB
	clocking slv_cb @(posedge PCLK);
		output  PRDATA;
		input   PENABLE, PREADY, PADDR, PWDATA, PRESETn;
	endclocking:slv_cb

	// Monitor CB
	clocking mon_cb @(posedge PCLK);
		input PENABLE, PREADY, PADDR, PWDATA, PRDATA, PRESETn;
	endclocking : mon_cb

//----------------------------------------
// Modports
//----------------------------------------
	
	// Modport for driver
	modport DRV (clocking drv_cb);

	// Modport for APB-Slave DUT
	modport APB_SLV (clocking slv_cb);

	// Modport for monitor
	modport MON (clocking mon_cb);

endinterface : apb_slave_ifc

endpackage : apb_pkg