`timescale 1ns / 1ps

module axi5_to_ahb5_lite_TOP_TB;
  // Parameters
  parameter ADDR_WIDTH = 32;
  parameter DATA_WIDTH = 32;
  parameter ID_WIDTH   = 4;
  parameter USER_WIDTH = 1;

  // DUT signals
  logic s_ACLK;
  logic s_ARESETn;

  // AXI write signals
  logic s_AWVALID, s_AWREADY;
  logic [ID_WIDTH-1:0] s_AWID;
  logic [ADDR_WIDTH-1:0] s_AWADDR;
  logic [7:0] s_AWLEN;
  logic [2:0] s_AWSIZE;
  logic [1:0] s_AWBURST;

  logic s_WVALID, s_WREADY;
  logic [DATA_WIDTH-1:0] s_WDATA;

  logic s_BVALID, s_BREADY;
  logic [ID_WIDTH-1:0] s_BID;
  logic [1:0] s_BRESP;
  logic [USER_WIDTH-1:0] s_BUSER;

  logic s_ARVALID, s_ARREADY;
  logic [ID_WIDTH-1:0] s_ARID;
  logic [ADDR_WIDTH-1:0] s_ARADDR;
  logic [7:0] s_ARLEN;
  logic [2:0] s_ARSIZE;
  logic [1:0] s_ARBURST;
  logic s_ARLOCK;
  logic [3:0] s_ARCACHE;
  logic [2:0] s_ARPROT;
  logic [3:0] s_ARQOS;
  logic [3:0] s_ARREGION;
  logic [USER_WIDTH-1:0] s_ARUSER;

  logic s_RVALID, s_RREADY;
  logic [ID_WIDTH-1:0] s_RID;
  logic [DATA_WIDTH-1:0] s_RDATA;
  logic [1:0] s_RRESP;
  logic s_RLAST;
  logic [USER_WIDTH-1:0] s_RUSER;

  // AHB side
  logic m_HCLK, m_HRESETn;
  logic [ADDR_WIDTH-1:0] m_HADDR;
  logic [1:0] m_HTRANS;
  logic m_HWRITE;
  logic [2:0] m_HSIZE;
  logic [2:0] m_HBURST;
  logic [3:0] m_HPROT;
  logic [DATA_WIDTH-1:0] m_HWDATA;
  logic m_HREADY;
  logic m_HRESP;
  logic [DATA_WIDTH-1:0] m_HRDATA;

  // Instantiate DUT
  axi5_to_ahb5_lite_TOP #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .ID_WIDTH(ID_WIDTH),
    .USER_WIDTH(USER_WIDTH)
  ) dut (
    .* // All signals are mapped above
  );

    // Clock generation
  always #5 s_ACLK = ~s_ACLK;

  initial begin
    s_ACLK = 0;
    s_ARESETn = 0;
    m_HREADY = 1;     // AHB slave is always ready
    m_HRESP = 0;
    m_HRDATA = 32'hA5A5A5A5;

    // Reset
    #20;
    s_ARESETn = 1;
    #10
    
    // Default signals
    s_ARVALID = 0;
    s_BREADY = 0;
    s_RREADY = 0;

    // Start single beat AXI write transaction
    s_AWID    = 4'h1;
    s_AWADDR  = 32'h1000_0000;
    s_AWLEN   = 8'd0;        // Single transfer
    s_AWSIZE  = 3'b010;      // 4 bytes
    s_AWBURST = 2'b01;       // INCR
    s_WDATA   = 32'hDEADBEEF;
//============AW only followed by W transaction start here===========
    s_AWVALID = 1;
    s_WVALID  = 0;
    s_BREADY  = 1;

    wait (s_AWREADY == 1); #10;
    s_AWVALID = 0;

    s_WVALID = 1;
    wait (s_WREADY == 1); #10;
    s_WVALID = 0;

    // Wait for BVALID
    wait (s_BVALID == 1); #10;

    if (s_BRESP == 2'b00)
      $display("AXI Write Response OKAY.");
    else
      $display("AXI Write Response ERROR: BRESP = %b", s_BRESP);
//============AW only followed by W transaction end here===========
    #5;
//============W only followed by AW transaction start here===========
    s_AWVALID = 0;
    s_WVALID  = 1;
    s_BREADY  = 1;

    wait (s_WREADY == 1); #10;
    s_WVALID = 0;

    s_AWVALID = 1;
    wait (s_AWREADY == 1); #10;
    s_AWVALID = 0;

    // Wait for BVALID
    wait (s_BVALID == 1); #10;

    if (s_BRESP == 2'b00)
      $display("AXI Write Response OKAY.");
    else
      $display("AXI Write Response ERROR: BRESP = %b", s_BRESP);
//============W only followed by AW transaction end here ===========    
    #5;
//============AW + W in same cycle transaction start here ===========
    s_AWVALID = 1;
    s_WVALID  = 1;
    s_BREADY  = 1;
    $display("herer");
    wait (s_WREADY == 1); //#10;
    s_WVALID = 0;
    s_BREADY = 0;
    $display("here1");
    // s_AWVALID = 1;
    wait (s_AWREADY == 1); #10;
    s_AWVALID = 0;

    // Wait for BVALID
    $display("here2");
    wait (s_BVALID == 1); #30;
    s_BREADY = 1;
    if (s_BRESP == 2'b00)
      $display("AXI Write Response OKAY.");
    else
      $display("AXI Write Response ERROR: BRESP = %b", s_BRESP);
//============AW + W in same cycle transaction end here ===========
    #50;
    $finish;
  end

endmodule