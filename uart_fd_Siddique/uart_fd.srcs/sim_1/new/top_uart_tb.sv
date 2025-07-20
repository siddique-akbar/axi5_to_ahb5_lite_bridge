`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2025 12:10:14 PM
// Design Name: 
// Module Name: top_uart_tb
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


module top_uart_tb();

localparam CLK_PERIOD = 10;
    logic sys_clk, rst, rx_data, tx_en, rx_en, tx_status, tx_data, rx_status, data_correct;
    logic [1:0] sel_baud;
    logic [7:0] data_in, data_out;
    
    top_uart u1( .sys_clk, .rx_data, .rst, .tx_en, .rx_en,  .sel_baud, .data_in,   //inputs to module 
                 .data_out, .tx_status, .tx_data, .rx_status, .data_correct );   //output from module
    
    initial sys_clk = 0;
    always #(CLK_PERIOD/2) sys_clk = ~sys_clk;
    
    initial begin
    // Initialize all inputs
    rst = 0;
    
    {tx_en, rx_en,  sel_baud, data_in} =  12'b00_00_00000000;
    rx_data = 1'b1;
    #CLK_PERIOD
        rst = 1'b1;
//        rx_data = 1'b1;
//        {tx_en, rx_en, sel_baud, data_in} =  12'b10_00_01000001;   //writing ASCII A
//    #(CLK_PERIOD*10416*10)
        {tx_en, rx_en,  sel_baud, data_in} =  12'b01_00_01000001;
        rx_data = 1'b1;
    #CLK_PERIOD
        {tx_en, rx_en,  sel_baud, data_in} =  12'b01_00_01000001;
        rx_data = 1'b0;
    #(CLK_PERIOD*10416)
        {tx_en, rx_en,  sel_baud, data_in} =  12'b01_00_01000001;
        rx_data = 1'b1;
    #(CLK_PERIOD*10416)
        {tx_en, rx_en,  sel_baud, data_in} =  12'b01_00_01000001;
        rx_data = 1'b0;
    #(CLK_PERIOD*10416)
        {tx_en, rx_en,  sel_baud, data_in} =  12'b01_00_01000001;
        rx_data = 1'b0;
    #(CLK_PERIOD*10416)
        {tx_en, rx_en,  sel_baud, data_in} =  12'b01_00_01000001;
        rx_data = 1'b0;
    #(CLK_PERIOD*10416)
        {tx_en, rx_en,  sel_baud, data_in} =  12'b01_00_01000001;
        rx_data = 1'b0;
    #(CLK_PERIOD*10416)
        {tx_en, rx_en,  sel_baud, data_in} =  12'b01_00_01000001;
        rx_data = 1'b0;
    #(CLK_PERIOD*10416)
        {tx_en, rx_en,  sel_baud, data_in} =  12'b01_00_01000001;
        rx_data = 1'b1;
    #(CLK_PERIOD*10416)
        {tx_en, rx_en,  sel_baud, data_in} =  12'b01_00_01000001;
        rx_data = 1'b0;
    #(CLK_PERIOD*10416)
        {tx_en, rx_en,  sel_baud, data_in} =  12'b01_00_01000001;
        rx_data = 1'b1;
        
//    $finish;
    end
        
endmodule
