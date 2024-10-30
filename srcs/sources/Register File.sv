//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Author: Alexander Mellas (UIUC '24)
// Purpose: The Register File instantiates a register array for storing temporary values
//////////////////////////////////////////////////////////////////////////////////////////////////////////
module reg_file(
    input logic clk,                  // Clock signal
    input logic reset,                // Reset signal
    
    input logic [4:0] rd_addr_1,      // Read address 1
    input logic [4:0] rd_addr_2,      // Read address 2
    output logic [31:0] rd_data_1,    // Read data 1
    output logic [31:0] rd_data_2,    // Read data 2
    
    input logic [4:0] wr_addr,        // Write address (assuming 5 bits for 32 registers)
    input logic [31:0] wr_data,       // Write data
    input logic wr_en                 // Write enable signal
);

    // Register array
    logic [31:0] reg_array [31:0];
    
    // Combinational read operations
    assign rd_data_1 = (rd_addr_1 == 5'b00000) ? 32'h0 : reg_array[rd_addr_1]; // Read data from the register array at rd_addr_1, output zero if x0
    assign rd_data_2 = (rd_addr_2 == 5'b00000) ? 32'h0 : reg_array[rd_addr_2]; // Read data from the register array at rd_addr_2, output zero if x0

    // Sequential write and reset operations
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers to 0, including x0 for safety, though it will be constantly zero due to assignment
            for (int i = 0; i < 32; i++) begin
                reg_array[i] <= 32'h0;
            end
        end else begin
            if (wr_en && (wr_addr != 5'b00000)) begin
                reg_array[wr_addr] <= wr_data; // Write data to the register array at wr_addr, avoid writing to x0
            end
        end
    end
endmodule



