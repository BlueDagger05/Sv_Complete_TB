`define DATA_WIDTH 8
`define ADDR_WIDTH 8
// interface declaration and definition	
interface apb_slave_ifc (input logic PCLK, logic PRESETn);

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
	logic                    PSELx;

//----------------------------------------	
// clocking blocks
//----------------------------------------

	// Driver CB
	clocking drv_cb @(posedge PCLK);
		default input #1 output	#1;
		input   PRDATA;
		output  PENABLE, PREADY, PADDR, PWRITE, PWDATA, PSELx;
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
	modport DRV (clocking drv_cb, input PCLK, input PRESETn);

	// Modport for APB-Slave DUT
	modport APB_SLV (output  PRDATA, input  PENABLE, PREADY, PADDR, PWDATA, PRESETn, PCLK, PSELx, PWRITE);

	// Modport for monitor
	modport MON (clocking mon_cb);

	// Modport for Test
	//modport TEST (output PENABLE, PREADY, PADDR, PWDATA, PRESETn, PCLK, PSELx, PWRITE, input PRDATA);
	
endinterface : apb_slave_ifc

