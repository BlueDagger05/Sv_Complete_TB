    `timescale 1ns / 1ps
// This module consists of AHB to APB bridge i.e AHB Slave
// Provides interface between High speed AHB and low-power APB
// This module converts AHB transactions to equivalent transactions to APB  

typedef enum logic [2:0] {ST_IDLE, ST_READ, ST_WWAIT, ST_WRITE, ST_WRITEP, ST_RENABLE,  ST_WENABLE, ST_WENABLEP} bridge_states;
typedef enum logic {LOW, HIGH} valid;
module ahb2apb_bridge #(parameter DATA_WIDTH = 16,
                        parameter ADDR_WIDTH = 8)(
// Valid signal
input wire Valid,
input wire HwriteReg,
// APB master signals    
output logic                    PENABLE,
output logic                    PWRITE,
output logic  [DATA_WIDTH -1:0] PWDATA,
input   wire  [DATA_WIDTH -1:0] PRDATA,
output logic  [ADDR_WIDTH -1:0] PADDR,
output logic                    PSELx,

// AHB slave signals
input   wire  HCLK,                    
input   wire  HRESETn,
input   wire  HTRANS,
input   wire  HWRITE,
input   wire  HSELAPBif,
input   wire  HREADYin,
output logic  HREADYout,
output logic  HRESP,
input  logic  [DATA_WIDTH -1:0] HWDATA,
output logic  [DATA_WIDTH -1:0] HRDATA,
input  logic  [ADDR_WIDTH -1:0] HADDR
);

//--------------------------------------
// temporary variables
//--------------------------------------

// Depth of 2^ADDR_WIDTH
localparam DEPTH = 1<<ADDR_WIDTH;

// Registered PENABLE and PWRITE 
logic Penable_next, Pwrite_next;

// State variables
logic [2:0] current_state, next_state;

// Registered PWDATA
logic [DATA_WIDTH -1:0] temp_PWDATA;
//--------------------------------------




//--------------------------------------
// present state logic
//--------------------------------------
always_ff @(posedge HCLK or negedge HRESETn)                        
begin
    if(~HRESETn) 
        current_state <= ST_IDLE;
    else
        current_state <= next_state;
end
//--------------------------------------



//--------------------------------------
// next state logic
//--------------------------------------
always_comb
begin
    case(current_state)
        
    ST_IDLE:
    begin
        if(~Valid && ~HRESETn) 
            next_state = ST_IDLE;

        else if(Valid & HWRITE)
            next_state = ST_WWAIT;

        //else if(Valid & ~HWRITE)
        else
            next_state = ST_READ;
    end
        
    ST_WWAIT:
    begin
        if(Valid)
            next_state = ST_WRITEP;
        else
            next_state = ST_WRITE;
    end 

    ST_WRITEP:
    begin
        next_state = ST_WENABLEP;
    end 

    ST_WRITE:
    begin
        if(Valid)
            next_state = ST_WENABLEP;
        else
            next_state = ST_WENABLE;
    end 

    ST_WENABLEP:
    begin
        if(Valid && HwriteReg)
            next_state = ST_WRITEP;

        else if(~Valid && HwriteReg)
            next_state = ST_WRITE;

        else if(~HwriteReg)
            next_state = ST_READ;
    end 

    ST_WENABLE: 
    begin   
        if(Valid && HWRITE)
            next_state = ST_WWAIT;

        else if(Valid && ~HWRITE)
            next_state = ST_READ;

        else if(~Valid)
            next_state = ST_IDLE;

    end

    ST_READ: 
    begin
        if(Valid && ~HWRITE)
            next_state = ST_RENABLE;
    end

    ST_RENABLE:
    begin
      if(~Valid)
          next_state = ST_IDLE;
    end
    
    default: next_state = ST_IDLE;
    endcase // next_state
end
//--------------------------------------


//--------------------------------------
// Output logic
//--------------------------------------
always_comb
begin: OUTPUT_LOGIC
    ST_IDLE:
    begin
        if(Valid && HWRITE)
        begin
            PSELx   = LOW;
            PENABLE = LOW;        
        end

        else if(Valid && ~HWRITE)
        begin
            
        end
    end

    ST_READ:
    begin
        // Relevant PSELx is asserted and PWRITE is driven low
        PSELx   = HIGH;
        PWRITE  = LOW;

        // The address is decoded and directly driven to PADDR
        PADDR   = HADDR;

        // HRDATA  = PRDATA;

    end

    ST_WWAIT:
    begin
        // Makes available AHB transfer write data onto HWDATA
        HRDATA = PRDATA;
    end

    ST_WRITE: 
    begin
        PADDR  = HADDR;
        PSELx  = HIGH;
        PWRITE = HIGH;
        temp_PWDATA = HWDATA;
    end

    ST_WRITEP: 
    begin
        PADDR = HADDR;
        PSELx = HIGH;
    end

    ST_RENABLE: 
    begin
        PENABLE = HIGH;
    end

    ST_WENABLE:
    begin
        PENABLE = HIGH;
    end

    ST_WENABLEP:
    begin
        
    end
end: OUTPUT_LOGIC
//--------------------------------------

// As APB do not have error reporting mechanism
assign HRESP = LOW;
endmodule
