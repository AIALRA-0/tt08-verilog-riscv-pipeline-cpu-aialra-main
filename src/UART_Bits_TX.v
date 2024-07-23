//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/11 17:07:30
// Design Name: 
// Module Name: UART_Bits_TX
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

module UART_Bits_TX #(
    parameter DATA_BITS = 8  // Default data bit width is 8
)(
    input wire clk,       // Clock signal
    input wire reset,     // Reset signal - active low
    input wire start,     // Start transmission signal
    input wire [DATA_BITS-1:0] data_in, // Input data with customizable bit width
    output reg tx,        // UART transmit pin
    output reg done       // Transmission complete signal
);

    // State definitions
    localparam IDLE       = 3'd0,  // Idle state
               START_BIT  = 3'd1,  // Send start bit state
               SEND_BITS  = 3'd2,  // Send data bits state
               STOP_BIT   = 3'd3,  // Send stop bit state
               DONE       = 3'd4,  // Done state
               START_NEXT = 3'd5;  // Start next byte state

    reg [2:0] state, next_state;  // Current and next state
    reg [$clog2(DATA_BITS)-1:0] bit_counter;  // Bit counter to track sent bits
    reg [DATA_BITS-1:0] data_reg;  // Data register to store data to be sent

    // State register: update current state on rising edge of clock or when reset is active
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;  // Enter idle state on reset
            bit_counter <= 0;  // Reset bit counter
        end else begin
            state <= next_state;  // Enter next state
            if (state == SEND_BITS) begin
                bit_counter <= bit_counter + 1;  // Update bit counter in SEND_BITS state
            end else begin
                bit_counter <= 0;  // Reset bit counter in other states
            end
        end
    end

    // On rising edge of clock, when start signal is active, load input data into data register
    always @(posedge clk) begin
        if (start)
            data_reg <= data_in;  // Load input data
    end

    // State machine logic: determine next state and output based on current state and input signals
    always @(*) begin
        next_state = state;  // Default to current state
        done = 0;            // Default transmission not done
        tx = 1;              // Default transmit pin stays high

        case (state)
            IDLE: begin
                if (start) begin
                    next_state = START_BIT;  // If start signal is active, enter start bit state
                end
            end
            START_BIT: begin
                tx = 0;  // Send start bit (logic 0)
                next_state = SEND_BITS;  // Enter send data bits state
            end
            SEND_BITS: begin
                tx = data_reg[bit_counter];  // Send current bit of data
                if (bit_counter == DATA_BITS-1) begin  // If all data bits are sent
                    next_state = STOP_BIT;  // Enter stop bit state
                end
            end
            STOP_BIT: begin
                tx = 1;  // Send stop bit (logic 1)
                next_state = DONE;  // Enter done state
            end
            DONE: begin
                done = 1;  // Transmission complete signal active
                if (start) begin
                    next_state = START_NEXT;  // If another byte to send, enter start next byte state
                end else begin
                    next_state = IDLE;  // Otherwise, return to idle state
                end
            end
            START_NEXT: begin
                next_state = START_BIT;  // Directly enter start bit state
            end
			default: begin
				next_state = IDLE; 
			end
        endcase
    end

endmodule
