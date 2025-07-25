`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.07.2025 18:46:47
// Design Name: 
// Module Name: axi_read_fsm
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


module axi_read_fsm #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4,
    parameter USER_WIDTH = 1
    )
    (
    input  logic                        rfsm_ACLK,
    input  logic                        rfsm_ARESETn,  //assumed that this resetn is asynch assert and synch deasserted

    //================ WRITE ADDRESS CHANNEL =================//
    // input  logic                        rfsm_AWVALID,
    // output logic                        rfsm_AWREADY,
    // input  logic [ID_WIDTH-1:0]        rfsm_AWID,
    // input  logic [ADDR_WIDTH-1:0]       rfsm_AWADDR,  //it's multiplexed out is in upper module
    // input  logic [7:0]                  rfsm_AWLEN,
    // input  logic [2:0]                  rfsm_AWSIZE,
    // input  logic [1:0]                  rfsm_AWBURST,

    //================ WRITE DATA CHANNEL =================//
    // input   logic                       rfsm_WVALID,
    // output  logic                       rfsm_WREADY,
    // input   logic [DATA_WIDTH-1:0]      rfsm_WDATA, //it's multiplexed out is in upper module
    // input   logic [(DATA_WIDTH/8)-1:0]  rfsm_WSTRB, //WSTRB_Present = False is our decision
    // input   logic                       rfsm_WLAST,  //since AXI lite hence WLAST always 1
    // input   logic [USER_WIDTH-1:0]      rfsm_WUSER,

    //================ WRITE RESPONSE CHANNEL =================//
    // input   logic                       rfsm_BVALID,
    // input   logic                       rfsm_BREADY,
    // output  logic [ID_WIDTH-1:0]        rfsm_BID,  //singe transaction
    // output  logic [1:0]                 rfsm_BRESP,// this will be sent back to AXI master in top module
    // output  logic [USER_WIDTH-1:0]      rfsm_BUSER,

    //================ READ ADDRESS CHANNEL =================//
    input   logic                       rfsm_ARVALID,
    output  logic                       rfsm_ARREADY,  //it may be needed we will see
    // input   logic [ID_WIDTH-1:0]        rfsm_ARID,
    // input   logic [ADDR_WIDTH-1:0]      rfsm_ARADDR,
    // input   logic [7:0]                 rfsm_ARLEN,
    // input   logic [2:0]                 rfsm_ARSIZE,
    // input   logic [1:0]                 rfsm_ARBURST,
    // input   logic                       rfsm_ARLOCK,
    // input   logic [3:0]                 rfsm_ARCACHE,
    // input   logic [2:0]                 rfsm_ARPROT,
    // input   logic [3:0]                 rfsm_ARQOS,
    // input   logic [3:0]                 rfsm_ARREGION,
    // input   logic [USER_WIDTH-1:0]      rfsm_ARUSER,

    //================ READ DATA CHANNEL =================//
    output logic                        rfsm_RVALID,
    input  logic                        rfsm_RREADY,
    // output  logic [ID_WIDTH-1:0]        rfsm_RID,
    // output  logic [DATA_WIDTH-1:0]      rfsm_RDATA,
    // output  logic [1:0]                 rfsm_RRESP,
    // output  logic                       rfsm_RLAST,
    // output  logic [USER_WIDTH-1:0]      rfsm_RUSER

    // muxes to forward write data to AHB interface and making a copy of relevant data
    output logic                        AR_sel,
    output logic                        AR_en,
    output logic                        R_strt_ahb,
    output logic                        read_fsm_ahb_flag,

    output logic                        H_R_sel,
    output logic                        H_R_en,
    

    //=============== Signal needed from AHB interface directly ============
    // input logic                         rfsm_HRESP,
    input logic                         rfsm_HREADY,

    //========= AHB-lite write relevant driven controls/signals data etc =======//
    // output  logic                   m_HCLK,    //this is directly routed to ahb interface in top module
    // output  logic                   m_HRESETn, //this is directly routed to ahb interface in top module
    //=========== AHB-Lite Bus Signals from Master ==========//
    // output  logic [ADDR_WIDTH-1:0]  m_HADDR,        // will be dealt through mux in upper module
    // output logic [1:0]                 rfsm_HTRANS,       // will be driven in TOP module
    // output  logic                   m_HWRITE,       // Read/Write
    // output  logic [2:0]             m_HSIZE,        // will be hard-coded in upper
    // output  logic [2:0]             m_HBURST,       // will be hard-coded in upper
    // output  logic [3:0]             m_HPROT,        // not implemented
    // output  logic [DATA_WIDTH-1:0]  m_HWDATA,       // will be dealt through mux in upper module

    //=========== AHB-Lite Response Signals to Master =========//
    // input  logic                       m_HREADY,    // Slave ready
    // input  logic                       m_HRESP,        // Transfer response (always 0 for OKAY in AHB-Lite)
    // input logic [DATA_WIDTH-1:0]    m_HRDATA        // mux will route it in upper towards 
    input  logic                       write_fsm_ahb_flag
    );

    //ouput signals next value for interfaces
    logic rfsm_ARREADY_next;
    //internal logic signal next value
    logic read_fsm_ahb_flag, AR_sel, AR_en, R_strt_ahb, H_R_en, H_R_sel;

    logic rfsm_RVALID_next;


    typedef enum logic [2:0] {READY = 3'b000, R_AHB_DATA = 3'b001, 
                            R_AHB_WAIT = 3'b010, R_WRITE_WAIT = 3'b011, AXI_FORWARD = 3'b100} rfsm_state_t;
    rfsm_state_t rstate, next_rstate;

    always_ff @(posedge rfsm_ACLK or negedge rfsm_ARESETn) begin
    if (!rfsm_ARESETn) begin
        rstate <= READY;
        rfsm_RVALID <= 'b0;
        rfsm_ARREADY <= 'b0;
    end
    else begin
        rstate <= next_rstate;
        rfsm_RVALID <= rfsm_RVALID_next;
        rfsm_ARREADY <= rfsm_ARREADY_next;
    end
    end

    always_comb begin
        rfsm_RVALID_next = rfsm_RVALID;
        next_rstate = rstate;
        rfsm_ARREADY_next = rfsm_ARREADY;
        casez (rstate)
            READY: begin
                rfsm_RVALID_next = 1'b0;
                casez({rfsm_ARVALID, write_fsm_ahb_flag})
                    2'b10: begin
                        rfsm_ARREADY_next = 1'b1;
                        if(rfsm_HREADY) begin
                            next_rstate = R_AHB_DATA;
                            {read_fsm_ahb_flag, AR_sel, AR_en,  R_strt_ahb, H_R_en, H_R_sel} = 
                            {1'b1,              1'b0,   1'b0,   1'b1,        1'b0,   1'b0};
                        end
                        else begin
                            next_rstate = R_AHB_WAIT;
                            {read_fsm_ahb_flag, AR_sel, AR_en,  R_strt_ahb, H_R_en, H_R_sel} = 
                            {1'b1,              1'b0,   1'b1,   1'b1,        1'b0,   1'b0};
                        end
                    end
                    2'b11: begin
                        rfsm_ARREADY_next = 1'b1;
                        next_rstate = R_WRITE_WAIT;
                        {read_fsm_ahb_flag, AR_sel, AR_en,  R_strt_ahb, H_R_en, H_R_sel} =
                        {1'b0,              1'b0,   1'b1,   1'b0,        1'b0,   1'b0};
                    end
                    default: begin
                        next_rstate = READY;
                        rfsm_ARREADY_next = 1'b1;
                        rfsm_RVALID_next = 1'b0;
                        {read_fsm_ahb_flag, AR_sel, AR_en,  R_strt_ahb, H_R_en, H_R_sel} =
                        {1'b0,              1'b0,   1'b0,   1'b0,        1'b0,   1'b0};
                    end
                endcase
            end
            R_AHB_DATA: begin
                if(rfsm_HREADY) begin
                    next_rstate = AXI_FORWARD;
                    rfsm_RVALID_next = 1'b1;
                    {read_fsm_ahb_flag, AR_sel, AR_en,  R_strt_ahb, H_R_en, H_R_sel} =
                    {1'b1,              1'b0,   1'b0,   1'b0,        1'b1,   1'b0};
                end
                else begin
                    next_rstate = R_AHB_DATA;
                    rfsm_RVALID_next = 1'b0;
                    {read_fsm_ahb_flag, AR_sel, AR_en,  R_strt_ahb, H_R_en, H_R_sel} =
                    {1'b1,              1'b0,   1'b0,   1'b0,        1'b0,   1'b0};
                end
            end
            R_AHB_WAIT: begin
                {read_fsm_ahb_flag, AR_sel, AR_en,  R_strt_ahb, H_R_en, H_R_sel} = 
                {1'b1,              1'b1,   1'b0,   1'b1,        1'b0,   1'b0};
                if(rfsm_HREADY)
                    next_rstate = R_AHB_DATA;
                else
                    next_rstate = R_AHB_WAIT;
            end
            R_WRITE_WAIT: begin
                if(!write_fsm_ahb_flag) begin
                    if(rfsm_HREADY) begin
                        next_rstate = R_AHB_DATA;
                        {read_fsm_ahb_flag, AR_sel, AR_en,  R_strt_ahb, H_R_en, H_R_sel} = 
                        {1'b1,              1'b1,   1'b0,   1'b1,        1'b0,   1'b0};
                    end
                    else begin
                        next_rstate = R_AHB_WAIT;
                        {read_fsm_ahb_flag, AR_sel, AR_en,  R_strt_ahb, H_R_en, H_R_sel} = 
                        {1'b1,              1'b1,   1'b0,   1'b1,        1'b0,   1'b0};
                    end
                end
                else begin
                    next_rstate = R_WRITE_WAIT;
                    {read_fsm_ahb_flag, AR_sel, AR_en,  R_strt_ahb, H_R_en, H_R_sel} =
                    {1'b0,              1'b1,   1'b0,   1'b0,        1'b0,   1'b0};
                end
            end
            AXI_FORWARD: begin
                if(rfsm_RREADY) begin
                    next_rstate = READY;
                    rfsm_ARREADY_next = 1'b1;
                    rfsm_RVALID_next = 1'b0;
                    {read_fsm_ahb_flag, AR_sel, AR_en,  R_strt_ahb, H_R_en, H_R_sel} =
                    {1'b0,              1'b0,   1'b0,   1'b0,        1'b0,   1'b1};
                end
                else begin
                    next_rstate = AXI_FORWARD;
                    {read_fsm_ahb_flag, AR_sel, AR_en,  R_strt_ahb, H_R_en, H_R_sel} =
                    {1'b1,              1'b0,   1'b0,   1'b0,        1'b0,   1'b1};
                end
            end
            default: begin
                next_rstate = READY;
                rfsm_RVALID_next = 1'b0;
                rfsm_ARREADY_next = 1'b1;
                {read_fsm_ahb_flag, AR_sel, AR_en,  R_strt_ahb, H_R_en, H_R_sel} =
                {1'b0,              1'b0,   1'b0,   1'b0,        1'b0,   1'b0};
            end
        endcase
    end
endmodule
