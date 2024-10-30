`timescale 1ns / 1ps

module gpio_tb;

// Parameters
localparam integer C_S_AXI_DATA_WIDTH = 32;
localparam integer C_S_AXI_ADDR_WIDTH = 9;

// AXI4Lite signals
reg S_AXI_ACLK;
reg S_AXI_ARESETN;
reg [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR;
reg S_AXI_AWVALID;
wire S_AXI_AWREADY;
reg [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA;
reg [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB;
reg S_AXI_WVALID;
wire S_AXI_WREADY;
wire [1 : 0] S_AXI_BRESP;
wire S_AXI_BVALID;
reg S_AXI_BREADY;
reg [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR;
reg S_AXI_ARVALID;
wire S_AXI_ARREADY;
wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA;
wire [1 : 0] S_AXI_RRESP;
wire S_AXI_RVALID;
reg S_AXI_RREADY;

// GPIO output
wire [31:0] gpio_io_o;

// Instantiate the AXI GPIO IP
axi_gpio_0 DUT (
    .s_axi_aclk(S_AXI_ACLK),
    .s_axi_aresetn(S_AXI_ARESETN),
    .s_axi_awaddr(S_AXI_AWADDR),
    .s_axi_awvalid(S_AXI_AWVALID),
    .s_axi_awready(S_AXI_AWREADY),
    .s_axi_wdata(S_AXI_WDATA),
    .s_axi_wstrb(S_AXI_WSTRB),
    .s_axi_wvalid(S_AXI_WVALID),
    .s_axi_wready(S_AXI_WREADY),
    .s_axi_bresp(S_AXI_BRESP),
    .s_axi_bvalid(S_AXI_BVALID),
    .s_axi_bready(S_AXI_BREADY),
    .s_axi_araddr(S_AXI_ARADDR),
    .s_axi_arvalid(S_AXI_ARVALID),
    .s_axi_arready(S_AXI_ARREADY),
    .s_axi_rdata(S_AXI_RDATA),
    .s_axi_rresp(S_AXI_RRESP),
    .s_axi_rvalid(S_AXI_RVALID),
    .s_axi_rready(S_AXI_RREADY),
    .gpio_io_o(gpio_io_o)
);

// Clock generation
initial begin
    S_AXI_ACLK = 0;
    forever #5 S_AXI_ACLK = ~S_AXI_ACLK; // 100 MHz clock
end

// Reset generation
initial begin
    S_AXI_ARESETN = 0;
    #100;
    S_AXI_ARESETN = 1;
end

// Test sequence
initial begin
    // Initialize signals
    S_AXI_AWADDR = 0;
    S_AXI_AWVALID = 0;
    S_AXI_WDATA = 0;
    S_AXI_WSTRB = 4'b1111;
    S_AXI_WVALID = 0;
    S_AXI_BREADY = 0;
    S_AXI_ARADDR = 0;
    S_AXI_ARVALID = 0;
    S_AXI_RREADY = 0;

    #200;

    // Write to GPIO
    @(posedge S_AXI_ACLK);
    S_AXI_AWADDR = 9'h0; // Address offset for GPIO data
    S_AXI_AWVALID = 1;
    S_AXI_WDATA = 32'hA5A5A5A5; // Data to write
    S_AXI_WVALID = 1;
    S_AXI_BREADY = 1;
    wait(S_AXI_BVALID);
    @(posedge S_AXI_ACLK);
    S_AXI_AWVALID = 0;
    S_AXI_WVALID = 0;

    // Read back GPIO
    @(posedge S_AXI_ACLK);
    S_AXI_ARADDR = 9'h04;
    S_AXI_ARVALID = 1;
    S_AXI_RREADY = 1;
    wait(S_AXI_RVALID);
    @(posedge S_AXI_ACLK);
    S_AXI_ARVALID = 0;
    S_AXI_RREADY = 0;
    
    // Finish the simulation
    $stop;
end

endmodule

