module riscv_core_tb;

    // Testbench clock and reset
    logic clk;
    logic reset;

    // Memory signals
    logic [31:0] instr_mem_addr;
    logic [31:0] instr_mem_rd_data;
    logic [31:0] data_mem_addr;
    logic [31:0] data_mem_wr_data;
    logic        data_mem_wr_en;
    logic [31:0] data_mem_rd_data;

    // Instantiate the RISC-V core
    riscv_core uut (
        .clk(clk),
        .reset(reset),
        .instr_mem_addr(instr_mem_addr),
        .instr_mem_rd_data(instr_mem_rd_data),
        .data_mem_addr(data_mem_addr),
        .data_mem_wr_data(data_mem_wr_data),
        .data_mem_wr_en(data_mem_wr_en),
        .data_mem_rd_data(data_mem_rd_data)
    );

    // Instruction memory simulation (for simplicity, using an array)
    logic [31:0] instruction_memory [0:300]; // Small instruction memory for testing

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 10 time units period clock
    end

//    // Instruction Memory Initialization: LUI, AUIPC, JAL, JALR
//    initial begin
//        // Instructions in Binary
//        instruction_memory[0] = 32'b10000000000000000000000010110111;   // LUI 
//        instruction_memory[1] = 32'b10000000000000000000000100010111;   // AUIPC
//        instruction_memory[2] = 32'b01000000000000000000000111101111;   // JAL
//        instruction_memory[258] = 32'b00100000000000011000001001100111; // JALR 
//    end

    // Instruction Memory Initialization: Branch Instructions
    initial begin
        // Instructions in Binary
        instruction_memory[0] = 32'b10000000000000000000000010110111;    // LUI x1, 0x80000 (initialize x1 for testing)
        instruction_memory[1] = 32'b00000000000000000001000010110011;    // ADDI x1, x0, 5 (x1 = 5)
        instruction_memory[2] = 32'b00000000000000000001000100110011;    // ADDI x2, x0, 3 (x2 = 3)
        
        // BEQ x1, x1, target (PC relative offset: 4)
        instruction_memory[3] = 32'b00000000000100001000000001100011;    // BEQ x1, x1, 4 (should branch to address 0x14)
        
        // NOP (to be skipped if BEQ is taken)
        instruction_memory[4] = 32'b00000000000000000000000000010011;    // NOP
        
        // Branch target (0x14)
        instruction_memory[5] = 32'b00000000000000000000000101100011;    // BNE x1, x2, 4 (should not branch, x1 != x2)

        // Continue with NOPs to fill space and simulate more instructions
        instruction_memory[6] = 32'b00000000000000000000000000010011;    // NOP
        instruction_memory[7] = 32'b00000000000000000000000000010011;    // NOP

        // BLT x2, x1, target (PC relative offset: 4)
        instruction_memory[8] = 32'b00000000001000001010000001100011;    // BLT x2, x1, 4 (should branch to address 0x24)
        
        // NOP (to be skipped if BLT is taken)
        instruction_memory[9] = 32'b00000000000000000000000000010011;    // NOP

        // Branch target (0x24)
        instruction_memory[10] = 32'b00000000001100001011000001100011;   // BGE x1, x2, 4 (should not branch, x1 > x2)

        // More NOPs or other instructions
        instruction_memory[11] = 32'b00000000000000000000000000010011;   // NOP
        instruction_memory[12] = 32'b00000000000000000000000000010011;   // NOP
        instruction_memory[13] = 32'b00000000000000000000000000010011;   // NOP
        instruction_memory[14] = 32'b00000000000000000000000000010011;   // NOP
    end

    // Instruction fetch logic
    always_comb begin
        instr_mem_rd_data = instruction_memory[instr_mem_addr >> 2]; // Fetch instruction (aligned to 4 bytes)
    end

    // Testbench initialization
    initial begin
        // Initialize inputs
        reset = 1;
        #20 reset = 0; // Release reset after 20 time units
        
        // Wait for the core to execute a few cycles
        #300;
        
        // End the simulation
        $stop;
    end

    // Monitor the outputs and other signals
    initial begin
        $monitor("Time=%0t | PC=%h | Instr=%h | Reg x1=%h | Reg x2=%h", 
                 $time, instr_mem_addr, instr_mem_rd_data, uut.reg_file.reg_array[1], uut.reg_file.reg_array[2]);
    end

    // Branch Instruction Checks
    initial begin
        // Wait until after the BEQ instruction should have executed
        @(posedge clk);
        @(posedge clk);
        
        // Check if PC branched correctly after BEQ
        if (instr_mem_addr !== 32'h14) begin
            $display("BEQ Test Failed: Expected PC 0x14, Got %h", instr_mem_addr);
        end else begin
            $display("BEQ Test Passed");
        end
        
        // Wait for BLT instruction to execute
        @(posedge clk);
        @(posedge clk);
        
        // Check if PC branched correctly after BLT
        if (instr_mem_addr !== 32'h24) begin
            $display("BLT Test Failed: Expected PC 0x24, Got %h", instr_mem_addr);
        end else begin
            $display("BLT Test Passed");
        end

        // Additional checks for other branches can be added similarly
    end


    // Instruction fetch logic
    always_comb begin
        instr_mem_rd_data = instruction_memory[instr_mem_addr >> 2]; // Fetch instruction (aligned to 4 bytes)
    end

    // Testbench initialization
    initial begin
        // Initialize inputs
        reset = 1;
        #20 reset = 0; // Release reset after 20 time units
        
        // Wait for the core to execute a few cycles
        #200;
        
        // End the simulation
        $stop;
    end

//    // Monitor the outputs and other signals
//    initial begin
//        $monitor("Time=%0t | PC=%h | ALU_Result=%h | Instr=%h | Reg_Write_Data=%h | Data_Mem_Addr=%h | Data_Mem_Wr_En=%b", 
//                 $time, instr_mem_addr, uut.alu_result, instr_mem_rd_data, uut.reg_write_data, data_mem_addr, data_mem_wr_en);
//    end

    // // Uncomment Output verification for LUI, AUIPC, JAL, and JALR // 
//    initial begin
//        // LUI Instruction Check
//        @(posedge clk); 
//        @(posedge clk); 
//        if (uut.reg_file.reg_array[1] !== 32'h80000000) begin
//            $display("LUI Test Failed: Expected 0x80000000, Got 0x%h", uut.reg_file.reg_array[1]);
//        end else begin
//            $display("LUI Test Passed");
//        end
        
//        // AUIPC Instruction Check
//        @(posedge clk);
//        @(posedge clk); 
//        if (uut.reg_file.reg_array[2] !== (32'h80000004)) begin
//            $display("AUIPC Test Failed: Expected 0x%h, Got 0x%h", 32'h80000004, uut.reg_file.reg_array[2]);
//        end else begin
//            $display("AUIPC Test Passed");
//        end
        
//        // JAL Instruction Check
//        @(posedge clk);
//        if (uut.pc_reg !== 32'h0000408) begin
//            $display("JAL Test (pc update) Failed: Expected 0x%h, Got 0x%h", 32'h0000408, uut.pc_reg);
//        end else begin
//            $display("JAL Test (pc update) Passed");
//        end
//        @(posedge clk); 
//        if (uut.reg_file.reg_array[3] !== 32'h000000c) begin
//            $display("JAL Test (reg store) Failed: Expected 0x%h, Got 0x%h", 32'h000000c, uut.reg_file.reg_array[3]);
//        end else begin
//            $display("JAL Test (reg store) Passed");
//        end
        
//        // JALR Instruction Check
//        if (uut.pc_reg !== 32'h000020c) begin
//            $display("JALR Test (pc update) Failed: Expected 0x%h, Got 0x%h", 32'h000020c, uut.pc_reg);
//        end else begin
//            $display("JALR Test (pc update) Passed");
//        end
//        @(posedge clk); 
//        if (uut.reg_file.reg_array[4] !== 32'h000040c) begin
//            $display("JALR Test (reg store) Failed: Expected 0x%h, Got 0x%h", 32'h000040c, uut.reg_file.reg_array[4]);
//        end else begin
//            $display("JALR Test (reg store) Passed");
//        end
//    end

endmodule
