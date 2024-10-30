module axi_master (
    // Global Signals
    input  logic        clk,
    input  logic        reset,
    
    // CPU Memory Interface
    input  logic [31:0] cpu_mem_addr,     // Read/Write Address
    input  logic [31:0] cpu_wr_data,      // Write Data
    input  logic        cpu_wr_en,        // Write Enable
    input  logic        cpu_rd_en,        // Read Enable
    output logic [31:0] axi_rd_data,      // Read From AXI 
    
    // AXI Master Interface
    // Address Write (AW) channel
    output logic        M_AXI_AWVALID,
    input  logic        M_AXI_AWREADY,
    output logic [31:0] M_AXI_AWADDR,
    output logic [2:0]  M_AXI_AWPROT,
    
    // Write Data (W) channel
    output logic        M_AXI_WVALID,
    input  logic        M_AXI_WREADY,
    output logic [31:0] M_AXI_WDATA,
    output logic [3:0]  M_AXI_WSTRB,
    
    // Write Response (B) channel
    input  logic        M_AXI_BVALID,
    output logic        M_AXI_BREADY,
    input  logic [1:0]  M_AXI_BRESP,
    
    // Address Read (AR) channel
    output logic        M_AXI_ARVALID,
    input  logic        M_AXI_ARREADY,
    output logic [31:0] M_AXI_ARADDR,
    output logic [2:0]  M_AXI_ARPROT,
    
    // Read Data (R) channel
    input  logic        M_AXI_RVALID,
    output logic        M_AXI_RREADY,
    input  logic [31:0] M_AXI_RDATA,
    input  logic [1:0]  M_AXI_RRESP,
    
    output logic        axi_op           // Select Signal for writing to memory or AXI
);
    // Memory-Mapped Peripheral Address Space
    localparam GPIO_ADDR = 32'h000003FF;
    
    // Read/Write response
    logic [1:0] read_response;
    logic [1:0] write_response;

    // Internal signals for handshaking
    // Write
    logic write_handshake_done;
    // Read
    logic read_handshake_done;

    // Address Decode Logic (Are we performing a read/write via AXI?)
    always_comb begin
        axi_op = (cpu_mem_addr == GPIO_ADDR) && (cpu_wr_en || cpu_rd_en);
    end

    // AXI Write Logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            M_AXI_AWVALID <= 1'b0;
            M_AXI_WVALID <= 1'b0;
            M_AXI_BREADY <= 1'b0;
            write_handshake_done <= 1'b0;
        end else begin
            // Address Write Channel
            if (axi_op && cpu_wr_en && !write_handshake_done) begin
                // The Master puts an address on the Write Address channel and data on the Write data channel.
                M_AXI_AWADDR <= 32'h0; // Write Addr: Base register of GPIO
                M_AXI_WDATA <= cpu_wr_data;
                // At the same time it asserts AWVALID and WVALID indicating the address and data on the respective channels is valid. 
                M_AXI_AWVALID <= 1'b1;
                M_AXI_WVALID <= 1'b1;
                // BREADY is also asserted by the Master, indicating it is ready to receive a response.
                M_AXI_BREADY <= 1'b1;
                // Other Signals
                M_AXI_AWPROT <= 3'b000;
                M_AXI_WSTRB <= 4'b1111;  // Assume full word writes             
            end 
            // Deassert Address Write Valid
            if (M_AXI_AWREADY && M_AXI_AWVALID) begin
                M_AXI_AWVALID <= 1'b0;
            end 
            // Deassert Data Write Valid
            if (M_AXI_WREADY && M_AXI_WVALID) begin
                M_AXI_WVALID <= 1'b0;
            end 
            // Deassert Write Response Ready and Complete Handshake
            if (M_AXI_BVALID && M_AXI_BREADY) begin
                M_AXI_BREADY <= 1'b0;
                write_handshake_done <= 1'b1;
                write_response <= M_AXI_BRESP;
            end
            // Reset handshakes for next transaction
            if (write_handshake_done) begin
                write_handshake_done <= 1'b0;
            end
        end
    end

    // AXI Read Logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            M_AXI_ARVALID <= 1'b0;
            M_AXI_RREADY <= 1'b0;
            axi_rd_data <= 32'b0;
            read_handshake_done <= 1'b0;
            // Other Signals
            M_AXI_ARPROT <= 3'b000;
        end else begin
            // Address Read Channel
            if (axi_op && cpu_rd_en && !read_handshake_done) begin
                // The Master puts an address on the Read Address channel 
                M_AXI_ARADDR <= 32'h0; // Read Addr: Base register of GPIO
                // At the same time it asserts ARVALID and RREADY indicating the address is valid and that the master is ready to receive data from the slave.
                M_AXI_ARVALID <= 1'b1;
                M_AXI_RREADY <= 1'b1;
            end
            // Since both ARVALID and ARREADY are asserted, on the next rising clock edge the handshake occurs, after this the master and slave deassert ARVALID and the ARREADY, respectively.
            if (M_AXI_ARVALID && M_AXI_ARREADY) begin
                M_AXI_ARVALID <= 1'b0;
            end 
            // Since both RREADY and RVALID are asserted, the next rising clock edge completes the transaction. RREADY and RVALID can now be deasserted.
            if (M_AXI_RREADY && M_AXI_RVALID) begin
                //complete handshake
                axi_rd_data <= M_AXI_RDATA;
                read_response <= M_AXI_RRESP;
                read_handshake_done <= 1'b1;
                //deassert RREADY
                M_AXI_RREADY <= 1'b0; 
            end
            // Reset handshakes for next transaction
            if (read_handshake_done) begin
                read_handshake_done <= 1'b0;
            end
        end
    end

endmodule


