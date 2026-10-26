`default_nettype none

module uart_tx #(
    parameter CLKS_PER_BIT = 87
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx_out,
    output reg        tx_busy
);

    localparam s_IDLE  = 3'b000;
    localparam s_START = 3'b001;
    localparam s_DATA  = 3'b010;
    localparam s_STOP  = 3'b011;

    reg [2:0] r_SM_Main;
    reg [7:0] r_Clock_Count;
    reg [2:0] r_Bit_Index;
    reg [7:0] r_Tx_Data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_SM_Main     <= s_IDLE;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
            tx_out        <= 1'b1; // Idle state of UART is high
            tx_busy       <= 1'b0;
            r_Tx_Data     <= 8'b0;
        end else begin
            case (r_SM_Main)
                s_IDLE: begin
                    tx_out        <= 1'b1;
                    r_Clock_Count <= 0;
                    r_Bit_Index   <= 0;
                    if (tx_start == 1'b1) begin
                        tx_busy   <= 1'b1;
                        r_Tx_Data <= tx_data;
                        r_SM_Main <= s_START;
                    end else begin
                        tx_busy   <= 1'b0;
                    end
                end

                s_START: begin
                    tx_out <= 1'b0; // Start bit is low
                    if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                        r_Clock_Count <= r_Clock_Count + 1;
                        r_SM_Main     <= s_START;
                    end else begin
                        r_Clock_Count <= 0;
                        r_SM_Main     <= s_DATA;
                    end
                end

                s_DATA: begin
                    tx_out <= r_Tx_Data[r_Bit_Index];
                    if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                        r_Clock_Count <= r_Clock_Count + 1;
                        r_SM_Main     <= s_DATA;
                    end else begin
                        r_Clock_Count <= 0;
                        if (r_Bit_Index < 7) begin
                            r_Bit_Index <= r_Bit_Index + 1;
                            r_SM_Main   <= s_DATA;
                        end else begin
                            r_Bit_Index <= 0;
                            r_SM_Main   <= s_STOP;
                        end
                    end
                end

                s_STOP: begin
                    tx_out <= 1'b1; // Stop bit is high
                    if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                        r_Clock_Count <= r_Clock_Count + 1;
                        r_SM_Main     <= s_STOP;
                    end else begin
                        tx_busy       <= 1'b0;
                        r_SM_Main     <= s_IDLE;
                    end
                end
                
                default: r_SM_Main <= s_IDLE;
            endcase
        end
    end
endmodule