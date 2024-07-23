//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/10 16:50:09
// Design Name: 
// Module Name: adder
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


module adder
(
    input wire [31:0] a,     // 32-bit input signal a
    input wire [31:0] b,     // 32-bit input signal b
    output wire [31:0] sum   // 32-bit output signal sum
);

    // Addition operation
    assign sum = a + b;

endmodule
