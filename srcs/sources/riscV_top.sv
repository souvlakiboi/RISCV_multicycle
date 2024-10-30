module riscv_top (
    // Global Signals
    input  logic        clk, 
    input  logic        reset, 

    // Buttons
    input  logic        run,
    input  logic        load,
    
//    // Debug: Hex Display
//    output logic [7:0]  hex_seg_left,
//    output logic [3:0]  hex_grid_left,
//    output logic [7:0]  hex_seg_right,
//    output logic [3:0]  hex_grid_right,
    
    // AXI Master signals
    // Address Write (AW) channel
    output logic        M_AXI_AWVALID,  // Write address valid 
    input  logic        M_AXI_AWREADY,  // Write address ready 
    output logic [31:0] M_AXI_AWADDR,   // Write address data
    output logic [2:0]  M_AXI_AWPROT,   // Write address protection information

    // Write Data (W) channel 
    output logic        M_AXI_WVALID,   // Write data valid 
    input  logic        M_AXI_WREADY,   // Write data ready 
    output logic [31:0] M_AXI_WDATA,    // Write data
    output logic [3:0]  M_AXI_WSTRB,    // Write strobe (byte enables)

    // Write Response (B) channel 
    input  logic        M_AXI_BVALID,   // Write response valid 
    output logic        M_AXI_BREADY,   // Write response ready 
    input  logic [1:0]  M_AXI_BRESP,    // Write response response information

    // Address Read (AR) channel 
    output logic        M_AXI_ARVALID,  // Read address valid 
    input  logic        M_AXI_ARREADY,  // Read address ready 
    output logic [31:0] M_AXI_ARADDR,   // Read address data
    output logic [2:0]  M_AXI_ARPROT,   // Read address protection information

    // Read Data (R) channel 
    input  logic        M_AXI_RVALID,   // Read data valid 
    output logic        M_AXI_RREADY,   // Read data ready 
    input  logic [31:0] M_AXI_RDATA,    // Read data
    input  logic [1:0]  M_AXI_RRESP     // Read response information
);

    // CPU control signals
    logic load_done;
    logic cpu_reset;

    // Instrucion Memory Interface Signals
    logic [31:0] instr_mem_addr, instr_mem_data;       // Instr. Read/Write Data
    logic [9:0]  instr_addr_trunc;                      // 10-bit Truncated Instruction Address
    
    // Data Memory Interface Signals
    logic [9:0]  data_addr_trunc;                      // 10-bit Truncated Data Address
    logic [31:0] mem_rd_data;
    
    // CPU Interface Signals
    logic [31:0] data_mem_addr;                        // 32-bit Data Memory Address
    logic [31:0] data_mem_rd_data, data_mem_wr_data;   // Data Memory Read/Write Data
    logic        data_mem_wr_en;                       // Data Memory Write Enable
    logic mem_func;                                    // A Load/Store operation is performed
    
    // AXI control signal
    logic axi_op;
    logic data_mem_rd_en;                              // Load (read) is performed
    assign data_mem_rd_en = (mem_func) && (!data_mem_wr_en);
    
    // AXI Read output
    logic [31:0] axi_rd_data;

    // Instruction loader signals
    logic [9:0]  instr_load_addr;
    logic [31:0] instr_load_data;

    // Truncate addresses to align with memory's 10-bit addresses (depth of 1024)
    assign instr_addr_trunc = instr_mem_addr[11:2]; // Instruction Read: Effectively Dividing by 4 to access 32-bit word
    assign data_addr_trunc = data_mem_addr[11:2];    // Data Read/Write
    
    // Assign data to be read by CPU 
    assign data_mem_rd_data = axi_op ? axi_rd_data : mem_rd_data;

    // Instantiate the RISC-V core
    riscv_core cpu (
        .clk                (clk),
        .reset              (cpu_reset),
        .instr_mem_addr     (instr_mem_addr),
        .instr_mem_rd_data  (instr_mem_data),
        .data_mem_addr      (data_mem_addr),      
        .data_mem_wr_data   (data_mem_wr_data),
        .data_mem_wr_en     (data_mem_wr_en),
        .data_mem_rd_data   (data_mem_rd_data), 
        .mem_func           (mem_func)
    );
    
    // Instantiate the instruction memory
    blk_mem_gen_0 instr_memory (
        .addra  (instr_load_addr),
        .clka   (clk),
        .dina   (instr_load_data),
        .wea    (instr_mem_wr_en),

        .addrb  (instr_addr_trunc),
        .clkb   (clk),
        .doutb  (instr_mem_data)
    );
    
    // Instantiate the data memory
    blk_mem_gen_1 data_memory (
        .addra  (data_addr_trunc),
        .clka   (clk),
        .dina   (data_mem_wr_data),          
        .wea    (data_mem_wr_en && !axi_op),
        .douta  (mem_rd_data)
    );

    // Instantiate the instruction loader
    instruction_loader loader (
        .clk              (clk),
        .reset            (reset),
        .load_enable      (load), 
        .instr_mem_addr   (instr_load_addr),
        .instr_mem_wr_en  (instr_mem_wr_en),
        .instr_mem_data   (instr_load_data),
        .load_done        (load_done)
    );
    
    // Instantiate the reset handler
    reset_handler reset_hander (
        .clk           (clk),
        .reset         (reset),
        .run           (run),
        .load_done     (load_done),
        .cpu_reset     (cpu_reset)
    );
    
    //  Instantiate the AXI Master Interface
    axi_master axi (
        .clk                (clk),
        .reset              (reset),
        
        .cpu_mem_addr       (data_mem_addr),     // input from cpu
        .cpu_wr_data        (data_mem_wr_data),  // input from cpu
        .cpu_wr_en          (data_mem_wr_en),    // input from cpu
        .cpu_rd_en          (data_mem_rd_en),    // input from cpu
        .axi_rd_data        (axi_rd_data),       // output from AXI
        
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
        .M_AXI_RRESP        (M_AXI_RRESP),
        
        .axi_op              (axi_op)
    );

endmodule
