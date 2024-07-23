//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/10 16:57:03
// Design Name: 
// Module Name: Instruction_Memory
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

module Instruction_Memory
#(
    parameter DEPTH = 256 // Default memory depth is 256
)
(
    input wire clk,            // Clock signal
    input wire reset,          // Reset signal
    input wire PCSrc,          // Branch select signal
    input wire [31:0] pc,      // 32-bit PC input
    output reg [31:0] instr,   // 32-bit instruction output
    input wire enable,         // Enable signal
    input wire write_mem_req,  // Memory write request signal
    input wire target_mem_type, // Target memory type
    input wire [8:0] target_addr, // Target memory address
    input wire [31:0] uart_rx_data_in, // UART data input
    input wire rw_flag,        // Read/Write flag
    output reg [41:0] uart_tx_data_out, // UART data output
    output reg instr_mem_tx_data_ready  // Data ready signal
);
	
	// List all unused inputs to prevent warnings
	wire _unused = &{pc[31:$clog2(DEPTH)+2], pc[1:0]};

    // Calculate the number of address bits
    function integer addr_bits;
        input integer depth;
        begin
            addr_bits = 0;
            while (depth > 1) begin
                addr_bits = addr_bits + 1;
                depth = depth >> 1;
            end
        end
    endfunction
    
    localparam ADDR_BITS = addr_bits(DEPTH);

    // Define parameterized instruction memory
    reg [31:0] memory [0:DEPTH-1];

    // Declare integer variable in module definition
    integer i;

    // Initialize instruction memory
    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            memory[i] = 32'h00000013; // Initialize all to nop
        end
        /*
        // Default firmware
		memory[0] = 32'h00000013; // 0x0000: nop
		memory[1] = 32'h00000093; // 0x0004: addi x1, x0, 0
		memory[2] = 32'h00900113; // 0x0008: addi x2, x0, 9
		memory[3] = 32'h000f4237; // 0x000c: lui x4, 0x000f4
		memory[4] = 32'h24020213; // 0x0010: addi x4, x4, 0x240
		memory[5] = 32'h00000013; // 0x0014: nop
		memory[6] = 32'h00000013; // 0x0018: nop
		memory[7] = 32'h00000013; // 0x001c: nop
		memory[8] = 32'h00000013; // 0x0020: nop
		memory[9] = 32'h00102023; // 0x0024: sw x1, 0(x0)
		memory[10] = 32'h00002183; // 0x0028: lw x3, 0(x0)
		memory[11] = 32'h00100293; // 0x002c: addi x5, x0, 1
		memory[12] = 32'h00128293; // 0x0030: addi x5, x5, 1
		memory[13] = 32'hfe521ee3; // 0x0034: bne x4, x5, -4
		memory[14] = 32'h00108093; // 0x0038: addi x1, x1, 1
		memory[15] = 32'h00000013; // 0x003c: nop
		memory[16] = 32'hfe2190e3; // 0x0040: bne x3, x2, -44
		memory[17] = 32'h00000093; // 0x0044: addi x1, x0, 0
		memory[18] = 32'h00000193; // 0x0048: addi x3, x0, 0
		memory[19] = 32'h01800067; // 0x004c: jalr x0, 32(x0)
		*/

    end

    // Sequential logic: read instruction based on PC value
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            instr <= 32'h00000013; // Output nop instruction on reset
        end else if (PCSrc) begin
            instr <= 32'h00000013; // Clear instr when PCSrc is active
        end else begin
            instr <= memory[pc[ADDR_BITS+1:2]]; // Use parameterized address bits
        end
    end

    // Sequential logic: write or read memory
    always @(posedge clk) begin
        if (!enable && write_mem_req && target_mem_type) begin
            if (rw_flag) begin
                memory[target_addr[ADDR_BITS-1:0]] <= uart_rx_data_in; // Write data to target memory address
                instr_mem_tx_data_ready <= 0; // Data not ready after write operation
            end else begin
                uart_tx_data_out <= {1'b1, target_addr, memory[target_addr[ADDR_BITS-1:0]]}; // Read data to UART data output
                instr_mem_tx_data_ready <= 1; // Data ready after read operation
            end
        end else begin
            instr_mem_tx_data_ready <= 0; // Data not ready in other cases
        end
    end

endmodule
