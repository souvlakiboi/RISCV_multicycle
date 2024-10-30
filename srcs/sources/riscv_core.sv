//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Author: Alexander Mellas (UIUC '24)
// Purpose: The Core of the RISC-V CPU encapsulates lower modules: fetch, decode, registers, control, ALU
//////////////////////////////////////////////////////////////////////////////////////////////////////////
module riscv_core (
    input logic clk,
    input logic reset,
    
    // Buttons & Switches 
    
    // Instruction Memory
    output logic [31:0] instr_mem_addr,
    input logic [31:0] instr_mem_rd_data,
    
    // Data Memory
    output logic [31:0] data_mem_addr,      
    output logic [31:0] data_mem_wr_data,
    output logic data_mem_wr_en,
    input logic [31:0] data_mem_rd_data,
    output logic mem_func
      
);
    ////////////////////// Internal Signals //////////////////////
    // Instruction Fields
    logic [31:0] instr;              // Instruction
    logic [6:0] opcode;              // Opcode
    logic [4:0] rd, rs1, rs2;        // Souce & Destination Registers
    logic [2:0] funct3;              // Funct3
    logic [6:0] funct7;              // Funct7
    
    logic [31:0] pc_reg;             // Current PC
    logic [31:0] pc_next;            // Next PC
    logic [31:0] reg_data_1;         // Register Output 1
    logic [31:0] reg_data_2;         // Register Output 2
    logic [31:0] imm;                // Immediate
    logic [31:0] alu_in_1, alu_in_2; // Execute Operands
    logic [3:0] alu_op;              // Execute Function
    logic [31:0] reg_write_data;     // Register Write Data
    logic reg_wr_en;                 // Register Write Enable
    logic imm_en;                    // Instruction involves use of Immediate
    logic [2:0] reg_wr_sel;          // Source of Reg Write Data (0: ALU, 1: Data Mem, 2: PC + 4)
    logic br_en;                     // Branch Enable
    logic [2:0] pc_sel;              // PC Select
    logic [31:0] immB;               // Branch Immediate
    logic [31:0] immU;               // Load Upper Immediate
    logic [31:0] immJ;               // JAL offset
    logic [31:0] alu_result;         // Execute Result
    logic [31:0] load_value;         // Formatted Load Data
    logic [31:0] store_value;        // Formatted Store Data
    
    logic update_pc;
    logic mem_done;
    /////////////////////////////////////////////////////////////
    
    ////////////////////// Comb. Connections ////////////////////
    assign opcode   = instr[6:0];      // Opcode
    
    assign data_mem_addr = alu_result;      // Data Memory Address 
    assign data_mem_wr_data = store_value;  // Data Memory Write Data 
    assign instr_mem_addr = pc_reg;         // Instr Memory Address
    
    // Multiplexor: "Execute Module" Operands
    // Determines if the operands are Register/Register OR Register/Immediate
    always_comb begin
        alu_in_1 = reg_data_1;
        case (imm_en)
            1'b0 : alu_in_2 = reg_data_2;
            1'b1 : alu_in_2 = imm;
            default : alu_in_2 = reg_data_2;
        endcase
    end
    
    // Multiplexor: "Register File" write data
    // The data to be written to our desired register
    localparam ALU  = 3'b000;   // ALU Result
    localparam MEM  = 3'b001;   // Data Memory (formatted)
    localparam PCO  = 3'b010;   // Current PC + 4 (JAL, JALR)
    localparam LUI  = 3'b011;   // U-Immediate (LUI)
    localparam AUIPC  = 3'b100; // U-Immediate + PC (AUIPC)
    
    always_comb begin
        case (reg_wr_sel)
            ALU: reg_write_data = alu_result;
            MEM: reg_write_data = load_value;
            PCO: reg_write_data = pc_reg + 4; 
            LUI: reg_write_data = immU;
            AUIPC: reg_write_data = pc_reg + immU;
            default: reg_write_data = alu_result;
        endcase
    end
    
    /////////////////////////////////////////////////////////////
    
    ////////////////// Module Instantiations ////////////////////
    // PC Generator: Provides current Program Counter (PC) value
    fetch pc_generator (
        .clk(clk),
        .reset(reset),
        .alu_result(alu_result),
        .immB(immB),
        .immJ(immJ),
        .pc_sel(pc_sel),
        .instr_mem_in(instr_mem_rd_data),
        .fetch_instr(fetch_instr),
        .update_pc(update_pc),
        .pc_reg(pc_reg),
        .pc_next(pc_next),
        .instr(instr),
        .mem_func(mem_func),
        .mem_done(mem_done)
    );
    
    // Controller: Produces control signals based on op-type
    controller control_unit (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .br_en(br_en),
        .imm_en(imm_en),
        .reg_wr_en(reg_wr_en), 
        .reg_wr_sel(reg_wr_sel),        
        .data_mem_wr_en(data_mem_wr_en),    
        .pc_sel(pc_sel),
        .mem_func(mem_func),
        .fetch_instr(fetch_instr),
        .update_pc(update_pc),
        .mem_done(mem_done)
    );
    
    // Register File: Read and Write temporary values to registers
    reg_file reg_file (
        .clk(clk),       
        .reset(reset),   
        .rd_addr_1(rs1),  
        .rd_addr_2(rs2), 
        .rd_data_1(reg_data_1),
        .rd_data_2(reg_data_2), 
        .wr_addr(rd),    
        .wr_data(reg_write_data), 
        .wr_en(reg_wr_en)
    );

    // Decoder: Breaks down instruction and determines the desired function to execute
    decoder decoder (
        .instr(instr),
        .data_mem_rd_data(data_mem_rd_data),
        .register_rd_data(reg_data_2),
        .imm(imm),
        .immB(immB),
        .immU(immU),
        .immJ(immJ),
        .alu_op(alu_op),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .load_value(load_value),
        .store_value(store_value)
    );

    // ALU: Executes the desired function 
    execute executor (
        .a(alu_in_1),
        .b(alu_in_2),
        .alu_ctrl(alu_op),
        .result(alu_result),
        .br_en(br_en)
    );
    
endmodule