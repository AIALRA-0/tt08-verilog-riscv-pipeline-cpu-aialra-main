//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/11 17:07:30
// Design Name: 
// Module Name: UART_Bits_RX
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


module UART_Bits_RX #(
    parameter DATA_BITS = 8  // Default data bit width is 8
)(
    input wire clk,       // Clock signal
    input wire reset,     // Reset signal - active low
    input wire rx,        // UART receive pin
    output reg [DATA_BITS-1:0] data_out, // Output data with customizable bit width
    output reg done       // Receive complete signal
);

    // State definitions
    localparam IDLE         = 3'd0,  // Idle state
               RECEIVE_BITS = 3'd1,  // Receive data bits state
               STOP_BIT     = 3'd2,  // Receive stop bit state
               DONE         = 3'd3,  // Done state
               START_NEXT   = 3'd4;  // Start receiving next byte state

    reg [2:0] state, next_state;  // Current and next state
    reg [$clog2(DATA_BITS)-1:0] bit_counter;   // Bit counter to keep track of received bits
    reg [DATA_BITS-1:0] data_reg;  // Data register to store received data

    // State register: update current state on rising edge of clock or when reset is active
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;  // Enter idle state on reset
            bit_counter <= 0;  // Reset bit counter
            data_reg <= 0;     // Clear data register
        end else begin
            state <= next_state;  // Enter next state
            if (state == RECEIVE_BITS) begin
                data_reg[bit_counter] <= rx;  // Update data register in RECEIVE_BITS state
                bit_counter <= bit_counter + 1;  // Update bit counter in RECEIVE_BITS state
            end else begin
                bit_counter <= 0;  // Reset bit counter in other states
            end
        end
    end

    // State machine logic: determine next state and output based on current state and input signals
    always @(*) begin
        next_state = state;  // Default to current state
        done = 0;            // Default receive not done

        case (state)
            IDLE: begin
                if (rx == 0) begin  // Detect start bit (logic 0)
                    next_state = RECEIVE_BITS;  // Enter receive data bits state
                end else begin
                    next_state = IDLE;  // Return to idle state if start bit is not logic 0
                end
            end
            RECEIVE_BITS: begin
                if (bit_counter == DATA_BITS-1) begin  // If all data bits are received
                    next_state = STOP_BIT;  // Enter receive stop bit state
                end else begin
                    next_state = RECEIVE_BITS;  // Stay in receive data bits state
                end
            end
            STOP_BIT: begin
                if (rx == 1) begin  // Detect stop bit (logic 1)
                    data_out = data_reg;  // Output received data
                    next_state = DONE;  // Enter done state
                end else begin
                    next_state = IDLE;  // Return to idle state if stop bit is not logic 1
                end
            end
            DONE: begin
                done = 1;  // Receive complete signal active
                if (rx == 0) begin
                    next_state = START_NEXT;  // If another byte to receive, enter start next byte state
                end else begin
                    next_state = IDLE;  // Otherwise, return to idle state
                end
            end
            START_NEXT: begin
                next_state = RECEIVE_BITS;  // Directly enter receive data bits state
            end
        endcase
    end

endmodule
