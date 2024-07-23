//////////////////////////////////////////////////////////////////////////////////
// Company: AIALRA
// Engineer: Lucas Ding
// 
// Create Date: 2024/07/10 15:58:13
// Design Name: 
// Module Name: UART_Bytes_RX
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

module UART_Bytes_RX #(
    parameter BYTE_COUNT = 4,  // Default receive 4 bytes
    parameter DATA_BITS = 12   // Number of data bits per byte
)(
    input wire clk,              // Clock signal
    input wire reset,            // Reset signal 
    input wire rx,               // UART receive pin
    output reg [31:0] data_out,  // Output multi-byte data
    output reg done,             // Receive complete signal
    output reg [8:0] target_addr,// Target memory address
    output reg target_mem_type,  // Target memory type
    output reg rw_flag           // Read/Write flag
);

    // State definitions
    localparam IDLE         = 3'd0,  // Idle state
               HANDSHAKE    = 3'd1,  // Handshake state
               RECEIVE_BYTE = 3'd2,  // Receive byte state
               DONE         = 3'd3;  // Done state

    reg [2:0] state, next_state;  // Current and next state
    reg [3:0] byte_counter;  // Byte counter to track received bytes
    wire [DATA_BITS-1:0] current_byte;  // Currently received byte
    wire byte_done;  // Byte receive complete signal
    reg [DATA_BITS-1:0] header;  // Packet header information

    // Instantiate UART receive module
    UART_Bits_RX #(
        .DATA_BITS(DATA_BITS)
    ) uart_rx_inst (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(current_byte),
        .done(byte_done)
    );

    // State register: update current state on rising edge of clock or when reset is active
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;  // Enter idle state on reset
            byte_counter <= 0;  // Reset byte counter
            data_out <= 0;  // Clear output data on reset
        end else begin
            state <= next_state;  // Enter next state
            if (state == IDLE) begin
                byte_counter <= 0;  // Reset byte counter in idle state
            end else if (state == RECEIVE_BYTE && byte_done) begin
                byte_counter <= byte_counter + 1;  // Increment byte counter in RECEIVE_BYTE state when byte is done
                data_out[(BYTE_COUNT-1-byte_counter)*8 +: 8] <= current_byte[7:0];  // Store the lower 8 bits of the current byte in the output data
            end
        end
    end
    

    // State machine logic: determine next state and output based on current state and input signals
    always @(*) begin
        next_state = state;  // Default to current state
        done = 0;  // Default receive not done

        case (state)
            IDLE: begin
                if (rx == 0) begin  // Detect start bit
                    next_state = HANDSHAKE;  // Enter handshake state
                end
            end
            HANDSHAKE: begin
                if (byte_done) begin
                    header = current_byte;  // Read packet header
                    if (header[11:10] == 2'b11) begin  // Confirm write handshake packet
                        rw_flag = header[11];
                        target_mem_type = header[9];
                        target_addr = header[8:0];
                        next_state = RECEIVE_BYTE;  // Enter receive byte state
                    end else if (header[11:10] == 2'b01) begin  // Confirm read handshake packet
                        rw_flag = header[11];
                        target_mem_type = header[9];
                        target_addr = header[8:0];
                        next_state = DONE;  // Directly enter done state
                    end else begin
                        next_state = IDLE;  // Non-handshake packet, return to idle state
                    end
                end
            end
            RECEIVE_BYTE: begin
                if (byte_done) begin
                    if (byte_counter == BYTE_COUNT-1) begin
                        next_state = DONE;  // If all bytes are received, enter done state
                    end else begin
                        next_state = RECEIVE_BYTE;  // Otherwise, continue receiving next byte
                    end
                end
            end
            DONE: begin
                done = 1;  // Receive complete signal active
                next_state = IDLE;  // Return to idle state, waiting for the next receive
            end
			default: begin
				next_state = IDLE;  // Default to IDLE state
			end
        endcase
    end

endmodule
