`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/10 17:28:44
// Design Name: 
// Module Name: Register_File
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


module Register_File
(
    input wire clk,                // Clock signal
    input wire reset,              // Reset signal
    input wire [4:0] read_register1, // Address of the first register to read (rs1)
    input wire [4:0] read_register2, // Address of the second register to read (rs2)
    input wire [4:0] write_register, // Address of the register to write (rd)
    input wire [31:0] write_data,  // Data to be written to the register
    input wire RegWrite,           // Control signal for register file write operation
    output wire [31:0] read_data1, // Data read from rs1
    output wire [31:0] read_data2  // Data read from rs2
);

    // Define 32 32-bit registers
    reg [31:0] registers [31:0];

    // Initialize register file
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end

    // Read operation (combinational logic) with forwarding logic
    assign read_data1 = (read_register1 == write_register && RegWrite && write_register != 0) ? write_data : registers[read_register1];
    assign read_data2 = (read_register2 == write_register && RegWrite && write_register != 0) ? write_data : registers[read_register2];

    // Write operation (sequential logic)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (RegWrite) begin
            if (write_register != 0) begin // x0 register is always 0
                registers[write_register] <= write_data;
            end
        end
    end

endmodule
