`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: AIALRA
// Engineer: Lucas Ding
// 
// Create Date: 2024/07/10 15:58:13
// Design Name: 
// Module Name: UART_Bytes_TX
// Project Name: 
// Target Devices: xc7a35tcpg236-1/basys3
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

module UART_Bytes_TX #(
    parameter BYTE_COUNT = 4,  // Default to send 4 bytes
    parameter DATA_BITS = 12   // Number of data bits per byte
)(
    input wire clk,            // Clock signal
    input wire reset,          // Reset signal 
    input wire start,          // Start transmission signal
    input wire [41:0] data_in, // Input multi-byte data, including target memory type, address, and actual data
    output wire tx,            // UART transmit pin
    output reg done            // Transmission complete signal
);

    // State definitions
    localparam IDLE      = 3'd0,  // Idle state
               SEND_BYTE = 3'd1,  // Send byte state
               WAIT_DONE = 3'd2,  // Wait for byte to be sent state
               DONE      = 3'd3;  // Done state

    reg [2:0] state, next_state;  // Current and next state
    reg [$clog2(BYTE_COUNT + 1)-1:0] byte_counter;  // Byte counter to track sent bytes
    reg [DATA_BITS-1:0] current_byte;  // Currently sent byte
    reg byte_start;  // Start sending byte signal
    wire byte_done;  // Byte sent complete signal

    // Extract target memory type, target address, and actual data from data_in signal
    wire target_mem = data_in[41];
    wire [8:0] target_addr = data_in[40:32];
    wire [31:0] data = data_in[31:0];

    // Instantiate UART transmit module
    UART_Bits_TX #(
        .DATA_BITS(DATA_BITS)
    ) uart_tx_inst (
        .clk(clk),
        .reset(reset),
        .start(byte_start),
        .data_in(current_byte),
        .tx(tx),
        .done(byte_done)
    );

    // State register: update current state on rising edge of clock or when reset is active
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;  // Enter idle state on reset
            byte_counter <= 0;  // Reset byte counter
        end else begin
            state <= next_state;  // Enter next state
            if (state == IDLE && start) begin
                byte_counter <= 0;  // Reset byte counter in idle state and start signal is active
            end else if (state == WAIT_DONE && byte_done) begin
                byte_counter <= byte_counter + 1;  // Increment byte counter in WAIT_DONE state when byte is done
            end
        end
    end

    // State machine logic: determine next state and output based on current state and input signals
    always @(*) begin
        next_state = state;  // Default to current state
        done = 0;  // Default transmission not done
        byte_start = 0;  // Default not start sending byte

        // Construct handshake packet
        if (byte_counter == 0) begin
            current_byte = {1'b0, 1'b1, target_mem, target_addr};  // Handshake packet data
        end else begin
            // Construct data packet
            current_byte = {4'b0000, data[(byte_counter-1)*8 +: 8]};  // Extract current byte from input data and construct data packet
        end

        case (state)
            IDLE: begin
                if (start) begin
                    next_state = SEND_BYTE;  // If start signal is active, enter send byte state
                end
            end
            SEND_BYTE: begin
                byte_start = 1;  // Start sending current byte
                next_state = WAIT_DONE;  // Enter wait for byte to be sent state
            end
            WAIT_DONE: begin
                if (byte_done) begin
                    if (byte_counter == BYTE_COUNT) begin
                        next_state = DONE;  // If all bytes are sent, enter done state
                    end else begin
                        next_state = SEND_BYTE;  // Otherwise, continue sending next byte
                    end
                end
            end
            DONE: begin
                done = 1;  // Transmission complete signal active
                next_state = IDLE;  // Return to idle state, waiting for the next transmission
            end
        endcase
    end

endmodule
