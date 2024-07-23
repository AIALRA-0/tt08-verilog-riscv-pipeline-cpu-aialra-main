`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/10 16:15:07
// Design Name: 
// Module Name: mux2to1
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

module mux2to1 #(parameter WIDTH = 32)
(
    input wire [WIDTH-1:0] in0,    // Input signal 0
    input wire [WIDTH-1:0] in1,    // Input signal 1
    input wire sel,                // Select signal
    output wire [WIDTH-1:0] out    // Output signal
);

    // Select input based on select signal
    assign out = sel ? in1 : in0;

endmodule
