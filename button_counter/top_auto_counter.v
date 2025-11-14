// Count up on each button press and display on LEDs

module top_auto_counter (

    // Inputs
    input       [1:0]   pmod,
    input               real_clk,

    // Output
    output reg  [3:0]   led
);

    localparam integer CLK_HZ = 12_000_000;

    wire rst;
    wire clk = real_clk;

    // Reset is the inverse of the first button
    assign rst = ~pmod[0];

    wire debounced_rst;

    button_debounce #(
        .CLK_HZ(12_000_000),
        .DEBOUNCE_MS(20)
    ) db_rst (
        .clk(real_clk),
        .noisy(rst),
        .clean(debounced_rst)
    );

    reg last_rst;
    reg [23:0] counter = 0;

    always @ (posedge real_clk) begin

        last_rst <= debounced_rst;

        if (debounced_rst & ~last_rst) begin
            led <= 4'b0;
            counter <= 0;
        end
        else if (debounced_rst) begin
            counter <= 24'b0;
        end
        else begin
            if (!(counter == CLK_HZ-1)) begin
                counter <= counter + 1'b1;
            end
            else begin
                counter <= 24'b0;
                led <= led + 4'b1;
            end
        end

    end

endmodule
