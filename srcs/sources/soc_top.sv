module soc_top(
    // Global Signals
    input  logic        clk, 
    input  logic        reset, 

    // Buttons
    input  logic        run,
    input  logic        load,
    
    // Debug: Hex Display
    output logic [3:0]  hex_grid_left,
    output logic [7:0]  hex_seg_left,
    output logic [3:0]  hex_grid_right,
    output logic [7:0]  hex_seg_right
    
    );
    
    logic [31:0] gpio_out;
    
     // Internal Signals for AXI Master Interface
    // Address Write (AW) channel
    logic M_AXI_AWVALID;
    logic M_AXI_AWREADY;
    logic [31:0] M_AXI_AWADDR;
    logic [2:0] M_AXI_AWPROT;

    // Write Data (W) channel
    logic M_AXI_WVALID;
    logic M_AXI_WREADY;
    logic [31:0] M_AXI_WDATA;
    logic [3:0] M_AXI_WSTRB;

    // Write Response (B) channel
    logic M_AXI_BVALID;
    logic M_AXI_BREADY;
    logic [1:0] M_AXI_BRESP;

    // Address Read (AR) channel
    logic M_AXI_ARVALID;
    logic M_AXI_ARREADY;
    logic [31:0] M_AXI_ARADDR;
    logic [2:0] M_AXI_ARPROT;

    // Read Data (R) channel
    logic M_AXI_RVALID;
    logic M_AXI_RREADY;
    logic [31:0] M_AXI_RDATA;
    logic [1:0] M_AXI_RRESP;
    
    
    // Instantiate the RISC-V CPU
    riscv_top microcontroller (
        .clk                (clk),
        .reset              (reset),
        .run                (run),
        .load               (load),
        
        .M_AXI_AWVALID      (M_AXI_AWVALID),
        .M_AXI_AWREADY      (M_AXI_AWREADY),
        .M_AXI_AWADDR       (M_AXI_AWADDR),
        .M_AXI_AWPROT       (M_AXI_AWPROT),

        .M_AXI_WVALID       (M_AXI_WVALID),
        .M_AXI_WREADY       (M_AXI_WREADY),
        .M_AXI_WDATA        (M_AXI_WDATA),
        .M_AXI_WSTRB        (M_AXI_WSTRB),

        .M_AXI_BVALID       (M_AXI_BVALID),
        .M_AXI_BREADY       (M_AXI_BREADY),
        .M_AXI_BRESP        (M_AXI_BRESP),

        .M_AXI_ARVALID      (M_AXI_ARVALID),
        .M_AXI_ARREADY      (M_AXI_ARREADY),
        .M_AXI_ARADDR       (M_AXI_ARADDR),
        .M_AXI_ARPROT       (M_AXI_ARPROT),

        .M_AXI_RVALID       (M_AXI_RVALID),
        .M_AXI_RREADY       (M_AXI_RREADY),
        .M_AXI_RDATA        (M_AXI_RDATA),
        .M_AXI_RRESP        (M_AXI_RRESP)
               
    );
    
    // Instantiate GPIO
    axi_gpio_0 gpio (
        .s_axi_aclk         (clk),
        .s_axi_aresetn      (~reset),
        
        // AXI Interface
        .s_axi_araddr       (M_AXI_ARADDR[8:0]),
        .s_axi_arready      (M_AXI_ARREADY),
        .s_axi_arvalid      (M_AXI_ARVALID),
        .s_axi_awaddr       (M_AXI_AWADDR[8:0]),
        .s_axi_awready      (M_AXI_AWREADY),
        .s_axi_awvalid      (M_AXI_AWVALID),
        .s_axi_bready       (M_AXI_BREADY),
        .s_axi_bresp        (M_AXI_BRESP),
        .s_axi_bvalid       (M_AXI_BVALID),
        .s_axi_rdata        (M_AXI_RDATA),
        .s_axi_rready       (M_AXI_RREADY),
        .s_axi_rresp        (M_AXI_RRESP),
        .s_axi_rvalid       (M_AXI_RVALID),
        .s_axi_wdata        (M_AXI_WDATA),
        .s_axi_wready       (M_AXI_WREADY),
        .s_axi_wstrb        (M_AXI_WSTRB),
        .s_axi_wvalid       (M_AXI_WVALID),
        
        // GPIO Signals
        .gpio_io_o          (gpio_out)  // Connect GPIO output to an external or internal signal
    );
    
    // Hex Seg: View Output of GPIO Module
    hex_driver hex_left (  
        .clk(clk), 
        .reset(reset), 
        .in({gpio_out[31:28],
             gpio_out[27:24], 
             gpio_out[23:20], 
             gpio_out[19:16]}),
             
        .hex_seg(hex_seg_left),
        .hex_grid(hex_grid_left)
    );
    
    hex_driver hex_right (  
        .clk(clk), 
        .reset(reset), 
        .in({gpio_out[15:12],
             gpio_out[11:8], 
             gpio_out[7:4], 
             gpio_out[3:0]}),
             
        .hex_seg(hex_seg_right),
        .hex_grid(hex_grid_right)
    );
    
    
endmodule
