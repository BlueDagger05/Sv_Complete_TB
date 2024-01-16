`timescale 1ns / 1ps
`include "/home/whiteshadow/Desktop/vivado/amba_apb/amba_apb.srcs/sim_1/imports/tb/interface.sv"
module apb_slave (apb_slave_ifc.APB_SLV ifc);


localparam DATA_WIDTH = 8;
localparam ADDR_WIDTH = 4;
localparam mem_width = 1<<ADDR_WIDTH;

// temp memory array storage
reg [7:0] memory [15:0];

typedef enum logic [1:0] {IDLE, SETUP, ACCESS} apb_states;

logic [1:0] state;


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
                else if(ifc.PSELx)
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
