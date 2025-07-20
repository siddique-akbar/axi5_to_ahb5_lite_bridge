module rx_ma #(parameter DATA_WIDTH = 8)(
    input logic bclk8x, rst, rx_data,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic rx_status, data_correct
    );
    
    typedef enum logic [1:0] {S0, S1, S2, S3} statetype;
    statetype rx_state, rx_nextstate;
    logic rx_statusnext, data_correct_next;
    //S0 idle mode
    //S1 start bit mode
    //S2 Data transmit state
    //S3 stop bit
    
    logic [7:0] RHR, RHR_next;
    logic [9:0] RSR, RSR_next;
    logic [2:0] sample_counter, sample_counter_next;
    logic [3:0] bit_count, bit_count_next;
    assign data_out = RHR;
    always_ff @(posedge bclk8x or negedge rst)
        if (!rst) begin
          rx_state <= S0;
          rx_status <= 1'b0;
          RSR <= 10'b1111111111;
          RHR <= 8'hff;
          sample_counter <= 3'd0;
          bit_count <= 4'h0;
          data_correct <= 1'b0;
        end
        else begin
            rx_state <= rx_nextstate; 
            rx_status <= rx_statusnext;
            RHR <= RHR_next;
            RSR <= RSR_next;
            sample_counter <= sample_counter_next;
            bit_count <= bit_count_next;
            data_correct <= data_correct_next;
        end
        
    //next state and output are calculated here. mealy fsm machine
    always_comb begin
        rx_nextstate = rx_state; 
        sample_counter_next = sample_counter;
        RHR_next = RHR;
        RSR_next = RSR;
        rx_statusnext = rx_status;
        bit_count_next = bit_count;
        data_correct_next = data_correct;
        case (rx_state)
            S0:
                if (~rx_data) begin   //the rx line is not idle
                    rx_nextstate = S1;
                    rx_statusnext = 1'b1; //display that rx is now busy onwared.
//                    RSR_next = {rx_data, RSR[8:0]}; //we copy it in first cycle of bclk8x in the bit
                    bit_count_next = 4'h0; //reset this for the next complete transaction
                    data_correct_next = 1'b0;  //invalidate as we are going to receive a complete byte
                end
                else begin
                    rx_statusnext = 1'b0;
                    RSR_next = 10'b1111111111;
                    bit_count_next = 4'h0;
                end
                    
            S1:   //start bit status
                begin
                    if(sample_counter == 3'b100) begin
                        if(~rx_data) begin
                            RSR_next = {rx_data, RSR[9:1]};
                            sample_counter_next = sample_counter+1;
                        end
                        else begin
                            sample_counter_next = 3'b000;
                            rx_statusnext = 1'b0;
                            rx_nextstate = S0;
                        end
                       end
                    else if(sample_counter == 3'b111) begin
                        sample_counter_next = sample_counter+1;
                        rx_nextstate = S2;
                        end
                    else
                     sample_counter_next = sample_counter+1;
                end
            S2:    //Data state
              if(bit_count != 4'h8) begin
              //////////////
                if(sample_counter == 3'b100) begin
//                        if(~rx_data) begin
                  RSR_next = {rx_data, RSR[9:1]};
                  sample_counter_next = sample_counter+1;
                  end
                else if(sample_counter == 3'b111) begin
                  sample_counter_next = sample_counter+1;
                  bit_count_next = bit_count+1;
                  end
                else
                  sample_counter_next = sample_counter+1;
                ///////////////
              end
              else begin
                rx_nextstate = S3;
                sample_counter_next = 3'b000;
              end
                
            S3: begin
                    if(sample_counter == 3'b100) begin
                        if(rx_data) begin
                            RSR_next = {rx_data, RSR[9:1]};
                            sample_counter_next = sample_counter+1;
                        end
                        else begin
                            sample_counter_next = 3'b000;
                            rx_statusnext = 1'b0;
                            rx_nextstate = S0;
                        end
                       end
                    else if(sample_counter == 3'b111) begin
                        sample_counter_next = sample_counter+1;
                        rx_nextstate = S0;
                        RHR_next = RSR[8:1];
                        end
                    else
                     sample_counter_next = sample_counter+1;
                end
              
        endcase
    end      
    
endmodule