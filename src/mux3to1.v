//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/10 16:15:07
// Design Name: 
// Module Name: mux3to1
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

module mux3to1 #(parameter WIDTH = 32)
(
    input wire [WIDTH-1:0] in0,    // Input signal 0
    input wire [WIDTH-1:0] in1,    // Input signal 1
    input wire [WIDTH-1:0] in2,    // Input signal 2
    input wire [1:0] sel,          // Select signal (extended to 2 bits)
    output reg [WIDTH-1:0] out    // Output signal (changed to reg type)
);

    // Select input based on select signal
    always @(*) begin
        case (sel)
            2'b00: out = in0;    // Select input 0
            2'b01: out = in1;    // Select input 1
            2'b10: out = in2;    // Select input 2
            default: out = in0;  // Default to select input 0
        endcase
    end

endmodule
