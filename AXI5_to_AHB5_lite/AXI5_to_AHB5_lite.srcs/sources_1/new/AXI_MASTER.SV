`timescale 1ns / 1ps

module AHB_MASTER #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input logic hclk,
    input logic hresetn,
    input logic [DATA_WIDTH-1:0] hrdata,
    input logic hready,
    input logic hresp,
    
    output logic [ADDR_WIDTH-1:0] haddr,
    output logic [2:0] hburst,
    output logic [1:0] htrans,
    output logic [DATA_WIDTH-1:0] hwdata,
    output logic hwrite,
    output logic [2:0] hsize,
    output logic [3:0] hprot,
    
    input logic start_trans,
    input logic [ADDR_WIDTH-1:0] start_addr,
    input logic write_en,
    input logic [2:0] size,
    input logic [2:0] burst_type,
    input logic [3:0] prot,
    input logic [DATA_WIDTH-1:0] wdata,
    
    output logic [DATA_WIDTH-1:0] rdata,
    output logic trans_done,
    output logic trans_error
);

    typedef enum logic [2:0] {
        IDLE    = 3'b000,
        ADDR    = 3'b001,
        DATA    = 3'b010,
        ERROR1  = 3'b011,
        ERROR2  = 3'b100
    } state_t;

    state_t state, next_state;
    logic [ADDR_WIDTH-1:0] addr_reg;
    logic [DATA_WIDTH-1:0] wdata_reg;
    logic [2:0] burst_reg;
    logic [2:0] size_reg;
    logic [4:0] burst_count;
    logic write_en_reg;
    logic addr_incr;
    logic [ADDR_WIDTH-1:0] next_addr;
    logic [2:0] mapped_hburst;
    logic next_trans_done;
    logic [DATA_WIDTH-1:0] rdata_reg;

    // Burst type mapping
    always_comb begin
        case (burst_type)
            3'b000: mapped_hburst = 3'b000; // SINGLE
            3'b001: mapped_hburst = 3'b001; // INCR
            3'b010: mapped_hburst = 3'b010; // WRAP4
            3'b011: mapped_hburst = 3'b011; // INCR4
            3'b100: mapped_hburst = 3'b100; // WRAP8
            3'b101: mapped_hburst = 3'b101; // INCR8
            3'b110: mapped_hburst = 3'b110; // WRAP16
            3'b111: mapped_hburst = 3'b111; // INCR16
            default: mapped_hburst = 3'b000;
        endcase
    end

    // Address calculation
    always_comb begin
        logic [31:0] wrap_boundary, incr_size;
        
        case (size_reg)
            3'b000: incr_size = 32'h1;      // Byte
            3'b001: incr_size = 32'h2;      // Halfword
            3'b010: incr_size = 32'h4;      // Word
            3'b011: incr_size = 32'h8;      // Doubleword
            3'b100: incr_size = 32'h10;     // 4-word line
            default: incr_size = 32'h4;      // Default word
        endcase
        
        case (burst_reg)
            next_addr = (addr_reg & ~(wrap_boundary - 1)) | 
        end
    end

    // Sequential logic
            wdata_reg <= '0;
            size_reg <= '0;
            burst_count <= '0;
            write_en_reg <= 1'b0;
            state <= next_state;
            trans_done <= next_trans_done;
            trans_error <= 1'b0;
            // Capture read data at end of successful data phase
                rdata_reg <= hrdata;
            
            if (state == IDLE && start_trans) begin
                addr_reg <= start_addr;
                burst_reg <= mapped_hburst;
                size_reg <= size;
                
                // Set burst count based on type
                case (burst_type)
                    3'b000: burst_count <= 5'd1;    // SINGLE
                    3'b001: burst_count <= 5'd16;   // INCR (max)
                    3'b100, 3'b101: burst_count <= 5'd8;   // WRAP8/INCR8
                    default: burst_count <= 5'd1;
                endcase
            // Update for next transfer in burst
            else if ((state == ADDR || state == DATA) && hready && !hresp) begin
                if (addr_incr) begin
                    addr_reg <= next_addr;
                    wdata_reg <= wdata;  // Update wdata for next write
                
                if (burst_count > 0) begin
                    burst_count <= burst_count - 1;
                end
            
        hwrite = write_en_reg;
                end
            DATA: begin
                        htrans = 2'b00;
                    end else begin
                        if (burst_count <= 1) begin
                            next_trans_done = 1'b1;
                            htrans = 2'b11;
                            addr_incr = 1'b1;
                    end
            end
            
            ERROR1: begin
            end
            
            ERROR2: begin
                htrans = 2'b00;
                next_state = IDLE;
                next_trans_done = 1'b1;
            end
            
            default: next_state = IDLE;
        endcase
    end

endmodule                next_state = ERROR2;
                htrans = 2'b00;
                end
                        end
                            next_state = ADDR;
                        end else begin
                            next_state = IDLE;
                        next_state = ERROR1;
                    if (hresp) begin
                if (hready) begin
            
            end
                    htrans = (burst_count > 1) ? 2'b11 : 2'b10;
                end else begin
                    end
                            addr_incr = 1'b1;
                        end
                            htrans = 2'b11;  // SEQ
        hsize = size_reg;
                        if (burst_count > 1) begin
        hprot = prot;
                        next_state = DATA;
            
                    end else begin
                        next_state = ERROR1;
                        htrans = 2'b00;
            ADDR: begin
                if (hready) begin
                    if (hresp) begin
        hwdata = wdata_reg;
        rdata = rdata_reg;
            end
                    next_state = ADDR;
                    htrans = 2'b10;  // NONSEQ
                end
        addr_incr = 1'b0;
        next_trans_done = 1'b0;
        
        case (state)
            IDLE: begin
                if (start_trans) begin
            // Error handling
                trans_error <= 1'b1;
            end
        end
    end

    // State machine and outputs
    always_comb begin
        next_state = state;
        haddr = addr_reg;
        htrans = 2'b00;  // IDLE default
        hburst = burst_reg;
            if (state == ERROR2) begin
            end
                end
            end 
                    3'b110, 3'b111: burst_count <= 5'd16;  // WRAP16/INCR16
                    3'b010, 3'b011: burst_count <= 5'd4;   // WRAP4/INCR4
                write_en_reg <= write_en;
                wdata_reg <= wdata;
            // Start new transaction
            end
            if (state == DATA && hready && !hresp && !write_en_reg) begin
            
        end else begin
            trans_error <= 1'b0;
            trans_done <= 1'b0;
            burst_reg <= '0;
            rdata_reg <= '0;
        if (!hresetn) begin
            addr_reg <= '0;
            state <= IDLE;
    always_ff @(posedge hclk or negedge hresetn) begin
            next_addr = addr_reg + incr_size;
        end else begin
                       ((addr_reg + incr_size) & (wrap_boundary - 1));
        if (burst_reg inside {3'b010, 3'b100, 3'b110}) begin
            3'b010: wrap_boundary = incr_size * 4;  // WRAP4
            3'b100: wrap_boundary = incr_size * 8;  // WRAP8
            3'b110: wrap_boundary = incr_size * 16; // WRAP16
            default: wrap_boundary = 32'hFFFFFFFF;  // No wrap
        endcase
