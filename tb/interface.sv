`include "defines.sv"
interface design_ifc (input bit clk);

//----------------------------------------
// add your signals
//----------------------------------------
	
// output signals	
	logic [`DATA_WIDTH -1:0] signal_3;

// input signals
	logic [`DATA_WIDTH -1:0] signal_1;
	logic [`DATA_WIDTH -1:0] signal_2;
	bit						 rst;

//----------------------------------------	
// clocking blocks
//----------------------------------------
	clocking cb @(posedge clk);
		output signal_3;
		input	signal_1, signal_2;
	endclocking: cb

	modport TEST (clocking cb, output rst);
	modport DUT (output signal_3, input signa_1, signal_2, rst, clk);

endinterface : design_ifc
