/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_aialra_riscv_pipeline_cpu (
    input  wire [7:0] ui_in,    // Dedicated input
    output wire [7:0] uo_out,   // Dedicated output
    input  wire [7:0] uio_in,   // IO: input path
    output wire [7:0] uio_out,  // IO: output path
    output wire [7:0] uio_oe,   // IO: enable path (active high: 0=input, 1=output)
    input  wire       ena,      // Always 1 when the design is powered on, can be ignored
    input  wire       clk,      // Clock signal
    input  wire       rst_n     // Reset signal - active low
);

    wire reset;
    assign reset = !rst_n;
	
	// Data memory read count value
    wire [31:0] count_value;

    // CPU instance
    RISCV_Pipeline_CPU #(
        .INSTR_MEM_DEPTH(128), // Specify instruction memory depth
        .DATA_MEM_DEPTH(32)   // Specify data memory depth
    ) cpu_inst (
        .clk(clk), // Clock
        .reset(reset),
        .enable(ui_in[0]),  // Get enable signal from ui_in
        .uart_rx(ui_in[1]),  // Get UART RX signal from ui_in
        .uart_tx(uio_out[0]),  // Send UART TX signal to uo_out
		.data_mem0(count_value) // Send Data memory[0] read to count value
    );

    // Seven-segment display module
    Seven_Segment_Display display_inst 
    (
        .value(count_value[3:0]), // Only take the lower 4 bits
        .seg(uo_out[6:0])
    );

    // Configure uio_oe signal to ensure uio_out output is enabled, 0=input, 1=output
    assign uio_oe = 8'b11111111;

    // Unused pins
    assign uio_out[7:1] = 7'b0000000;
	
	// List all unused inputs to prevent warnings
	wire _unused = &{ui_in[7:2], uio_in, ena, count_value[31:4]};
	assign uo_out[7] = 0;
	
endmodule
