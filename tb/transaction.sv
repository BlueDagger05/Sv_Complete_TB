// APB slave transaction class
// this file includes APB data fields and 

// Transaction package which includes Transaction class
// To avoid multiple inclusions of classes

package Trasaction;
`include "defines.sv"

class Transaction;
import apb_states::*;

//------------------------------
// Transaction fields
//------------------------------

	randc bit 			PENABLE;
	randc bit 			PREADY	
	randc bit [`ADDR_WIDTH -1:0] 	PADDR;
	randc bit 			PWRITE;
	randc bit			PRESETn;
	randc bit [`DATA_WIDTH -1:0]	PWDATA;
	rand apb_states st;

//------------------------------
// Constraints
//------------------------------
	constraint c_PADDR  {PADDR  inside [0:10];}
	constraint c_PWDATA {PWDATA inside [0:20];}

endclass: Transaction

endpackage: Transaction
