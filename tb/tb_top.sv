`include "interface.sv"
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
		clk = 1'b0;
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
	sample_test test(ifc.TEST);
	initial
	begin: invoking_test

		// running test
		fork
			test.run();
		join_none
	
	end: invoking_test



endmodule : tb_top
