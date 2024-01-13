`include "defines.sv"
package apb_pkg;

// interface declaration and definition	
interface apb_slave_ifc (input bit PCLK);

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
	logic					 PRESETn;
	logic [`DATA_WIDTH -1:0] PWDATA;

//----------------------------------------	
// clocking blocks
//----------------------------------------
	clocking cb @(posedge PCLK);
		// can add input and output delay
		output PRDATA;
		input  PENABLE, PREADY, PADDR, PWDATA;
	endclocking: cb

	modport TEST (clocking cb, output rst);
	modport DUT (output PRDATA, input PENABLE, PREADY, PADDR, PWRITE,PRESETn, PWDATA, PCLK);

endinterface : apb_slave_ifc

endpackage : apb_pkg