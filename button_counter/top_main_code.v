// Count up on each button press and display on LEDs

module top (

    // Inputs
    input       [1:0]   pmod,
    input               real_clk,

    // Output
    output reg  [3:0]   led
);

    wire rst;
    wire clk;

    // Reset is the inverse of the first button
    assign rst = ~pmod[0];

    // Clock signal is the inverse of second button
    assign clk = ~pmod[1];

    wire debounced_clk;

    button_debounce #(
        .CLK_HZ(12_000_000),
        .DEBOUNCE_MS(20)
    ) db_clk (
        .clk(real_clk),
        .noisy(clk),
        .clean(debounced_clk)
    );

    reg last_clk = 1'b0;

    wire clk_pulse = debounced_clk & ~last_clk;

    always @ (posedge real_clk or posedge rst) begin
        if (rst == 1'b1) begin
            led <= 4'd0;
        // Define the state transitions
        end else begin
            if (clk_pulse) begin
                led <= led + 1'b1;
            end
            last_clk <= debounced_clk;
        end

    end

endmodule
