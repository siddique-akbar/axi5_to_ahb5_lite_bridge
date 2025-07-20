module tx_ma #(parameter DATA_WIDTH = 8)(
    input logic bclk, rst,
    input logic [DATA_WIDTH-1:0] data_in,
    output logic tx_status, tx_data
    );
    typedef enum logic [1:0] {S0, S1, S2, S3} statetype;
    statetype tx_state, tx_nextstate;
    logic tx_statuswire, tx_datawire;
    //S0 idle mode
    //S1 start bit mode
    //S2 Data transmit state
    //S3 stop bit
    logic [3:0] counter_tx;
    logic [7:0] THR, THR_next;
    logic [9:0] TSR, TSR_next;

    assign tx_data = TSR[0];
    //sequential logic 
    always_ff @(posedge bclk or negedge rst)
        if (!rst) begin
          tx_state <= S0;
          counter_tx <= 4'h0;
          tx_status <= 1'b0;
          TSR <= 10'b1111111111;
          THR <= 8'hff;
        end
        else begin
            tx_state <= tx_nextstate; 
            counter_tx <= counter_tx+1;
            tx_status <= tx_statuswire;
            THR <= THR_next;
            TSR <= TSR_next;
        end 

    //next state and output are calculated here. mealy fsm machine
    always_comb begin
        tx_nextstate = tx_state;
        case (tx_state)
            S0:
                if (rst==1'b1) begin
                    tx_nextstate = S2;
                    tx_statuswire = 1'b1; //display that tx is now busy onwared.
                    THR_next = data_in;
//                    TSR_next = 10'b1111111111;
                    TSR_next = {1'b1, data_in, 1'b0};
                end
                else begin
                    tx_nextstate = S0;
                    tx_statuswire = 1'b0;
                end
            S1:
                begin
//                    TSR_next = {1'b1, THR_next, 1'b0}; //here at bclk negedge will output start bit
                    tx_nextstate = S2;
                end
            S2:
                begin
                    if(counter_tx == 8)
                        tx_nextstate = S3;
                    TSR_next = {1'b1, TSR[9:1]};   //1 append at left is to make sure that start bit at end of transaction is 1'b1 i.e. idle
                end
            S3: begin
//                tx_statuswire = 1'b0;
                TSR_next = {1'b1, TSR[9:1]};
            end

        endcase
        
    end

    endmodule