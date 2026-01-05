`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.01.2026 19:46:46
// Design Name: 
// Module Name: tb_ahb_apb_bridge
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


module tb_ahb_apb_bridge;

    logic HCLK, HRESETn;
    logic [31:0] HADDR, HWDATA, HRDATA;
    logic HWRITE, HREADY, HREADYin, HRESP;
    logic [1:0] HTRANS;

    logic [31:0] PADDR, PWDATA, PRDATA;
    logic PWRITE, PSEL, PENABLE, PREADY;

    ahb_to_apb_bridge dut (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HADDR(HADDR),
        .HWRITE(HWRITE),
        .HTRANS(HTRANS),
        .HWDATA(HWDATA),
        .HREADYin(HREADYin),
        .HRDATA(HRDATA),
        .HREADY(HREADY),
        .HRESP(HRESP),
        .PADDR(PADDR),
        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY)
    );

    apb_slave_model apb (
        .PCLK(HCLK),
        .PRESETn(HRESETn),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY)
    );

    // Clock
    initial HCLK = 0;
    always #5 HCLK = ~HCLK;

    task ahb_write(input [31:0] addr, input [31:0] data);
        @(posedge HCLK);
        HADDR  <= addr;
        HWDATA <= data;
        HWRITE <= 1;
        HTRANS <= 2'b10;
        wait(HREADY);
        @(posedge HCLK);
        HTRANS <= 0;
    endtask

    task ahb_read(input [31:0] addr);
        @(posedge HCLK);
        HADDR  <= addr;
        HWRITE <= 0;
        HTRANS <= 2'b10;
        wait(HREADY);
        @(posedge HCLK);
        HTRANS <= 0;
    endtask

    initial begin
        HRESETn  = 0;
        HREADYin = 1;
        HTRANS   = 0;
        HWRITE   = 0;
        HADDR    = 0;
        HWDATA   = 0;

        #20 HRESETn = 1;

        ahb_write(32'h10, 32'hDEADBEEF);
        ahb_read (32'h10);

        #20;
        $display("Read Data = %h", HRDATA);
        $finish;
    end

endmodule

