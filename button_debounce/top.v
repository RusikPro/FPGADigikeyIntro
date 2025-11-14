module top (
    input  wire clk,     // 12 MHz
    input  wire pmod_0,
    output reg  led
);

    wire BTN = ~pmod_0;

    wire btn_pressed;

    button_debounce #(
        .CLK_HZ(12_000_000),
        .DEBOUNCE_MS(20)
    ) db (
        .clk(clk),
        .noisy(BTN),
        .clean(btn_pressed)
    );

    // toggle LED on press
    always @(posedge btn_pressed) begin
        led <= ~led;
    end
endmodule
