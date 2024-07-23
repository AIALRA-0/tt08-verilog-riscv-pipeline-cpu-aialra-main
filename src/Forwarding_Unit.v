//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/12 11:53:45
// Design Name: 
// Module Name: Forwarding_Unit
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

module Forwarding_Unit
(
    input wire [4:0] RegisterRs1,        // Rs1 register number in IF/ID stage
    input wire [4:0] RegisterRs2,        // Rs2 register number in IF/ID stage
    input wire [4:0] RegisterRd_ex_mem,  // Rd register number in EX/MEM stage
    input wire [4:0] RegisterRd_mem_wb,  // Rd register number in MEM/WB stage
    input wire RegWrite_ex_mem,          // Register write enable signal in EX/MEM stage
    input wire RegWrite_mem_wb,          // Register write enable signal in MEM/WB stage
    input wire MemWrite_ex,              // Memory write enable signal in EX/MEM stage
    input wire ALUSrc,                   // ALU source select signal, decides whether to use immediate value
    output reg [1:0] ForwardA,           // Control selection for ALU input A
    output reg [1:0] ForwardB,           // Control selection for ALU input B
    output reg [1:0] ForwardDataMemWriteData // Control selection for Data Memory write data
);

    // Forwarding control logic
    always @(*) begin
        // Control forwarding for ALU input A
        if (RegWrite_ex_mem && (RegisterRd_ex_mem != 0) && (RegisterRd_ex_mem == RegisterRs1)) begin
            ForwardA = 2'b10;  // Forward from EX/MEM
        end else if (RegWrite_mem_wb && (RegisterRd_mem_wb != 0) && (RegisterRd_mem_wb == RegisterRs1) && !(RegWrite_ex_mem && (RegisterRd_ex_mem != 0) && (RegisterRd_ex_mem == RegisterRs1))) begin
            ForwardA = 2'b01;  // Forward from MEM/WB
        end else begin
            ForwardA = 2'b00;  // No forwarding
        end
        
        // Control forwarding for ALU input B
        if (ALUSrc) begin
            ForwardB = 2'b00;  // Use immediate value, no forwarding
        end else if (RegWrite_ex_mem && (RegisterRd_ex_mem != 0) && (RegisterRd_ex_mem == RegisterRs2)) begin
            ForwardB = 2'b10;  // Forward from EX/MEM
        end else if (RegWrite_mem_wb && (RegisterRd_mem_wb != 0) && (RegisterRd_mem_wb == RegisterRs2) && !(RegWrite_ex_mem && (RegisterRd_ex_mem != 0) && (RegisterRd_ex_mem == RegisterRs2))) begin
            ForwardB = 2'b01;  // Forward from MEM/WB
        end else begin
            ForwardB = 2'b00;  // No forwarding
        end
        
        // Control forwarding for Data Memory write data
        if (MemWrite_ex && RegWrite_ex_mem && (RegisterRd_ex_mem != 0) && (RegisterRd_ex_mem == RegisterRs2)) begin
            ForwardDataMemWriteData = 2'b10;  // Forward from EX/MEM
        end else if (MemWrite_ex && RegWrite_mem_wb && (RegisterRd_mem_wb != 0) && (RegisterRd_mem_wb == RegisterRs2) && !(RegWrite_ex_mem && (RegisterRd_ex_mem != 0) && (RegisterRd_ex_mem == RegisterRs2))) begin
            ForwardDataMemWriteData = 2'b01;  // Forward from MEM/WB
        end else begin
            ForwardDataMemWriteData = 2'b00;  // No forwarding
        end
    end

endmodule
