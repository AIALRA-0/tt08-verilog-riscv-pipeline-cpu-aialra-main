//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/10 17:57:09
// Design Name: 
// Module Name: Immediate_Generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Immediate_Generator
(
    input wire [31:0] instr, // Instruction input
    output reg [31:0] imm    // Immediate output
);

    always @(*) begin
        case (instr[6:0])
            7'b0010011, // I-type: addi, etc.
            7'b0000011, // I-type: lw, lb, lh, lbu, lhu
            7'b1100111: // I-type: jalr
                imm = {{20{instr[31]}}, instr[31:20]};
            
            7'b0100011: // S-type: sw, sb, sh
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            
            7'b1100011: // B-type: beq, bne, blt, bge, bltu, bgeu
                imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            
            7'b0110111, // U-type: lui
            7'b0010111: // U-type: auipc
                imm = {instr[31:12], 12'b0};
            
            7'b1101111: // J-type: jal
                imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            
            default:
                imm = 32'b0; // Unknown type, immediate value is 0
        endcase
    end

endmodule
