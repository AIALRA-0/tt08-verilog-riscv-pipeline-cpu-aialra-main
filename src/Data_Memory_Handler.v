//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/18 22:13:45
// Design Name: 
// Module Name: Data_Memory_Handler
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


module Data_Memory_Handler 
(
    input wire [2:0] DataMemOutOp, // Memory operation signal
    input wire MemRead,            // Memory read enable signal
    input wire MemWrite,           // Memory write enable signal
    input wire [31:0] mem_data_in, // Data read from memory
    input wire [31:0] write_data_in, // Data to be written to memory
    output reg [31:0] mem_data_out, // Processed data output
    output reg [31:0] write_data_out // Processed data input
);

    always @(*) begin
        if (MemRead) begin
            case (DataMemOutOp)
                3'b001: mem_data_out = mem_data_in; // lw
                3'b010: mem_data_out = {{24{mem_data_in[7]}}, mem_data_in[7:0]}; // lb
                3'b011: mem_data_out = {{16{mem_data_in[15]}}, mem_data_in[15:0]}; // lh
                3'b100: mem_data_out = {24'b0, mem_data_in[7:0]}; // lbu
                3'b101: mem_data_out = {16'b0, mem_data_in[15:0]}; // lhu
                default: mem_data_out = mem_data_in; // Default lw
            endcase
        end else if (MemWrite) begin
            case (DataMemOutOp)
                3'b001: write_data_out = write_data_in; // sw
                3'b010: write_data_out = {24'b0, write_data_in[7:0]}; // sb
                3'b011: write_data_out = {16'b0, write_data_in[15:0]}; // sh
                default: write_data_out = write_data_in; // Default sw
            endcase
        end else begin
            mem_data_out = 32'b0;
            write_data_out = 32'b0;
        end
    end

endmodule
