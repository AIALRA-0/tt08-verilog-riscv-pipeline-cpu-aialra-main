//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/10 16:03:20
// Design Name: 
// Module Name: PC
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


module PC 
(
    input wire clk,          // Clock signal
    input wire reset,        // Reset signal
    input wire enable,       // PC update enable signal
    input wire [31:0] pc_in, // 32-bit address input
    output reg [31:0] pc_out // 32-bit address output
);

    // Execute on rising edge of clock or when reset signal is active
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Set pc_out to 0 on reset
            pc_out <= 32'b0;
        end
        else if (!enable) begin
            // Do not update pc_out when not enabled
            pc_out <= pc_out;
        end else begin
            // Otherwise, set pc_out to the value of pc_in
            pc_out <= pc_in;
        end
    end

endmodule
