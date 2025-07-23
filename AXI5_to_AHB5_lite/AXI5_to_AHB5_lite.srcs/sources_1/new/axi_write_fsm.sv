`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.07.2025 18:46:25
// Design Name: 
// Module Name: axi_write_fsm
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


module axi_write_fsm #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4,
    parameter USER_WIDTH = 1
    )
    (
    input  logic                        wfsm_ACLK,
    input  logic                        wfsm_ARESETn,  //assumed that this resetn is asynch assert and synch deasserted

    //================ WRITE ADDRESS CHANNEL =================//
    input  logic                        wfsm_AWVALID,
    output logic                        wfsm_AWREADY,
    // input  logic [ID_WIDTH-1:0]        wfsm_AWID,
    // input  logic [ADDR_WIDTH-1:0]       wfsm_AWADDR,  //it's multiplexed out is in upper module
    // input  logic [7:0]                  wfsm_AWLEN,
    // input  logic [2:0]                  wfsm_AWSIZE,
    // input  logic [1:0]                  wfsm_AWBURST,

    //================ WRITE DATA CHANNEL =================//
    input   logic                       wfsm_WVALID,
    output  logic                       wfsm_WREADY,
    // input   logic [DATA_WIDTH-1:0]      wfsm_WDATA, //it's multiplexed out is in upper module
    // input   logic [(DATA_WIDTH/8)-1:0]  wfsm_WSTRB, //WSTRB_Present = False is our decision
    // input   logic                       wfsm_WLAST,  //since AXI lite hence WLAST always 1
    // input   logic [USER_WIDTH-1:0]      wfsm_WUSER,

    //================ WRITE RESPONSE CHANNEL =================//
    output  logic                       wfsm_BVALID,
    input   logic                       wfsm_BREADY,
    // output  logic [ID_WIDTH-1:0]        wfsm_BID,  //singe transaction
    output  logic [1:0]                 wfsm_BRESP,// this will be sent back to AXI master in top module
    // output  logic [USER_WIDTH-1:0]      wfsm_BUSER,

    //================ READ ADDRESS CHANNEL =================//
    input   logic                       wfsm_ARVALID,
    // input   logic                       wfsm_ARREADY,  //it may be needed we will see
    // input   logic [ID_WIDTH-1:0]        wfsm_ARID,
    // input   logic [ADDR_WIDTH-1:0]      wfsm_ARADDR,
    // input   logic [7:0]                 wfsm_ARLEN,
    // input   logic [2:0]                 wfsm_ARSIZE,
    // input   logic [1:0]                 wfsm_ARBURST,
    // input   logic                       wfsm_ARLOCK,
    // input   logic [3:0]                 wfsm_ARCACHE,
    // input   logic [2:0]                 wfsm_ARPROT,
    // input   logic [3:0]                 wfsm_ARQOS,
    // input   logic [3:0]                 wfsm_ARREGION,
    // input   logic [USER_WIDTH-1:0]      wfsm_ARUSER,

    //================ READ DATA CHANNEL =================//
    input  logic                        wfsm_RVALID,
    input   logic                       wfsm_RREADY,
    // output  logic [ID_WIDTH-1:0]        wfsm_RID,
    // output  logic [DATA_WIDTH-1:0]      wfsm_RDATA,
    // output  logic [1:0]                 wfsm_RRESP,
    // output  logic                       wfsm_RLAST,
    // output  logic [USER_WIDTH-1:0]      wfsm_RUSER

    // muxes to forward write data to AHB interface and making a copy of relevant data
    output logic                        AW_sel,
    output logic                        AW_en,
    output logic                        W_sel,
    output logic                        W_en,
    output logic                        W_strt_ahb,
    output logic                        write_fsm_ahb_flag,

    output logic                        H_sel,
    output logic                        H_en,
    

    //=============== Signal needed from AHB interface directly ============
    // input logic                         wfsm_HRESP,
    input logic                         wfsm_HREADY,

    //========= AHB-lite write relevant driven controls/signals data etc =======//
    // output  logic                   m_HCLK,    //this is directly routed to ahb interface in top module
    // output  logic                   m_HRESETn, //this is directly routed to ahb interface in top module
    //=========== AHB-Lite Bus Signals from Master ==========//
    // output  logic [ADDR_WIDTH-1:0]  m_HADDR,        // will be dealt through mux in upper module
    // output logic [1:0]                 wfsm_HTRANS,       // will be driven in TOP module
    // output  logic                   m_HWRITE,       // Read/Write
    // output  logic [2:0]             m_HSIZE,        // will be hard-coded in upper
    // output  logic [2:0]             m_HBURST,       // will be hard-coded in upper
    // output  logic [3:0]             m_HPROT,        // not implemented
    // output  logic [DATA_WIDTH-1:0]  m_HWDATA,       // will be dealt through mux in upper module

    //=========== AHB-Lite Response Signals to Master =========//
    // input  logic                       m_HREADY,    // Slave ready
    // input  logic                       m_HRESP,        // Transfer response (always 0 for OKAY in AHB-Lite)
    // input logic [DATA_WIDTH-1:0]    m_HRDATA        // mux will route it in upper towards 
    input  logic                       read_fsm_ahb_flag
    );

    //ouput signals next value for interfaces
    logic wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next;
    //internal logic signal next value
    logic write_fsm_ahb_flag_next, AW_sel_next, W_sel_next, AW_en_next, W_en_next, W_strt_ahb_next;
    // BRESP logic completed
    // assign wfsm_BRESP = {1'b0, wfsm_HRESP, 1'b0};   // see page 66 of IHI0022K_amba_axi_protocol_spec.pdf
    // assign wfsm_HTRANS = {W_strt_ahb, 1'b0};  //HTRANS required in AHB ADDRESS phase. will also be needed to read fsm so top will decide

    typedef enum logic [2:0] {READY = 3'b000, READ_PRIORITY = 3'b001, 
                            W_AHB_ADDR = 3'b010, AXI_B_WAIT = 3'b011, AW_ONLY = 3'b100, W_ONLY = 3'b101,
                            AXI_NR_AHB_CHECK = 3'b110, READ_ACTIVE = 3'b111} wfsm_state_t;
    wfsm_state_t state, next_state;
    always_ff @(posedge wfsm_ACLK or negedge wfsm_ARESETn) begin
    if (!wfsm_ARESETn) begin
        state <= READY;
        {wfsm_AWREADY, wfsm_WREADY, wfsm_BVALID} <= 'b0;
        // {AW_sel, W_sel, AW_en, W_en, W_strt_ahb} <=  'b0;
        // write_fsm_ahb_flag <= 'b0;
    end
    else begin
        state <= next_state;
        {wfsm_AWREADY, wfsm_WREADY, wfsm_BVALID} <= 
        {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next};

        // {AW_sel, W_sel, AW_en, W_en, W_strt_ahb} <=  \
        // {AW_sel_next, W_sel_next, AW_en_next, W_en_next, W_strt_ahb_next};
        // write_fsm_ahb_flag <= write_fsm_ahb_flag_next;
    end
    end

    always_comb begin
    // next_state = state;  // default
    {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
    {wfsm_AWREADY, wfsm_WREADY, wfsm_BVALID};

    // {AW_sel_next, W_sel_next, AW_en_next, W_en_next, W_strt_ahb_next} = \
    // {AW_sel, W_sel, AW_en, W_en, W_strt_ahb};

    casez (state)
        READY: begin
            casez ({wfsm_AWVALID, wfsm_WVALID, wfsm_ARVALID})
                3'b111: begin
                    next_state = READ_PRIORITY;
                    {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                    {1'b0,              1'b0,             1'b0            }; 

                    {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                    {1'b0,   1'b0,  1'b1,  1'b1, 1'b0,        1'b0,              1'b0,  1'b0};                    
                end
                3'b110: begin   //start of address phase
                    if(wfsm_HREADY)
                        next_state = W_AHB_ADDR;
                    else
                        next_state = AXI_NR_AHB_CHECK; //this state show that ahb slave didn't accept NONSEQ in previous cycle
                    {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                    {1'b0,              1'b0,             1'b0            }; 

                    {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                    {1'b0,   1'b0,  1'b1,  1'b1, 1'b1,        1'b1,              1'b0,  1'b0};
                end
                3'b100, 3'b101: begin
                    next_state = AW_ONLY;
                    {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                    {1'b0,              1'b1,             1'b0            }; 

                    {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                    {1'b0,   1'b0,  1'b1,  1'b0, 1'b0,        1'b0,              1'b0,  1'b0};
                end
                3'b010, 3'b011: begin
                    next_state = W_ONLY;
                    {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                    {1'b1,              1'b0,             1'b0            }; 

                    {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                    {1'b0,   1'b0,  1'b0,  1'b1, 1'b0,        1'b0,              1'b0,  1'b0};
                end
                3'b001: begin
                    next_state = READ_ACTIVE;
                    {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                    {1'b1,              1'b1,             1'b0            }; 

                    {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                    {1'b0,   1'b0,  1'b0,  1'b0, 1'b0,        1'b0,              1'b0,  1'b0};
                end
                default: begin
                    next_state = READY;
                    {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                    {1'b1,              1'b1,             1'b0            };

                    {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                    {1'b0,   1'b0,  1'b0,  1'b0, 1'b0,        1'b0,              1'b0,  1'b0};
                end
            endcase
        end
        READ_ACTIVE:
            casez({wfsm_AWVALID, wfsm_WVALID, read_fsm_ahb_flag})
                3'b110: begin   //start of address phase
                    if(wfsm_HREADY)
                        next_state = W_AHB_ADDR;
                    else
                        next_state = AXI_NR_AHB_CHECK; //this state show that ahb slave didn't accept NONSEQ in previous cycle
                    {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                    {1'b0,              1'b0,             1'b0            }; 

                    {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                    {1'b0,   1'b0,  1'b1,  1'b1, 1'b1,        1'b1,              1'b0,  1'b0};
                end
                3'b111: begin
                    next_state = READ_PRIORITY;
                    {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                    {1'b0,              1'b0,             1'b0            }; 

                    {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                    {1'b0,   1'b0,  1'b1,  1'b1, 1'b0,        1'b0,              1'b0,  1'b0};                    
                end
                3'b000: begin
                    next_state = READY;
                    {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                    {1'b1,              1'b1,             1'b0            }; 

                    {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                    {1'b0,   1'b0,  1'b0,  1'b0, 1'b0,        1'b0,              1'b0,  1'b0};
                end
                3'b101: begin
                    next_state = AW_ONLY;
                    {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                    {1'b1,              1'b1,             1'b0            }; 

                    {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                    {1'b0,   1'b0,  1'b1,  1'b0, 1'b0,        1'b0,              1'b0,  1'b0};
                end
            endcase
        READ_PRIORITY:
            if(wfsm_RREADY & wfsm_RVALID) begin
                if(wfsm_HREADY)
                    next_state = W_AHB_ADDR;
                else
                    next_state = AXI_NR_AHB_CHECK; //this state show that ahb slave didn't accept NONSEQ in previous cycle
                {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                {1'b0,              1'b0,             1'b0            }; 

                {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                {1'b1,   1'b1,  1'b0,  1'b0, 1'b1,        1'b1,              1'b0,  1'b0};
            end
            else begin
                next_state = READ_PRIORITY;
                {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                {1'b1,   1'b1,  1'b0,  1'b0, 1'b0,        1'b0,              1'b0,  1'b0};
            end
        W_AHB_ADDR:  //this is for sure AHB data phase of the previous write transaction address phase
            if(wfsm_HREADY) begin
                    next_state = AXI_B_WAIT;
                    {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                    {1'b0,              1'b0,             1'b1            };

                    {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                    {1'b0,   1'b1,  1'b0,  1'b0, 1'b0,        1'b1,              1'b0,  1'b1};
            end
            else begin
                next_state = W_AHB_ADDR;
                {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                {1'b1,   1'b1,  1'b0,  1'b0, 1'b0,        1'b1,              1'b0,  1'b0};
            end
        AXI_B_WAIT:
            if(wfsm_BREADY) begin
                next_state = READY;
                {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                {1'b1,              1'b1,             1'b0            }; 

                {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                {1'b0,   1'b0,  1'b0,  1'b0, 1'b0,        1'b1,              1'b1,  1'b0};
            end
            else begin
                next_state = AXI_B_WAIT;
                {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                {1'b1,   1'b1,  1'b0,  1'b0, 1'b0,        1'b1,              1'b1,  1'b0};
            end
        AW_ONLY:
            casez ({read_fsm_ahb_flag, wfsm_WVALID, wfsm_ARVALID})
              3'b010: begin
                if(wfsm_HREADY)
                    next_state = W_AHB_ADDR;
                else
                    next_state = AXI_NR_AHB_CHECK; //this state show that ahb slave didn't accept NONSEQ in previous cycle
                {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                {1'b0,              1'b0,             1'b0            }; 

                {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                {1'b1,   1'b0,  1'b0,  1'b1, 1'b1,        1'b1,               1'b0,  1'b0};
              end
              3'b011, 3'b11x: begin
                next_state = READ_PRIORITY;
                {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                {1'b0,              1'b0,             1'b0            }; 

                {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                {1'b1,   1'b1,  1'b0,  1'b1, 1'b0,        1'b0,               1'b0,  1'b0};
              end
              default: begin
                next_state = AW_ONLY;
                {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                {1'b0,              1'b1,             1'b0            }; 

                {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                {1'b1,   1'b1,  1'b0,  1'b0, 1'b0,        1'b0,               1'b0,  1'b0};
              end
            endcase
        W_ONLY:
            casez ({read_fsm_ahb_flag, wfsm_AWVALID, wfsm_ARVALID})
              3'b010: begin
                if(wfsm_HREADY)
                        next_state = W_AHB_ADDR;
                    else
                        next_state = AXI_NR_AHB_CHECK; //this state show that ahb slave didn't accept NONSEQ in previous cycle
                {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                {1'b0,              1'b0,             1'b0            }; 

                {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                {1'b0,   1'b1,  1'b1,  1'b0, 1'b1,        1'b1,              1'b0,  1'b0};
              end
              3'b011, 3'b110, 3'b111: begin
                next_state = READ_PRIORITY;
                {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                {1'b0,              1'b0,             1'b0            }; 

                {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                {1'b1,   1'b1,  1'b1,  1'b0, 1'b0,        1'b0,               1'b0,  1'b0};
              end
              default: begin
                next_state = W_ONLY;
                {wfsm_AWREADY_next, wfsm_WREADY_next, wfsm_BVALID_next} = 
                {1'b1,              1'b0,             1'b0            }; 

                {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} = 
                {1'b1,   1'b1,  1'b0,  1'b0, 1'b0,        1'b0,               1'b0,  1'b0};
              end
            endcase
        AXI_NR_AHB_CHECK: begin   //It was found that the previous cycle HREADY was low when Address phase with AHB started
            if(wfsm_HREADY)
                next_state = W_AHB_ADDR;
            {AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, H_sel, H_en} =
            {1'b1,   1'b1,  1'b0,  1'b0, 1'b1,        1'b1,              1'b0,  1'b0};
        end
    endcase
end
endmodule
