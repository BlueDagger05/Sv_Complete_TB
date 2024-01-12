`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.01.2024 01:22:59
// Design Name: 
// Module Name: apb_master
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

typedef enum logic [1:0] {IDLE, SETUP, ACCESS} e_state;

module apb_master #(parameter DATA_WIDTH = 8,
                    parameter ADDR_WIDTH = 4,
                    parameter PROT_WIDTH = 3,
                    parameter STRB_WIDTH = 4)(

    output reg                   PENABLE,
    output reg                   PSELx,
    output reg [ADDR_WIDTH -1:0] PADDR,
    output reg [DATA_WIDTH -1:0] PWDATA,
    output reg                   PWRITE,
//    output reg [PROT_WIDTH -1:0] PPROT,
//    output reg [STRB_WIDTH -1:0] PSTRB,

    input wire [DATA_WIDTH - 1:0] PRDATA,
    input wire                    PCLK,
    input wire                    PRESETn,
    input wire                    PREADY,
    input wire                    PSLVERR
);

// temporary variables
reg [1:0] current_state;

localparam DEPTH = 1<<ADDR_WIDTH;

reg [DATA_WIDTH -1:0] memory [DEPTH -1:0];

always_ff @(posedge PCLK or negedge PRESETn) begin : proc_master
    if(~PRESETn) begin
         current_state <= IDLE;
    end else begin
         case(current_state)
            IDLE:
            begin
               // De-selecting the slave device by pulling low PSELx signal 
               PSELx <= 1'b0;

               // Disabling the slave by pulling low PENABLE signal
               PENABLE <= 1'b0;

               if(!PRESETn) 
                    current_state <= IDLE;
                else
                    current_state <= SETUP;
            end

            SETUP:
            begin
                // ENABLING TRANSFER
                PSELx = 1'b1;

                PENABLE = 1'b0;

                // Keeping PADDR, PWRITE, PWDATA stable during setup phase

                // Transferring PADDR the lowe
                PADDR = PRDATA[3:0];
                // For write condition
                PWRITE = 1'b1;
                PADDR  = 

                // For read condition
                PWDATA <= PRDATA;   
            end

         endcase // current_state
    end
end


endmodule
