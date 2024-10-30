module instruction_loader (
    input  logic        clk,
    input  logic        reset,
    input  logic        load_enable,
    output logic [9:0]  instr_mem_addr,
    output logic        instr_mem_wr_en,
    output logic [31:0] instr_mem_data,
    output logic        load_done
);
    // Memory File: Provide path to imported .mem file
    // parameter MEM_FILE = "C:/Users/Alex/Documents/RISC-V/RISC_V Processor.srcs/sim_1/imports/set_variable_test/set_variable_formatted.mem";
    
    // Initial Address
    parameter INITIAL_INSTR_ADDR = 10'h000;
    
    // Number of Instructions - At the top of the .mem file
    parameter NUM_INSTRUCTIONS = 10'h022;

    // Register array to temporarily hold instructions
    logic [31:0] instr_data_reg [0:NUM_INSTRUCTIONS-1];
    
    always_comb begin
        instr_data_reg[0] = 32'hFE010113; // I-Type
        instr_data_reg[1] = 32'h00812E23; // Store
        instr_data_reg[2] = 32'h02010413; // I-Type
        instr_data_reg[3] = 32'h3FF00793; // I-Type
        instr_data_reg[4] = 32'hFEF42023; // Store
        instr_data_reg[5] = 32'hFE042623; // Store
        instr_data_reg[6] = 32'h05C0006F; // JAL
        instr_data_reg[7] = 32'hFE042423; // Store
        instr_data_reg[8] = 32'h0300006F; // JAL
        instr_data_reg[9] = 32'hFE042223; // Store
        instr_data_reg[10] = 32'h0100006F; // JAL
        instr_data_reg[11] = 32'hFE442783; // Load
        instr_data_reg[12] = 32'h00178793; // I-Type
        instr_data_reg[13] = 32'hFEF42223; // Store
        instr_data_reg[14] = 32'hFE442703; // Load
        instr_data_reg[15] = 32'h3E800793; // I-Type
        instr_data_reg[16] = 32'hFEE7D6E3; // Branch
        instr_data_reg[17] = 32'hFE842783; // Load
        instr_data_reg[18] = 32'h00178793; // I-Type
        instr_data_reg[19] = 32'hFEF42423; // Store
        instr_data_reg[20] = 32'hFE842703; // Load
        instr_data_reg[21] = 32'h3E800793; // I-Type
        instr_data_reg[22] = 32'hFCE7D6E3; // Branch
        instr_data_reg[23] = 32'hFEC42703; // Load
        instr_data_reg[24] = 32'hFE042783; // Load
        instr_data_reg[25] = 32'h00E7A023; // Store
        instr_data_reg[26] = 32'hFEC42783; // Load
        instr_data_reg[27] = 32'h00178793; // I-Type
        instr_data_reg[28] = 32'hFEF42623; // Store
        instr_data_reg[29] = 32'hFEC42703; // Load
        instr_data_reg[30] = 32'h00A00793; // I-Type
        instr_data_reg[31] = 32'hFAE7D0E3; // Branch
        instr_data_reg[32] = 32'h0000006F; // JAL
        instr_data_reg[33] = 32'h00000013; // NOP
    end  
    
    // Counter: Track Address (4-byte aligned)
    logic [9:0] addr_counter;
    
    // Rising edge detector for load_enable
    logic load_enable_prev;
    logic load_enable_rising_edge;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            load_enable_prev <= 1'b0;
        end else begin
            load_enable_prev <= load_enable;
        end
    end

    assign load_enable_rising_edge = load_enable && !load_enable_prev;

    // Instruction Memory Address and Data
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset logic has the highest priority
            addr_counter <= INITIAL_INSTR_ADDR;
            load_done <= 1'b0;       // Reset load_done
            instr_mem_wr_en <= 1'b0; // Disable write
            instr_mem_data <= 32'b0;
            instr_mem_addr <= 10'b0;
        end else if (load_enable_rising_edge) begin
            // Loading logic has the next highest priority
            addr_counter <= INITIAL_INSTR_ADDR;
            load_done <= 1'b0;       // Clear load_done to start loading
            instr_mem_wr_en <= 1'b1; // Enable write on rising edge of load_enable
        end else if (instr_mem_wr_en && (addr_counter < NUM_INSTRUCTIONS)) begin
            // Continue loading while write enable is high and address is within range
            instr_mem_data <= instr_data_reg[addr_counter];
            instr_mem_addr <= addr_counter;
            addr_counter <= addr_counter + 1;
            if (addr_counter == (NUM_INSTRUCTIONS - 1)) begin
                instr_mem_wr_en <= 1'b0; // Stop write when the last instruction is reached
                load_done <= 1'b1;       // Indicate that loading is done
            end
        end else begin
            // Ensure write enable is low when not loading
            instr_mem_wr_en <= 1'b0;
        end
    end

endmodule
