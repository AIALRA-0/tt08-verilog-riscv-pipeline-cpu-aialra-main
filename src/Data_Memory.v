//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/10 20:49:33
// Design Name: 
// Module Name: Data_Memory
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

module Data_Memory
#(
    parameter DEPTH = 1024  // Depth of the data memory, default is 1024
)
(
    input wire clk,           // Clock signal
    input wire reset,         // Reset signal
    input wire [31:0] address, // Address input
    input wire [31:0] write_data, // Data to be written
    input wire MemWrite,      // Memory write enable signal
    input wire MemRead,       // Memory read enable signal
    output reg [31:0] read_data, // Data read out
    input wire enable,        // Enable signal
    input wire write_mem_req, // Memory write request signal
    input wire target_mem_type, // Target memory type
    input wire [8:0] target_addr, // Target memory address
    input wire [31:0] uart_rx_data_in, // UART data input
    input wire rw_flag,        // Read/Write flag
    output reg [41:0] uart_tx_data_out, // UART data output
    output reg data_mem_tx_data_ready, // Data ready signal
	output wire [31:0] data_mem0 // Data from mem[0]
);

	assign data_mem0 = memory[0];
	
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

    // Define data memory
    reg [31:0] memory [0:DEPTH-1];
    
    // Initialize data memory
    integer i;
    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            memory[i] = 32'b0;
        end
    end

    // Sequential logic: reset and write operations
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Clear memory on reset
            for (i = 0; i < DEPTH; i = i + 1) begin
                memory[i] <= 32'b0;
            end
            data_mem_tx_data_ready <= 0;
            uart_tx_data_out <= 42'b0; // Ensure uart_tx_data_out is cleared on reset
        end else begin
            if (MemWrite) begin
                memory[address[ADDR_BITS+1:2]] <= write_data; // Store write data to the corresponding address
                data_mem_tx_data_ready <= 0;
            end else if (!enable && write_mem_req && target_mem_type == 0) begin
                if (rw_flag) begin
                    memory[target_addr] <= uart_rx_data_in; // Write UART data to target address
                    data_mem_tx_data_ready <= 0;
                end else begin
                    uart_tx_data_out <= {1'b0, target_addr, memory[target_addr]}; // Read data to UART data output
                    data_mem_tx_data_ready <= 1; // Data ready after read operation
                end
            end else begin
                data_mem_tx_data_ready <= 0; // Data not ready in other cases
            end
        end
    end

    // Read operation (combinational logic)
    always @(*) begin
        if (reset) begin
            read_data = 32'b0;
        end else if (MemRead) begin
            read_data = memory[address[ADDR_BITS+1:2]];
        end else begin
            read_data = 32'b0;
        end
    end

endmodule
