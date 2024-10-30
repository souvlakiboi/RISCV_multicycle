//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Author: Alexander Mellas (UIUC '24)
// Purpose: The Decoder interprets the current instruction and tells the ALU what operation to perform
//////////////////////////////////////////////////////////////////////////////////////////////////////////
module decoder (
    input logic [31:0] instr,            // Instruction
    input logic [31:0] data_mem_rd_data, // Data Memory Data
    input logic [31:0] register_rd_data, // Register Read Data
   
    output logic [31:0] imm,        // Immediate
    output logic [31:0] immB,       // Branch Immediate
    output logic [31:0] immU,       // Load Upper Immediate
    output logic [31:0] immJ,       // Jump and Link Offset
    output logic [3:0] alu_op,      // Execute Operation
    output logic [4:0] rd,          // Destination Register 
    output logic [4:0] rs1,         // Source Register 1
    output logic [4:0] rs2,         // Source Register 2
    output logic [31:0] load_value, // Formatted Value for Data Memory Load
    output logic [31:0] store_value // Formatted Value for Data Memory Storage
);
    // Internal Signals
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [11:0] imm12;
    logic [19:0] imm20;
    logic [6:0] imm7;
    logic [4:0] imm5;
    
    // Assign instruction fields
    assign opcode   = instr[6:0];
    assign rd       = instr[11:7];
    assign funct3   = instr[14:12];
    assign rs1      = instr[19:15];
    assign rs2      = instr[24:20];
    assign funct7   = instr[31:25];
    assign imm12    = instr[31:20];
    assign imm20    = instr[31:12];
    assign imm7     = instr[31:25];
    assign imm5     = instr[11:7];
    
    // ALU operation control logic
    always_comb begin
        case (opcode)
            7'b0010011: begin // I-type instructions (Immediate & Register)
                imm = {{20{imm12[11]}}, imm12};
                immB = 32'd0;
                immU = 32'd0;
                immJ = 32'd0;
                case (funct3)
                    3'b000: alu_op = 4'b0000; // ADDI
                    3'b010: alu_op = 4'b0011; // SLTI 
                    3'b011: alu_op = 4'b0100; // SLTIU
                    3'b100: alu_op = 4'b0101; // XORI
                    3'b110: alu_op = 4'b1000; // ORI
                    3'b111: alu_op = 4'b1001; // ANDI
                    3'b001: alu_op = 4'b0010; // SLLI
                    3'b101: alu_op = (funct7[5] == 1'b0) ? 4'b0110 : 4'b0111; // SRLI or SRAI
                    default: alu_op = 4'b0000;
                endcase
            end
            7'b0110011: begin // R-type instructions (Register & Register)
                imm = 32'd0;
                immB = 32'd0;
                immU = 32'd0;
                immJ = 32'd0;
                case (funct3)
                    3'b000: alu_op = (funct7[5] == 1'b0) ? 4'b0000 : 4'b0001; // ADD or SUB
                    3'b001: alu_op = 4'b0010; // SLL
                    3'b010: alu_op = 4'b0011; // SLT
                    3'b011: alu_op = 4'b0100; // SLTU
                    3'b100: alu_op = 4'b0101; // XOR
                    3'b101: alu_op = (funct7[5] == 1'b0) ? 4'b0110 : 4'b0111; // SRL or SRA
                    3'b110: alu_op = 4'b1000; // OR
                    3'b111: alu_op = 4'b1001; // AND
                    default: alu_op = 4'b0000;
                endcase
            end
            7'b0000011: begin // Load
                alu_op = 4'd0;
                imm = {{20{imm12[11]}}, imm12};
                immB = 32'd0;
                immU = 32'd0;
                immJ = 32'd0;
            end
            7'b0100011: begin // Store
                alu_op = 4'd0;
                imm = {{20{imm7[6]}}, imm7, imm5};
                immB = 32'd0;
                immU = 32'd0;
                immJ = 32'd0;
            end
            7'b1100011: begin // Branch
                imm = 32'd0;
                immB = {{19{instr[31]}} ,instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
                immU = 32'd0;
                immJ = 32'd0;
                case (funct3)
                    3'b000: alu_op = 4'b0000; // Branch Equals
                    3'b001: alu_op = 4'b0001; // Branch Not Equals
                    3'b100: alu_op = 4'b0010; // Branch Less Than (Signed)
                    3'b101: alu_op = 4'b0011; // Branch Greater Than (Signed)
                    3'b110: alu_op = 4'b0100; // Branch Less Than (Unsigned)
                    3'b111: alu_op = 4'b0101; // Branch Greater Than (Unsigned)
                    default: alu_op = 4'b0000;
                 endcase
            end
            7'b1101111: begin // Jump and Link (JAL)
                alu_op = 4'd0;
                imm = 32'd0;
                immB = 32'd0;
                immU = 32'd0;
                immJ = {{11{instr[31]}}, instr[31] ,instr[19:12], instr[20], instr[30:21], 1'b0};
            end
            7'b1100111: begin // Jump and Link Register (JALR)
                alu_op = 4'd0;
                imm = {{20{imm12[11]}}, imm12};
                immB = 32'd0;
                immU = 32'd0;
                immJ = 32'd0;
            end
            7'b0110111: begin // Load Upper Immediate (LUI)
                alu_op = 4'd0;
                imm = 32'd0;
                immB = 32'd0;
                immU = {imm20, 12'b0};
                immJ = 32'd0;
            end
            7'b0010111: begin // Add Upper Immediate to PC (AUIPC)
                alu_op = 4'd0;
                imm = 32'd0;
                immB = 32'd0;
                immU = {imm20, 12'b0};
                immJ = 32'd0;
            end
            
            default: begin // Default Case
                alu_op = 4'd0;
                imm = 32'd0; 
                immB = 32'd0; 
                immU = 32'd0;
                immJ = 32'd0;
            end
        endcase 
    end
    
    // Format Load and Store Data
    always_comb begin
        // Extract the relevant parts from the read data for loads
        logic signed [15:0] data_halfword;
        logic signed [7:0]  data_byte;
        
        // Prepare store values
        logic signed [15:0] store_halfword;
        logic signed [7:0]  store_byte;
    
        data_halfword = data_mem_rd_data[15:0];
        data_byte     = data_mem_rd_data[7:0];
    
        store_halfword = register_rd_data[15:0];
        store_byte     = register_rd_data[7:0];
    
        // Handle load operations based on funct3
        case (funct3)
            3'b010: begin                                     // LW (Load Word)
                load_value  = data_mem_rd_data;               
            end
            3'b001: begin                                     // LH (Load Halfword, Sign-Extended)
                load_value  = $signed(data_halfword); 
            end
            3'b101: begin                                     // LHU (Load Halfword, Zero-Extended)
                load_value  = {16'b0, data_halfword}; 
            end
            3'b000: begin                                     // LB  (Load Byte, Sign-Extended)
                load_value  = $signed(data_byte);  
            end
            3'b100: begin                                     // LBU (Load Byte, Zero-Extended)
                load_value  = {24'b0, data_byte};     
            end
            default: load_value = 32'b0;                      // Default case
        endcase
    
        // Handle store operations based on funct3
        case (funct3)
            3'b010: begin                                     // SW (Store Word)
                store_value = register_rd_data;               
            end
            3'b001: begin                                     // SH (Store Halfword)
                store_value = {16'b0, store_halfword};        
            end
            3'b000: begin                                     // SB (Store Byte)
                store_value = {24'b0, store_byte};            
            end
            default: store_value = 32'b0;
        endcase
    end

   
endmodule