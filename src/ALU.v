//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/10 20:15:19
// Design Name: 
// Module Name: ALU
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

module ALU
(
    input wire [31:0] a,         // First operand
    input wire [31:0] b,         // Second operand
    input wire [5:0] alu_control,// ALU control signal
    output reg [31:0] result,    // Calculation result
    output reg zero              // ZERO signal
);

    reg [63:0] mult_result; // Used to store 64-bit multiplication result

    always @(*) begin
        case (alu_control)
            6'b000001: result = a + b;  // Addition
            6'b000010: result = a - b;  // Subtraction
            6'b000011: result = a & b;  // AND operation
            6'b000100: result = a | b;  // OR operation
            6'b000101: result = a ^ b;  // XOR operation
            6'b001110: result = a << b[4:0]; // Logical left shift, 5 bits represent 32 bits
            6'b001111: result = a >> b[4:0]; // Logical right shift
            6'b010000: result = $signed(a) >>> b[4:0]; // Arithmetic right shift, keeping the sign bit
            6'b000110: result = $signed(a) * $signed(b); // Signed multiplication (only lower 32 bits)
            6'b000111: begin // High-order signed multiplication
                mult_result = $signed(a) * $signed(b);
                result = mult_result[63:32];
            end
            6'b001000: begin // High-order signed and unsigned mixed multiplication
                mult_result = $signed(a) * b;
                result = mult_result[63:32];
            end
            6'b001001: begin // High-order unsigned multiplication
                mult_result = a * b;
                result = mult_result[63:32];
            end
            6'b001010: begin // Signed division
                if (b != 0) begin
                    result = $signed(a) / $signed(b);
                end else begin
                    result = 32'h80000000; // Divide by zero, set result to minimum negative number to indicate exception
                end
            end
            6'b001011: begin // Unsigned division
                if (b != 0) begin
                    result = a / b;
                end else begin
                    result = 32'h80000000; // Divide by zero, set result to minimum negative number to indicate exception
                end
            end
            6'b001100: begin // Signed remainder
                if (b != 0) begin
                    result = $signed(a) % $signed(b);
                end else begin
                    result = 32'h80000000; // Divide by zero, set result to minimum negative number to indicate exception
                end
            end
            6'b001101: begin // Unsigned remainder
                if (b != 0) begin
                    result = a % b;
                end else begin
                    result = 32'h80000000; // Divide by zero, set result to minimum negative number to indicate exception
                end
            end
            // branch
            6'b011000: result = ($signed(a) < $signed(b)) ? 32'b0 : 32'b1; // Signed less than comparison
            6'b010101: result = (a < b) ? 32'b0 : 32'b1; // Unsigned less than comparison
            6'b010100: result = ($signed(a) >= $signed(b)) ? 32'b0 : 32'b1; // Signed greater than or equal comparison
            6'b010110: result = (a >= b) ? 32'b0 : 32'b1; // Unsigned greater than or equal comparison
            6'b010111: result = (a != b) ? 32'b0 : 32'b1; // bne comparison
            // compare
            6'b010001: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0; // Signed less than comparison
            6'b010010: result = (a < b) ? 32'b1 : 32'b0; // Unsigned less than comparison
            default: result = 32'b0;  // Default result
        endcase
        
        // Set ZERO signal when result is zero
        if (result == 0) begin
            zero = 1;
        end else begin
            zero = 0;
        end
    end

endmodule
