`default_nettype none
`timescale 1ns / 1ps

/* This testbench simply instantiates the module and creates a wave dump.
   The wave can be driven/tested by cocotb test.py.
*/
module tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Connect inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Replace tt_um_example with your module name:
  tt_um_aialra_riscv_pipeline_cpu user_project (

      // Include power ports for gate-level testing:
`ifdef GL_TEST
      .VPWR(1'b1),
      .VGND(1'b0),
`endif

      .ui_in  (ui_in),    // Dedicated input
      .uo_out (uo_out),   // Dedicated output
      .uio_in (uio_in),   // IO: input path
      .uio_out(uio_out),  // IO: output path
      .uio_oe (uio_oe),   // IO: enable path (active high: 0=input, 1=output)
      .ena    (ena),      // Enable - active high when the design is selected
      .clk    (clk),      // Clock
      .rst_n  (rst_n)     // Active low reset
  );

endmodule
