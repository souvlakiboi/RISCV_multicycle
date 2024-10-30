//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Author: Alexander Mellas (UIUC '24)
// Purpose: Test the Decoder Module
//////////////////////////////////////////////////////////////////////////////////////////////////////////
module tb_decoder;
    // Inputs and ouputs
    logic [31:0] instr;      // Instruction
       
    logic [31:0] imm;        // Immediate
    logic [31:0] immB;       // Branch Immediate
    logic [3:0] alu_op;      // Execute Operation
    logic [4:0] rd;          // Destination Register 
    logic [4:0] rs1;         // Source Register 1
    logic [4:0] rs2;          // Source Register 2
    
    logic [6:0] opcode_test;
    logic [4:0] rd_test;
    logic [2:0] funct3_test;
    logic [4:0] rs1_test;
    logic [11:0] imm_test;
    
    logic [4:0] imm1_test;
    logic [6:0] imm2_test;
    logic [4:0] rs2_test;
    

    // Instantiate UUT
    decoder uut_decoder (
        .instr  (instr),
        .imm    (imm),
        .immB   (immB),
        .alu_op (alu_op),
        .rd     (rd),
        .rs1    (rs1),
        .rs2    (rs2)
    );
    
    // Task to check the output
    task check_output(input [31:0] expected_imm, input [31:0] expected_immB, input [3:0] expected_alu_op);
        if (imm !== expected_imm) begin
            $display("ERROR: Immediate value mismatch. Expected: %h, Got: %h", expected_imm, imm);
        end else begin
            $display("SUCCESS: Immediate value matched. Expected %h, Got: %h", expected_imm, imm);
        end
        
        if (immB !== expected_immB) begin
            $display("ERROR: Branch Immediate value mismatch. Expected: %h, Got: %h", expected_immB, immB);
        end else begin
            $display("SUCCESS: Branch Immediate value matched. Expected %h, Got: %h", expected_immB, immB);
        end
        
        if (alu_op !== expected_alu_op) begin
            $display("ERROR: ALU operation mismatch. Expected: %h, Got: %h", expected_alu_op, alu_op);
        end else begin
            $display("SUCCESS: ALU operation value matched. Expected %h, Got: %h", expected_alu_op, alu_op);
        end
    endtask
        
    // Test vector generation
    
//     //////////////////////////  Uncomment This block for I-type instructions //////////////////////////
//    initial begin
//        // Set common fields
//        opcode_test = 7'b0010011;
//        rd_test = 5'b00101;
//        rs1_test = 5'b00010;
//        imm_test = 12'b000000000011;
//        #10;

//        // Test case 1: ADDI 
//        funct3_test = 3'b000;
//        instr = {imm_test, rs1_test, funct3_test, rd_test, opcode_test};
//        #10;
//        check_output(32'h00000003, 32'h00000000, 4'b0000);
        
//        // Test case 2: SLTI 
//        funct3_test = 3'b010;
//        instr = {imm_test, rs1_test, funct3_test, rd_test, opcode_test};
//        #10;
//        check_output(32'h00000003, 32'h00000000, 4'b0011);
        
//        // Test case 3: SLTIU 
//        funct3_test = 3'b011;
//        instr = {imm_test, rs1_test, funct3_test, rd_test, opcode_test};
//        #10;
//        check_output(32'h00000003, 32'h00000000, 4'b0100);
        
//        // Test case 4: XORI
//        funct3_test = 3'b100;
//        instr = {imm_test, rs1_test, funct3_test, rd_test, opcode_test};
//        #10;
//        check_output(32'h00000003, 32'h00000000, 4'b0101);
        
//        // Test case 5: ORI 
//        funct3_test = 3'b110;
//        instr = {imm_test, rs1_test, funct3_test, rd_test, opcode_test};
//        #10;
//        check_output(32'h00000003, 32'h00000000, 4'b1000);
        
//        // Test case 6: ANDI 
//        funct3_test = 3'b111;
//        instr = {imm_test, rs1_test, funct3_test, rd_test, opcode_test};
//        #10;
//        check_output(32'h00000003, 32'h00000000, 4'b1001);
        
//        // Test case 7: SLLI 
//        funct3_test = 3'b001;
//        instr = {imm_test, rs1_test, funct3_test, rd_test, opcode_test};
//        #10;
//        check_output(32'h00000003, 32'h00000000, 4'b0010);
        
//        // Test case 8: SRLI 
//        funct3_test = 3'b101;
//        instr = {imm_test, rs1_test, funct3_test, rd_test, opcode_test};
//        #10;
//        check_output(32'h00000003, 32'h00000000, 4'b0110);
        
//        // Test case 9: SRAI 
//        funct3_test = 3'b101;
//        imm_test = 12'b010000000011; // Change instruction bit 30 to 1'b1
//        instr = {imm_test, rs1_test, funct3_test, rd_test, opcode_test};
//        #10;
//        check_output(32'h00000403, 32'h00000000, 4'b0111);
        
//        // End Simulation
//        $finish;
//    end
      
     //////////////////////////  Uncomment This block for Branch instructions //////////////////////////
    initial begin
        // Set common fields
        opcode_test = 7'b1100011; 
        rs1_test = 5'b00010;
        rs2_test = 5'b00000;
        imm1_test = 5'b00010;
        imm2_test = 7'b0000000;
        #10;

        // Test case 1: BEQ 
        funct3_test = 3'b000;
        instr = {imm2_test, rs2_test, rs1_test, funct3_test, imm1_test, opcode_test};
        #10;
        check_output(32'h00000000, 32'h00000002, 4'b0000);
        
        // Test case 2: BNE 
        funct3_test = 3'b001;
        instr = {imm2_test, rs2_test, rs1_test, funct3_test, imm1_test, opcode_test};        
        #10;
        check_output(32'h00000000, 32'h00000002, 4'b0001);
        
        // Test case 3: BLT 
        funct3_test = 3'b100;
        instr = {imm2_test, rs2_test, rs1_test, funct3_test, imm1_test, opcode_test};        
        #10;
        check_output(32'h00000000, 32'h00000002, 4'b0010);
        
        // Test case 4: BGE
        funct3_test = 3'b101;
        instr = {imm2_test, rs2_test, rs1_test, funct3_test, imm1_test, opcode_test};        
        #10;
        check_output(32'h00000000, 32'h00000002, 4'b0011);
        
        // Test case 5: BLTU 
        funct3_test = 3'b110;
        instr = {imm2_test, rs2_test, rs1_test, funct3_test, imm1_test, opcode_test};        
        #10;
        check_output(32'h00000000, 32'h00000002, 4'b0100);
       
        // Test case 6: BGEU 
        funct3_test = 3'b111;
        instr = {imm2_test, rs2_test, rs1_test, funct3_test, imm1_test, opcode_test};        
        #10;
        check_output(32'h00000000, 32'h00000002, 4'b0101);
        
        // End Simulation
        $finish;
    end
endmodule
