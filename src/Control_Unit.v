//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/10 21:17:55
// Design Name: 
// Module Name: Control_Unit
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

module Control_Unit 
(
    input wire [31:0] instr,     // Input instruction
    output wire [1:0] ALUOp,     // ALU operation control signal
    output wire ALUSrc,          // ALU operand selection signal
    output wire Branch,          // Branch signal
    output wire MemRead,         // Memory read enable signal
    output wire MemWrite,        // Memory write enable signal
    output wire RegWrite,        // Register write enable signal
    output wire MemtoReg,        // Memory to register data selection signal
    output wire Jump,            // Jump signal
    output wire JumpAddrSrc,     // Jump address source signal
    output wire ImmLoad,         // Immediate load signal
    output wire [2:0] DataMemOutOp,  // Memory operation signal
    output wire WriteBackRegSrc            // New signal to control write-back register value source
);

    reg [1:0] ALUOp_reg;
    reg ALUSrc_reg;
    reg Branch_reg;
    reg MemRead_reg;
    reg MemWrite_reg;
    reg RegWrite_reg;
    reg MemtoReg_reg;
    reg Jump_reg;
    reg JumpAddrSrc_reg;
    reg ImmLoad_reg;
    reg [2:0] DataMemOutOp_reg;
    reg WriteBackRegSrc_reg; // New register variable

    always @(*) begin
        case (instr[6:0])
            7'b0110011: begin // R-format
                ALUOp_reg = 2'b10;
                ALUSrc_reg = 1'b0;
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemWrite_reg = 1'b0;
                RegWrite_reg = 1'b1;
                MemtoReg_reg = 1'b0;
                Jump_reg = 1'b0;
                JumpAddrSrc_reg = 1'b0;
                ImmLoad_reg = 1'b0;
                DataMemOutOp_reg = 3'b000; // Not needed
                WriteBackRegSrc_reg = 1'b0; // Default to 0
            end
            7'b0010011: begin // I-format
                ALUOp_reg = 2'b11;
                ALUSrc_reg = 1'b1;
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemWrite_reg = 1'b0;
                RegWrite_reg = 1'b1;
                MemtoReg_reg = 1'b0;
                Jump_reg = 1'b0;
                JumpAddrSrc_reg = 1'b0;
                ImmLoad_reg = 1'b0;
                DataMemOutOp_reg = 3'b000; // Not needed
                WriteBackRegSrc_reg = 1'b0; // Default to 0
            end
            7'b0000011: begin // load instructions
                case (instr[14:12])
                    3'b010: DataMemOutOp_reg = 3'b001; // lw
                    3'b000: DataMemOutOp_reg = 3'b010; // lb
                    3'b001: DataMemOutOp_reg = 3'b011; // lh
                    3'b100: DataMemOutOp_reg = 3'b100; // lbu
                    3'b101: DataMemOutOp_reg = 3'b101; // lhu
                    default: DataMemOutOp_reg = 3'b000; // Not needed
                endcase
                ALUOp_reg = 2'b00;
                ALUSrc_reg = 1'b1;
                Branch_reg = 1'b0;
                MemRead_reg = 1'b1;
                MemWrite_reg = 1'b0;
                RegWrite_reg = 1'b1;
                MemtoReg_reg = 1'b1;
                Jump_reg = 1'b0;
                JumpAddrSrc_reg = 1'b0;
                ImmLoad_reg = 1'b0;
                WriteBackRegSrc_reg = 1'b0; // Default to 0
            end
            7'b0100011: begin // store instructions
                case (instr[14:12])
                    3'b010: DataMemOutOp_reg = 3'b001; // sw
                    3'b000: DataMemOutOp_reg = 3'b010; // sb
                    3'b001: DataMemOutOp_reg = 3'b011; // sh
                    default: DataMemOutOp_reg = 3'b000; // Not needed
                endcase
                ALUOp_reg = 2'b00;
                ALUSrc_reg = 1'b1;
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemWrite_reg = 1'b1;
                RegWrite_reg = 1'b0;
                MemtoReg_reg = 1'bx; // Don't care
                Jump_reg = 1'b0;
                JumpAddrSrc_reg = 1'b0;
                ImmLoad_reg = 1'b0;
                WriteBackRegSrc_reg = 1'b0; // Default to 0
            end
            7'b1100011: begin // branch instructions (beq, bne, blt, bge, bltu, bgeu)
                ALUOp_reg = 2'b01;
                ALUSrc_reg = 1'b0;
                Branch_reg = 1'b1;
                MemRead_reg = 1'b0;
                MemWrite_reg = 1'b0;
                RegWrite_reg = 1'b0;
                MemtoReg_reg = 1'bx; // Don't care
                Jump_reg = 1'b0;
                JumpAddrSrc_reg = 1'b0;
                ImmLoad_reg = 1'b0;
                DataMemOutOp_reg = 3'b000; // Not needed
                WriteBackRegSrc_reg = 1'b0; // Default to 0
            end
            7'b1101111: begin // jal
                ALUOp_reg = 2'bxx; // Don't care
                ALUSrc_reg = 1'bx; // Don't care
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemWrite_reg = 1'b0;
                RegWrite_reg = 1'b1;
                MemtoReg_reg = 1'b0;
                Jump_reg = 1'b1;
                JumpAddrSrc_reg = 1'b0;
                ImmLoad_reg = 1'b0;
                DataMemOutOp_reg = 3'b000; // Not needed
                WriteBackRegSrc_reg = 1'b0; // Default to 0
            end
            7'b1100111: begin // jalr
                ALUOp_reg = 2'bxx; // Don't care
                ALUSrc_reg = 1'b1; 
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemWrite_reg = 1'b0;
                RegWrite_reg = 1'b1;
                MemtoReg_reg = 1'b0;
                Jump_reg = 1'b1;
                JumpAddrSrc_reg = 1'b1;
                ImmLoad_reg = 1'b0;
                DataMemOutOp_reg = 3'b000; // Not needed
                WriteBackRegSrc_reg = 1'b0; // Default to 0
            end
            7'b0110111: begin // lui instruction
                ALUOp_reg = 2'b00;   // Addition
                ALUSrc_reg = 1'b1;   // Use immediate as operand
                Branch_reg = 1'b0;   // No branching
                MemRead_reg = 1'b0;  // No memory read
                MemWrite_reg = 1'b0; // No memory write
                RegWrite_reg = 1'b1; // Write to register
                MemtoReg_reg = 1'b0; // No memory to register data selection needed
                Jump_reg = 1'b0;     // No jump
                JumpAddrSrc_reg = 1'b0; // No jump address source selection needed
                ImmLoad_reg = 1'b1;  // Immediate load signal
                DataMemOutOp_reg = 3'b000; // No memory operation needed
                WriteBackRegSrc_reg = 1'b0; // Default to 0
            end
            7'b0010111: begin // auipc
                ALUOp_reg = 2'b00;   // Addition
                ALUSrc_reg = 1'b1;   // Use immediate as operand
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemWrite_reg = 1'b0;
                RegWrite_reg = 1'b1;
                MemtoReg_reg = 1'b0;
                Jump_reg = 1'b0;
                JumpAddrSrc_reg = 1'b0;
                ImmLoad_reg = 1'b0;
                DataMemOutOp_reg = 3'b000; // Not needed
                WriteBackRegSrc_reg = 1'b1; // Only 1 in AUIPC instruction
            end
            // Control signal handling for other instructions...
            default: begin
                ALUOp_reg = 2'b00;
                ALUSrc_reg = 1'b0;
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemWrite_reg = 1'b0;
                RegWrite_reg = 1'b0;
                MemtoReg_reg = 1'b0;
                Jump_reg = 1'b0;
                JumpAddrSrc_reg = 1'b0;
                ImmLoad_reg = 1'b0;
                DataMemOutOp_reg = 3'b000; // Not needed
                WriteBackRegSrc_reg = 1'b0; // Default to 0
            end
        endcase
    end

    assign ALUOp = ALUOp_reg;
    assign ALUSrc = ALUSrc_reg;
    assign Branch = Branch_reg;
    assign MemRead = MemRead_reg;
    assign MemWrite = MemWrite_reg;
    assign RegWrite = RegWrite_reg;
    assign MemtoReg = MemtoReg_reg;
    assign Jump = Jump_reg;
    assign JumpAddrSrc = JumpAddrSrc_reg;
    assign ImmLoad = ImmLoad_reg;
    assign DataMemOutOp = DataMemOutOp_reg;
    assign WriteBackRegSrc = WriteBackRegSrc_reg; // New signal output

endmodule
