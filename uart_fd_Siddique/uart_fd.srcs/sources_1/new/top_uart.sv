`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2025 12:09:04 PM
// Design Name: 
// Module Name: top_uart
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


module top_uart #(parameter DATA_WIDTH = 8)(
    input logic sys_clk, rx_data, rst, tx_en, rx_en,
    input logic [1:0] sel_baud,
    input logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic tx_status, tx_data, rx_status, data_correct
    );
    
    logic bclk, bclk8x, sys_clk_generator, baud_gen_en;
    logic [DATA_WIDTH-1:0] data_into_tx, data_outof_rx;
    logic rx_data1, rx_data2;
    
    always_ff @(posedge sys_clk or negedge rst) begin   //two flip flop synchronizer
        if (~rst) begin
          rx_data1 <= 1'b1;
          rx_data2 <= 1'b1;
        end 
        else begin
            rx_data1 <= rx_data;
            rx_data2 <=  rx_data1;
        end
      end
    
    rx_ma u1( .bclk8x, .rx_data(rx_data2), .rst(rx_en), .data_out, .rx_status, .data_correct);
    
    tx_ma u2(.bclk, .rst(tx_en), .data_in, .tx_status, .tx_data );

    assign sys_clk_generator = sys_clk & (tx_en | rx_en); //this is to save power and avoid free running baud generator.
    assign baud_gen_en = tx_en | rx_en;
    baud_generator u3( .sys_clk(sys_clk_generator), .rst(baud_gen_en), .sel_baud, .bclk, .bclk8x );
//    baud_generator u3( .sys_clk, .rst, .sel_baud, .bclk, .bclk8x );

endmodule
