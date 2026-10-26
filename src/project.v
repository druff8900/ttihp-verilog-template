`default_nettype none

module tt_um_uart_tx_project (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Wire declarations
    wire tx_out;
    wire tx_busy;

    // Instantiate the UART Transmitter
    uart_tx #(
        .CLKS_PER_BIT(87) // Adjust this based on your clock speed / baud rate target
    ) uart_transmitter (
        .clk      (clk),
        .rst_n    (rst_n),
        .tx_start (uio_in[0]), // Using bidirectional pin 0 as the 'start' input button
        .tx_data  (ui_in),     // Using all 8 dedicated input pins for data
        .tx_out   (tx_out),
        .tx_busy  (tx_busy)
    );

    // Map outputs
    assign uo_out[0]   = tx_out;
    assign uo_out[1]   = tx_busy;
    assign uo_out[7:2] = 6'b000000; // Ground unused outputs

    // Set bidirectional pins configuration
    // uio_oe defines pin direction: 0 = input, 1 = output.
    // We are using uio_in[0] as input, so set its OE to 0. 
    assign uio_oe  = 8'b00000000; 
    assign uio_out = 8'b00000000; // Ground unused bidirectional outputs

    // Prevent warnings on unused inputs
    wire _unused = &{ena, uio_in[7:1]};

endmodule
