//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/11 17:09:44
// Design Name: 
// Module Name: RISCV_Pipeline_Display_Counter
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

module RISCV_Pipeline_Display_Counter 
(
    input wire clk,
    input wire reset,
    input wire enable,
    input wire uart_rx,
    output wire uart_tx, // uart_tx
    output wire [6:0] seg // Seven-segment display output
);

    // Data memory read count value
    wire [31:0] count_value;

    // CPU instance
    RISCV_Pipeline_CPU #(
        .INSTR_MEM_DEPTH(128), // Specify instruction memory depth
        .DATA_MEM_DEPTH(128)   // Specify data memory depth
    ) cpu_inst (
        .clk(clk), // Clock
        .reset(reset),
        .enable(enable),  // Get enable signal from ui_in
        .uart_rx(uart_rx),  // Get UART RX signal from ui_in
        .uart_tx(uart_tx),  // Send UART TX signal to uo_out
		.data_mem0(count_value) // Send Data memory[0] read to count value
    );

    // Seven-segment display module
    Seven_Segment_Display display_inst 
    (
        .value(count_value[3:0]), // Only take the lower 4 bits
        .seg(seg)
    );
    
    wire _unused = &{count_value[31:4]};

endmodule
