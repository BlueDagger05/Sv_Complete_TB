`include "interface.sv"
//import test_pkg::Test;
`include "test.sv"

module tb_top;
//----------------------------------------
// local signals and parameters
//----------------------------------------

	logic clk;
	logic rst;
	localparam timePeriod  = 10;
	localparam resetPeriod = 200;

// interface instance	
	apb_slave_ifc ifc (.PCLK(clk), .PRESETn(rst));

// Test instantiation
	Test t0 (ifc);
// connceting DUT with modport APB_SLV defined interface
	apb_slave DUT (ifc.APB_SLV);

// Generating Clock	
	initial
	begin: clock_generation
		clk = 1'b0;
		forever #(timePeriod/2) clk = ~clk;
	end: clock_generation


// Generating Reset
	initial 
	begin: reset_generation
		rst = 1'b0;
		forever #(resetPeriod/2) rst = ~rst;
	end: reset_generation

// Scratch logic
// Invoking Test
// Binding sample_test with modport TEST
// connecting test program with interface
// Test t1(.ifc(ifc.TEST);


endmodule : tb_top