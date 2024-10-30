module cpu_to_io ( 	
    // Global Signals
    input  logic        clk, 
    input  logic        reset,
    
    // Memory Fields
    input  logic [9:0]  cpu_addr,       // Address
    input  logic        cpu_wr_ena,     // Write Enable
    input  logic [31:0] cpu_wdata,      // Data from instruction
    output logic [31:0] mem_wr_data,    // Data to be written to memory
    
    // Debug: Hex Display
    output logic [3:0]  hex_grid_left,
    output logic [7:0]  hex_seg_left,
    output logic [3:0]  hex_grid_right,
    output logic [7:0]  hex_seg_right
);
   
    // Binary value to be written to Hex Display
    logic [31:0] hex_display_d;
    logic [31:0] hex_display;

	// Data Write Logic
	always_comb begin 
	    hex_display_d = hex_display; 
        mem_wr_data = 32'h00000000; 
        // If Write Enable is Active
        if (cpu_wr_ena) begin
            // 1. Write to LEDs when address is 10'h3FF (= concatenation of 32'hFFFFFFFF)
            if (cpu_addr == 10'h3ff) begin
                hex_display_d = cpu_wdata;
            end else begin 
                mem_wr_data = cpu_wdata;
            end
        end
    end 
    
    // Update Hex Display
	always_ff @(posedge clk) begin
		if (reset) begin
			hex_display <= 32'd0;
        end else begin
            hex_display <= hex_display_d;
        end
    end
    
    // Instantiate Hex Drivers
    hex_driver hex_left (  
        .clk(clk), 
        .reset(reset), 
        .in({hex_display[31:28],
             hex_display[27:24], 
             hex_display[23:20], 
             hex_display[19:16]}),
             
        .hex_seg(hex_seg_left),
        .hex_grid(hex_grid_left)
    );
    
    hex_driver hex_right (  
        .clk(clk), 
        .reset(reset), 
        .in({hex_display[15:12],
             hex_display[11:8], 
             hex_display[7:4], 
             hex_display[3:0]}),
             
        .hex_seg(hex_seg_right),
        .hex_grid(hex_grid_right)
    );

endmodule