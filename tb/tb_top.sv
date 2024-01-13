`include "interface.sv"
import test_pkg::Test;

module tb_top;
//----------------------------------------
// local signals and parameters
//----------------------------------------

	logic clk;
	logic rst;
	localparam timePeriod  = 10;
	localparam resetPeriod = 200;

// interface instance	
	design_ifc ifc(.clk(clk));

// connceting DUT with modport DUT defined interface
	design DUT(ifc.DUT);

// Generating Clock	
	initial
	begin: clock_generation
		clk = 1'b;
		forever #(timePeriod/2) clk = ~clk
	end: clock_generation


// Generating Reset
	initial 
	begin: reset_generation
		rst = 1'b0;
		forever #(resetPeriod/2) rst = ~rst;
	end: reset_generation

// Invoking Test
// Binding sample_test with modport TEST
// connecting test program with interface
// Test t1(.ifc(ifc.TEST);
Test t1(.ifc(ifc.TEST));

endmodule : tb_top