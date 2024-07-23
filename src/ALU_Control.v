//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/10 20:21:35
// Design Name: 
// Module Name: ALU_Control
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

module ALU_Control
(
    input wire [1:0] ALUOp,         // ALU operation control signal
    input wire [9:0] funct,         // funct signal (includes funct7 and funct3)
    output reg [5:0] alu_control    // ALU control signal output
);

    always @(*) begin
        case (ALUOp)
            2'b00: alu_control = 6'b000001; // Load/store instructions: addition
            2'b01: begin // Branch instructions
                case (funct[2:0])
                    3'b000: alu_control = 6'b000010; // beq
                    3'b100: alu_control = 6'b011000; // blt, reuse slt
                    3'b101: alu_control = 6'b010100; // bge
                    3'b110: alu_control = 6'b010101; // bltu
                    3'b111: alu_control = 6'b010110; // bgeu
                    3'b001: alu_control = 6'b010111; // bne
                    default: alu_control = 6'b000000; // Default
                endcase
            end
            2'b10: begin // R-type instructions
                case (funct)
                    10'b0000000000: alu_control = 6'b000001; // add
                    10'b0100000000: alu_control = 6'b000010; // sub
                    10'b0000000111: alu_control = 6'b000011; // and
                    10'b0000000110: alu_control = 6'b000100; // or
                    10'b0000000100: alu_control = 6'b000101; // xor
                    10'b0000001000: alu_control = 6'b000110; // mul
                    10'b0000001001: alu_control = 6'b000111; // mulh
                    10'b0000001011: alu_control = 6'b001000; // mulhu
                    10'b0000001010: alu_control = 6'b001001; // mulhsu
                    10'b0000001100: alu_control = 6'b001010; // div
                    10'b0000001101: alu_control = 6'b001011; // divu
                    10'b0000001110: alu_control = 6'b001100; // rem
                    10'b0000001111: alu_control = 6'b001101; // remu
                    10'b0000000001: alu_control = 6'b001110; // sll
                    10'b0000000101: alu_control = 6'b001111; // srl
                    10'b0100000101: alu_control = 6'b010000; // sra
                    10'b0000000010: alu_control = 6'b010001; // slt
                    10'b0000000011: alu_control = 6'b010010; // sltu
                    default: alu_control = 6'b000000;         // Default
                endcase
            end
            2'b11: begin // I-type instructions
                case (funct[2:0]) // Only use funct3 part
                    3'b000: alu_control = 6'b000001; // addi
                    3'b100: alu_control = 6'b000101; // xori
                    3'b110: alu_control = 6'b000100; // ori
                    3'b111: alu_control = 6'b000011; // andi
                    3'b001: alu_control = 6'b001110; // slli
                    3'b101: begin
                        if (funct[9:3] == 7'b0000000)
                            alu_control = 6'b001111; // srli
                        else if (funct[9:3] == 7'b0100000)
                            alu_control = 6'b010000; // srai
                        else
                            alu_control = 6'b000000; // Default
                    end
                    3'b010: alu_control = 6'b010001; // slti
                    3'b011: alu_control = 6'b010010; // sltiu
                    default: alu_control = 6'b000000; // Default
                endcase
            end
            default: alu_control = 6'b000000; // Default
        endcase
    end

endmodule
