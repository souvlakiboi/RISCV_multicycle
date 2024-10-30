//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Author: Alexander Mellas (UIUC '24)
// Purpose: The PC Generator is responsible for updating the Program Counter (PC) with a latency for fetch.
//////////////////////////////////////////////////////////////////////////////////////////////////////////
module fetch (
    input logic clk,
    input logic reset,
    
    input logic [31:0] alu_result,     // ALU Result
    input logic [2:0] pc_sel,          // PC Select
    input logic [31:0] immB,           // Branch Immediate
    input logic [31:0] immJ,           // JAL offset
    input logic [31:0] instr_mem_in,   // Input from instruction memory
    input logic fetch_instr,           // Signal to perform fetch
    input logic update_pc,
    input logic mem_func,
    input logic mem_done,
    
    output logic [31:0] pc_reg,        // PC value
    output logic [31:0] pc_next,
    output logic [31:0] instr          // Output the instruction
);

    // Jump Target
    logic [31:0] jalr_target;
    assign jalr_target = alu_result & ~1; // Clears the least significant bit to 0

    // Update PC Logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_reg <= 32'd0; 
        end else begin
            if (update_pc) begin
                pc_reg <= pc_next;
            end else begin
                pc_reg <= pc_reg;
            end
        end
    end
    
   // Instruction update logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            instr <= 32'd0;          // Initialize instruction to 0 on reset
        end else begin
            if (fetch_instr) begin
                instr <= instr_mem_in; // Fetch the instruction from memory
            end else begin
                if (mem_func) begin
                    if (!mem_done) begin
                        // Retain current instruction if it's a memory read or write
                        instr <= instr;  
                    end else begin
                        instr <= 32'd0; 
                    end
                end else begin
                    // Output NOP (0) if not fetching or during non-memory access
                    instr <= 32'd0;   
                end
            end
        end
    end


    // Source for Program Counter (PC)
    localparam DEF   = 3'b000; // Default (PC = PC + 4)
    localparam BRA   = 3'b001; // Branch
    localparam JALR  = 3'b010; // Jump and Link Register 
    localparam JAL   = 3'b100; // Jump and Link

    // Determine the next value of the PC based on the selection signal
    always_comb begin
        case (pc_sel)
            DEF:  pc_next = pc_reg + 4;
            BRA:  pc_next = pc_reg + $signed(immB);
            JALR: pc_next = jalr_target;
            JAL:  pc_next = (pc_reg + $signed(immJ));
            default: pc_next = pc_reg + 4;
        endcase
    end

endmodule

