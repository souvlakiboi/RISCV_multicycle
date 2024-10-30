//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Author: Alexander Mellas (UIUC '24)
// Purpose: The Arithmetic Logic Unit (ALU) performs desired operations
//////////////////////////////////////////////////////////////////////////////////////////////////////////
module execute (
    input logic [31:0] a,         // First operand
    input logic [31:0] b,         // Second operand
    input logic [3:0] alu_ctrl,   // ALU control signal to select operation
    output logic [31:0] result,   // ALU result
    output logic br_en             // ALU Br result
);

alu alu (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result)
    );
    
alu_br alu_br (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .br_en(br_en)
    );


endmodule



module alu (
    input logic [31:0] a,         // First operand
    input logic [31:0] b,         // Second operand
    input logic [3:0] alu_ctrl,   // ALU control signal to select operation
    output logic [31:0] result    // ALU result
);

    // ALU control signals encoding
    localparam ADD  = 4'b0000; // Addition
    localparam SUB  = 4'b0001; // Subtraction
    localparam SLL  = 4'b0010; // Shift Left Logical
    localparam SLT  = 4'b0011; // Set Less Than (Signed)
    localparam SLTU = 4'b0100; // Set Less Than (Unsigned)
    localparam XOR  = 4'b0101; // Bitwise XOR
    localparam SRL  = 4'b0110; // Shift Right Logical
    localparam SRA  = 4'b0111; // Shift Right Arithmetic
    localparam OR   = 4'b1000; // Bitwise OR
    localparam AND  = 4'b1001; // Bitwise AND

    // ALU operations
    always_comb begin
        case (alu_ctrl)
            ADD:  result = a + b;                                       // Addition
            SUB:  result = a - b;                                       // Subtraction
            SLL:  result = a << b[4:0];                                 // Shift Left Logical
            SLT:  result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;   // Set Less Than (Signed)
            SLTU: result = (a < b) ? 32'b1 : 32'b0;                     // Set Less Than (Unsigned)
            XOR:  result = a ^ b;                                       // Bitwise XOR
            SRL:  result = a >> b[4:0];                                 // Shift Right Logical
            SRA:  result = $signed(a) >>> b[4:0];                       // Shift Right Arithmetic
            OR:   result = a | b;                                       // Bitwise OR
            AND:  result = a & b;                                       // Bitwise AND
            default: result = 32'b0;                                    // Default case
        endcase
    end

endmodule

module alu_br (
    input logic [31:0] a,         // First operand
    input logic [31:0] b,         // Second operand
    input logic [3:0] alu_ctrl,   // ALU control signal to select operation
    output logic br_en            // ALU result - Branch Enable
);

    // ALU Branch control signals encoding
    localparam BEQ  = 4'b0000; // Equals 
    localparam BNE  = 4'b0001; // Not Equals
    localparam BLT  = 4'b0010; // Less Than (Signed)
    localparam BGE  = 4'b0011; // Greater Than (Signed)
    localparam BLTU = 4'b0100; // Less Than (Unigned)
    localparam BGEU  = 4'b0101; // Greater Than (Unigned)

    // ALU Branch operations
    always_comb begin
        case (alu_ctrl)
            BEQ:  br_en = (a == b) ? 1'b1 : 1'b0;                   // Equals
            BNE:  br_en = (a != b) ? 1'b1 : 1'b0;                   // Not Equals
            BLT:  br_en = ($signed(a) < $signed(b)) ? 1'b1 : 1'b0;  // Less Than (Signed)
            BGE:  br_en = ($signed(a) >= $signed(b)) ? 1'b1 : 1'b0; // Greater Than (Signed)
            BLTU: br_en = (a < b) ? 1'b1 : 1'b0;                    // Less Than (Unigned)
            BGEU: br_en = (a >= b) ? 1'b1 : 1'b0;                   // Greater Than (Unigned)
            default: br_en = 1'b0;
        endcase
    end

endmodule

