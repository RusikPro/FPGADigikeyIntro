module button_debounce #(
    parameter integer CLK_HZ        = 12_000_000, // 12 thousand ticks/second
    parameter integer DEBOUNCE_MS   = 20
) (
    input wire  clk,
    input wire  noisy,

    output reg  clean
);

    localparam integer CTR_MAX = (CLK_HZ / 1000) * DEBOUNCE_MS;

    reg [17:0] counter = 0;
    reg prev = 0;

    always @ (posedge clk) begin
        if (noisy != prev) begin
            // Can change multiple time during jumps
            prev <= noisy;
            // So, each time reset counter
            counter <= 0;
        end else if (counter < CTR_MAX) begin
            // Waiting in this state.
            counter <= counter + 1;
        end else begin
            // Stable long enough, as counter reached CTR_MAX (20ms)
            clean <= prev;
        end
    end

endmodule

