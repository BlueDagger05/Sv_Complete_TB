// APB slave transaction class
// this file includes APB data fields and 

// Transaction package which includes Transaction class
// To avoid multiple inclusions of classes

package transaction_pkg;
`include "defines.sv"

import apb_states::*;
class Transaction;

//------------------------------
// Transaction fields
//------------------------------

	randc bit [`ADDR_WIDTH -1:0] PADDR;
	randc bit 					 PWRITE;
	 rand apb_states st;
	      bit 					 PENABLE;
		  bit 					 PREADY;	
		  bit [`DATA_WIDTH -1:0] PWDATA;
	 	  bit  is_rd, is_wr;
		  bit PRESETn;

//------------------------------
// Constraints
//------------------------------
	constraint c_PADDR  { PADDR  inside [0:10]; }
	constraint c_PWDATA { PWDATA inside [0:20]; }

	// constraint for weighted dist of APB-slave states
	constraint c_st {st dist { 2:= 5, 0:=3, 1:=7}; }
		
endclass: Transaction

endpackage: transaction_pkg
