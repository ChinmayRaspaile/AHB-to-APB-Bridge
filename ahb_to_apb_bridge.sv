`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.01.2026 19:38:15
// Design Name: 
// Module Name: ahb_to_apb_bridge
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

module ahb_to_apb_bridge (
    input  logic        HCLK,
    input  logic        HRESETn,

    // AHB-Lite interface
    input  logic [31:0] HADDR,
    input  logic        HWRITE,
    input  logic [1:0]  HTRANS,
    input  logic [31:0] HWDATA,
    input  logic        HREADYin,
    output logic [31:0] HRDATA,
    output logic        HREADY,
    output logic        HRESP,

    // APB interface
    output logic [31:0] PADDR,
    output logic        PWRITE,
    output logic        PSEL,
    output logic        PENABLE,
    output logic [31:0] PWDATA,
    input  logic [31:0] PRDATA,
    input  logic        PREADY
);

    typedef enum logic [1:0] {IDLE, SETUP, ACCESS} state_t;
    state_t state, next_state;

    logic [31:0] addr_reg, wdata_reg;
    logic        write_reg;

    wire ahb_valid = HREADYin && HTRANS[1];

    // FSM state register
    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Capture AHB address phase
    always_ff @(posedge HCLK) begin
        if (ahb_valid && state == IDLE) begin
            addr_reg  <= HADDR;
            write_reg <= HWRITE;
            wdata_reg <= HWDATA;
        end
    end

    // FSM next state
    always_comb begin
        next_state = state;
        case (state)
            IDLE   : if (ahb_valid) next_state = SETUP;
            SETUP  : next_state = ACCESS;
            ACCESS : if (PREADY)  next_state = IDLE;
        endcase
    end

    // APB + AHB control
    always_comb begin
        PSEL    = 0;
        PENABLE = 0;
        PADDR   = addr_reg;
        PWRITE  = write_reg;
        PWDATA  = wdata_reg;

        HREADY  = 1;
        HRESP   = 0; // OKAY response

        case (state)
            SETUP: begin
                PSEL   = 1;
                HREADY = 0; // stall AHB
            end

            ACCESS: begin
                PSEL    = 1;
                PENABLE = 1;
                HREADY  = PREADY;
            end
        endcase
    end

    // Read data return
    always_ff @(posedge HCLK) begin
        if (state == ACCESS && PREADY && !write_reg)
            HRDATA <= PRDATA;
    end

endmodule
