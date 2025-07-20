`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2025 12:21:02 PM
// Design Name: 
// Module Name: baud_generator
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


module baud_generator #(parameter SYS_CLK = 100000000, parameter BAUD0=9600, parameter BAUD1=19200, parameter BAUD2=38400, parameter BAUD3=57600)(
    input logic sys_clk, rst,
    input logic [1:0] sel_baud,
    output logic bclk, bclk8x
    );
    logic [2:0] main_counter, bclk_counter;
    
    always_ff @(posedge sys_clk or negedge rst)
        if(!rst)
            main_counter <= 3'b000;
        else
            main_counter <= main_counter+1;
    
    
//    localparam BAUD0_BITS=$clog2 (  ((SYS_CLK/8)/(BAUD0*8)) /2);
    localparam BAUD0_BITS=$clog2 (  ((SYS_CLK/8)/(BAUD0*8)) /2);
    localparam BAUD1_BITS=$clog2 (  ((SYS_CLK/8)/(BAUD1*8)) /2);
    localparam BAUD2_BITS=$clog2 (  ((SYS_CLK/8)/(BAUD2*8)) /2);
    localparam BAUD3_BITS=$clog2 (  ((SYS_CLK/8)/(BAUD3*8)) /2);
    logic [BAUD0_BITS-1:0] buad0_count; 
    logic [BAUD1_BITS-1:0] buad1_count; 
    logic [BAUD2_BITS-1:0] buad2_count; 
    logic [BAUD3_BITS-1:0] buad3_count; 
    logic bclk8x0, bclk8x1, bclk8x2, bclk8x3;
    
    always_ff @(posedge main_counter[2] or negedge rst)
//    always_ff @(posedge sys_clk or negedge rst)
        if(!rst) begin
            buad0_count <= 0;
            bclk8x0 <= 0;
        end
        else
            if(buad0_count == ((SYS_CLK/8)/(BAUD0*8))/2-1) begin
//            if(buad0_count == 1302) begin
                buad0_count <= 0;
                bclk8x0 <= ~bclk8x0;
            end
            else
                buad0_count <= buad0_count + 1;
    
    always_ff @(posedge main_counter[2] or negedge rst)
        if(!rst) begin
            buad1_count <= 0;
            bclk8x1 <= 0;
        end
        else
            if(buad1_count == ((SYS_CLK/8)/(BAUD1*8))/2-1) begin
                buad1_count <= 0;
                bclk8x1 <= ~bclk8x1;
            end
            else
                buad1_count <= buad1_count + 1;
    
    always_ff @(posedge main_counter[2] or negedge rst)
        if(!rst) begin
            buad2_count <= 0;
            bclk8x2 <= 0;
        end
        else
            if(buad2_count == ((SYS_CLK/8)/(BAUD2*8))/2-1) begin
                buad2_count <= 0;
                bclk8x2 <= ~bclk8x2;
            end
            else
                buad2_count <= buad2_count + 1;
    
    always_ff @(posedge main_counter[2] or negedge rst)
        if(!rst) begin
            buad3_count <= 0;
            bclk8x3 <= 0;
        end
        else
            if(buad3_count == ( (SYS_CLK/8)/(BAUD3*8)/2 ) ) begin
                buad3_count <= 0;
                bclk8x3 <= ~bclk8x3;
            end
            else
                buad3_count <= buad3_count + 1;
                
          
    //final tx output i.e. bclk_counter[2] is 8x slower than main             
    always_ff @(posedge bclk8x or negedge rst)
        if(!rst)
            bclk_counter <= 3'b000;
        else
            bclk_counter <= bclk_counter+1;  
     
    assign bclk =  bclk_counter[2];           
    always_comb
        case(sel_baud)
            2'b00: begin
                bclk8x = bclk8x0;
            end  
            2'b01: begin
                bclk8x = bclk8x1;
            end  
            2'b10: begin
                bclk8x = bclk8x2;
            end  
            2'b11: begin
                bclk8x = bclk8x3;
            end  
        endcase             
endmodule
