`timescale 1ns / 1ps
`include "packages.sv"
module apb_slave #(apb_slave_ifc.APB_SLV ifc,
                   parameter DATA_WIDTH = 8,
                   parameter ADDR_WIDTH = 4);		   

import apb_pkg::*;
import apb_states::*;
/*
(
   output   reg [DATA_WIDTH -1:0] PRDATA,
   input   wire                   PSELx,
   
   input   wire                   PENABLE,
   input   wire                   PREADY,
   input   wire [ADDR_WIDTH -1:0] PADDR,
   input   wire                   PWRITE,
   input   wire                   PRESETn,
   input   wire                   PCLK,
   input   wire [DATA_WIDTH -1:0] PWDATA
);
*/

localparam mem_width = 1<<ADDR_WIDTH;

// temporary variables for present and next state
reg [2:0] p_state, n_state;

// temp memory array storage
reg [DATA_WIDTH -1:0] memory [mem_width-1:0];

reg [1:0] state;

    always_ff @(posedge ifc.PCLK or negedge ifc.PRESETn)
    begin 
        if(~ifc.PRESETn) begin
            state <= IDLE;
        end else begin
            case(state)
                IDLE: 
                begin
                    if(!ifc.PSELx)
                    begin
                        {memory[ifc.PADDR], ifc.PRDATA} <= 16'h0000_0000_0000_0000;
                        state <= IDLE;
                    end
                    else if(PSELx)
                        state <= SETUP;
                end

                SETUP:
                begin
                    if(ifc.PSELx && ifc.PWRITE)
                    begin
                        memory[ifc.PADDR] <= ifc.PWDATA;
                        if(ifc.PENABLE)
                            state <= ACCESS;
                        else
                            state <= SETUP;                            
                    end
                    
                    else if(ifc.PREADY && ifc.PSELx && !ifc.PWRITE) begin
                        ifc.PRDATA <= memory[ifc.PADDR];
                        
                        // if PENABLE == HIGH MOVE TO ACCESS STATE
                        if(ifc.PENABLE)
                            state <= ACCESS;
                            
                        // ELSE STAY IN SETUP STATE                            
                        else
                            state <= SETUP;
                   end
                end

                ACCESS:
                begin
                    if(ifc.PSELx && ifc.PENABLE && !ifc.PREADY)
                        state <= ACCESS;
                    else if(ifc.PSELx && !ifc.PENABLE && ifc.PREADY) 
                        state <= SETUP;
                    else
                        state <= IDLE;
                end


            endcase // state

        end
    end
endmodule
