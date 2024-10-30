//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Author: Alexander Mellas (UIUC '24)
// Purpose: The Control Unit reads the current instruction and produces appropriate control signals
//////////////////////////////////////////////////////////////////////////////////////////////////////////
module controller (
    input logic clk,
    input logic reset,

    input logic [6:0] opcode,     // Opcode           : Indicates Operation Type
    input logic br_en,            // Branch Boolean   : Same as br_en (for organization purposes) 
        
    // Control Signals
    output logic imm_en,          // Immediate Enable : Execute uses an immediate
    output logic reg_wr_en,       // Reg Write Enable : Allow writing to register file
    output logic [2:0] reg_wr_sel,// Reg Write Select : 0 (Default), 1 (Load), 2 (Jump)
    output logic data_mem_wr_en,  // Mem Write Enable : Store to Data Memory
    output logic [2:0] pc_sel,           // PC Select    :   : Select to Mux choosing PC source 
    output logic mem_func,
    
    output logic fetch_instr,
    output logic update_pc,
    output logic mem_done
);
    
    // Assign control signals given the op-type
    always_comb begin
        case (opcode)
            7'b0010011: begin // I-type (xxI)
                imm_en = 1'b1;
                reg_wr_en = 1'b1;
                reg_wr_sel = 3'b000;
                data_mem_wr_en = 1'b0;
                pc_sel = 3'b000;
                mem_func = 1'b0;
            end
            7'b0110011: begin // R-type (xx)
                imm_en = 1'b0;
                reg_wr_en = 1'b1;
                reg_wr_sel = 3'b000;
                data_mem_wr_en = 1'b0;
                pc_sel = 3'b000;
                mem_func = 1'b0;
            end
            7'b0000011: begin // Load (Lxx)
                imm_en = 1'b1;
                reg_wr_en = 1'b1;
                reg_wr_sel = 3'b001;
                data_mem_wr_en = 1'b0;
                pc_sel = 3'b000;
                mem_func = 1'b1;
            end
            7'b0100011: begin // Store (Sxx)
                imm_en = 1'b1;
                reg_wr_en = 1'b0;
                reg_wr_sel = 3'b000; 
                data_mem_wr_en = 1'b1;
                pc_sel = 3'b000;
                mem_func = 1'b1;
            end
            7'b1100011: begin // Branch (Bxx) 
                imm_en = 1'b0;
                reg_wr_en = 1'b0;
                reg_wr_sel = 3'b000;
                data_mem_wr_en = 1'b0;
                pc_sel = br_en ? 3'b001 : 3'b000;
                mem_func = 1'b0;
            end
            7'b1101111: begin // Jump and Link (JAL)
                imm_en = 1'b0;
                reg_wr_en = 1'b1;
                reg_wr_sel = 3'b010;
                data_mem_wr_en = 1'b0;
                pc_sel = 3'b100; 
                mem_func = 1'b0;
            end
            7'b1100111: begin // Jump and Link Register (JALR)
                imm_en = 1'b1;
                reg_wr_en = 1'b1;
                reg_wr_sel = 3'b010;
                data_mem_wr_en = 1'b0;
                pc_sel = 3'b010; 
                mem_func = 1'b0;
            end
            7'b0110111: begin // Load Upper Immediate (LUI)
                imm_en = 1'b0;
                reg_wr_en = 1'b1;
                reg_wr_sel = 3'b011;
                data_mem_wr_en = 1'b0;
                pc_sel = 3'b000;
                mem_func = 1'b0;
            end
            7'b0010111: begin // Add Upper Immediate to PC (AUIPC)
                imm_en = 1'b0;
                reg_wr_en = 1'b1;
                reg_wr_sel = 3'b100;
                data_mem_wr_en = 1'b0;
                pc_sel = 3'b000;
                mem_func = 1'b0;
            end
            
            default: begin // Default
                imm_en = 1'b0;
                reg_wr_en = 1'b0;
                reg_wr_sel = 3'b011;
                data_mem_wr_en = 1'b0;
                pc_sel = 3'b000;
                mem_func = 1'b0;
            end
        endcase
    end
    
    // State Machine
    // 1) Wait1: Wait for instruction to become valid
    // 2) Wait2: Wait for instruction to become valid
    // 3) Fetch: Allow fetch to update pc / instruction 
    // 4) If mem_read or mem_write
        // 3) Enter Wait states to allow data to be read/written
    
    // State definitions
    typedef enum logic [2:0] {
        WAIT1,  
        WAIT2,   
        FETCH,
        UPDATE,
        MEM1,
        MEM2
    } state_t;
    
    state_t current_state, next_state;
    
    // State transition logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= WAIT1;  // Reset to IDLE state
        end else begin
            current_state <= next_state;  // Transition to the next state
        end
    end

    // Next state logic
    always_comb begin
        // Default fetch_instr to 1 in IDLE state
        fetch_instr = (current_state == FETCH);
        update_pc   = ((current_state == UPDATE) && (!mem_func)) || ((current_state == UPDATE) && (mem_done));
        
        // Determine the next state based on the current state and inputs
        case (current_state)
            WAIT1:   begin
                next_state = WAIT2;
                mem_done = 1'b0;
            end
            WAIT2:   begin
                next_state = FETCH; 
                mem_done = 1'b0;
            end 
            FETCH:   begin
                next_state = UPDATE;
                mem_done = 1'b0;
            end
            UPDATE:  begin
                next_state =  (!mem_func || mem_done) ? WAIT1 : MEM1;
                mem_done = 1'b0;
            end
            MEM1:    begin
                next_state = MEM2;
                mem_done = 1'b0;
            end
            MEM2:    begin
                next_state = UPDATE;
                mem_done = 1'b1;
            end
            default: begin
                next_state = WAIT1;
                mem_done = 1'b0;
            end
        endcase
    end

endmodule
