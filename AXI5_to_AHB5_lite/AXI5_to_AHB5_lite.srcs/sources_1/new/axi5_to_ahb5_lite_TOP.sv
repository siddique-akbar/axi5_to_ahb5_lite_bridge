`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.07.2025 18:49:50
// Design Name: 
// Module Name: axi5_to_ahb5_lite_TOP
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


module axi5_to_ahb5_lite_TOP#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4,
    parameter USER_WIDTH = 1
    )
    (
    // ********** AXI interface signals start****************************************************//
    input  logic                        s_ACLK,
    input  logic                        s_ARESETn,  //assumed that this resetn is asynch assert and synch deasserted

    //================ WRITE ADDRESS CHANNEL =================//
    input  logic                        s_AWVALID,  
    output logic                        s_AWREADY,
    input  logic [ID_WIDTH-1:0]         s_AWID,
    input  logic [ADDR_WIDTH-1:0]       s_AWADDR,  //it's multiplexed out is in upper module
    input  logic [7:0]                  s_AWLEN,
    input  logic [2:0]                  s_AWSIZE,
    input  logic [1:0]                  s_AWBURST,

    //================ WRITE DATA CHANNEL =================//
    input   logic                       s_WVALID,
    output  logic                       s_WREADY,
    input   logic [DATA_WIDTH-1:0]      s_WDATA, //it's multiplexed out is in upper module
    // input   logic [(DATA_WIDTH/8)-1:0]  s_WSTRB, //WSTRB_Present = False is our decision
    // input   logic                       s_WLAST,  //since AXI lite hence WLAST always 1
    // input   logic [USER_WIDTH-1:0]      s_WUSER,

    //================ WRITE RESPONSE CHANNEL =================//
    output  logic                       s_BVALID,
    input   logic                       s_BREADY,
    output  logic [ID_WIDTH-1:0]        s_BID,  //singe transaction
    output  logic [1:0]                 s_BRESP,
    output  logic [USER_WIDTH-1:0]      s_BUSER,

    //================ READ ADDRESS CHANNEL =================//
    input   logic                       s_ARVALID,
    output  logic                       s_ARREADY,  //it may be needed we will see
    input   logic [ID_WIDTH-1:0]        s_ARID,
    input   logic [ADDR_WIDTH-1:0]      s_ARADDR,
    input   logic [7:0]                 s_ARLEN,
    input   logic [2:0]                 s_ARSIZE,
    input   logic [1:0]                 s_ARBURST,
    input   logic                       s_ARLOCK,
    input   logic [3:0]                 s_ARCACHE,
    input   logic [2:0]                 s_ARPROT,
    input   logic [3:0]                 s_ARQOS,
    input   logic [3:0]                 s_ARREGION,
    input   logic [USER_WIDTH-1:0]      s_ARUSER,

    //================ READ DATA CHANNEL =================//
    output logic                        s_RVALID,
    input  logic                        s_RREADY,
    output logic [ID_WIDTH-1:0]         s_RID,
    output logic [DATA_WIDTH-1:0]       s_RDATA,
    output logic [1:0]                  s_RRESP,
    output logic                        s_RLAST,
    output logic [USER_WIDTH-1:0]       s_RUSER,
    // ********** AXI interface signals end here****************************************************//

    // ********** AHB interface signals start here****************************************************//
    output  logic                       m_HCLK,
    output  logic                       m_HRESETn,

    //=========== AHB-Lite Bus Signals from Master ==========//
    output  logic [ADDR_WIDTH-1:0]      m_HADDR,        // Address
    output  logic [1:0]                 m_HTRANS,       // Transfer type
    output  logic                       m_HWRITE,       // Read/Write
    output  logic [2:0]                 m_HSIZE,        // Transfer size
    output  logic [2:0]                 m_HBURST,       // Burst type
    output  logic [3:0]                 m_HPROT,        // Protection control
    output  logic [DATA_WIDTH-1:0]      m_HWDATA,       // Write data

    //=========== AHB-Lite Response Signals to Master =========//
    input logic                         m_HREADY,    // Slave ready
    input logic                         m_HRESP,        // Transfer response (always 0 for OKAY in AHB-Lite)
    input logic [DATA_WIDTH-1:0]        m_HRDATA        // Read data
    // ********** AXI interface signals end here****************************************************//

    );
    //write fsm relevant top level hardware nets
    logic AW_sel, W_sel, AW_en, W_en, W_strt_ahb, write_fsm_ahb_flag, read_fsm_ahb_flag, H_sel, H_en;
    // logic wfsm_HRESP;
    logic [ADDR_WIDTH-1:0] AWADDR_copy, AWADDR_final;
    logic [DATA_WIDTH-1:0] WDATA_copy;
    logic hresp1;
    axi_write_fsm wfsm_u1(.wfsm_ACLK(s_ACLK), .wfsm_ARESETn(s_ARESETn), .wfsm_AWVALID(s_AWVALID), 
    .wfsm_AWREADY(s_AWREADY), .wfsm_WVALID(s_WVALID), .wfsm_WREADY(s_WREADY), .wfsm_BVALID(s_BVALID), 
    .wfsm_BREADY(s_BREADY), .wfsm_ARVALID(s_ARVALID), .wfsm_RVALID(s_RVALID), .wfsm_RREADY(s_RREADY), .AW_sel, 
    .AW_en, .W_sel, .W_en, .W_strt_ahb, .write_fsm_ahb_flag, .H_sel, .H_en, 
    .wfsm_HREADY(m_HREADY), .read_fsm_ahb_flag );

    assign m_HCLK    = s_ACLK;
    assign m_HRESETn = s_ARESETn;

    always_ff @(posedge s_ACLK or negedge s_ARESETn)
        if(!s_ARESETn)
            AWADDR_copy <= 'b0;
        else if(AW_en)
            AWADDR_copy <= s_AWADDR;
        else
            AWADDR_copy <= AWADDR_copy;

    always_ff @(posedge s_ACLK or negedge s_ARESETn)
        if(!s_ARESETn)
            WDATA_copy <= 'b0;
        else if(W_en)
            WDATA_copy <= s_WDATA;
        else
            WDATA_copy <= WDATA_copy;
    assign m_HWDATA     = W_sel ? WDATA_copy : s_WDATA;
    assign AWADDR_final = AW_sel ? AWADDR_copy : s_AWADDR;
    
    always_ff @(posedge s_ACLK or negedge s_ARESETn)
        if(!s_ARESETn)
            hresp1 <= 'b0;
        else if(H_en)
            hresp1 <= m_HRESP;
        else
            hresp1 <= hresp1;
    assign s_BRESP = H_sel ? {1'b0, hresp1, 1'b0} : {1'b0, m_HRESP, 1'b0};

    //======= Read transaction relevant logic ========
    logic AR_sel, AR_en, R_strt_ahb, H_R_sel, H_R_en, hresp2;
    logic [ADDR_WIDTH-1:0] ARADDR_copy, ARADDR_final;
    logic [DATA_WIDTH-1:0] HRDATA_copy, HRDATA_final;
    axi_read_fsm rfsm_u2(.rfsm_ACLK(s_ACLK), .rfsm_ARESETn(s_ARESETn), .rfsm_ARVALID(s_ARVALID), 
    .rfsm_ARREADY(s_ARREADY), .rfsm_RVALID(s_RVALID), .rfsm_RREADY(s_RREADY), .AR_sel, .AR_en, 
    .R_strt_ahb, .read_fsm_ahb_flag, .H_R_sel, .H_R_en, .rfsm_HREADY(m_HREADY), .write_fsm_ahb_flag
    );

    always_ff @(posedge s_ACLK or negedge s_ARESETn)
        if(!s_ARESETn)
            ARADDR_copy <= 'b0;
        else if(AR_en)
            ARADDR_copy <= s_ARADDR;
        else
            ARADDR_copy <= ARADDR_copy;
    assign ARADDR_final = AR_sel ? ARADDR_copy : s_ARADDR;

    always_ff @(posedge s_ACLK or negedge s_ARESETn)
        if(!s_ARESETn)
            hresp2 <= 'b0;
        else if(H_R_en)
            hresp2 <= m_HRESP;
        else
            hresp2 <= hresp2;
    assign s_RRESP = H_R_sel ? {1'b0, hresp1, 1'b0} : {1'b0, m_HRESP, 1'b0};

    always_ff @(posedge s_ACLK or negedge s_ARESETn)
        if(!s_ARESETn)
            HRDATA_copy <= 'b0;
        else if(H_R_en)
            HRDATA_copy <= m_HRDATA;
        else
            HRDATA_copy <= HRDATA_copy;
    assign s_RDATA = H_R_sel ? HRDATA_copy : m_HRDATA;

//common driven by write and read fsm toward ahb
    assign m_HTRANS = {W_strt_ahb|R_strt_ahb, 1'b0};
    assign m_HWRITE = (!R_strt_ahb) & W_strt_ahb;

    assign m_HADDR = m_HWRITE ? AWADDR_final : ARADDR_final;

endmodule
