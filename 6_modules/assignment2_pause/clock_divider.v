// Clock divider
module clock_divider # (
    parameter                   COUNT_WIDTH = 24,
    parameter   [COUNT_WIDTH:0] MAX_COUNT   = 6000000 - 1
) (

    // Inputs
    input       clk,
    input       rst,
    input wire  pause_sig,

    // Outputs
    output  reg out
);

    // Internal signals
    reg [COUNT_WIDTH:0] count;
    reg toggle = 1'b0;

    // Clock divider
    always @ (posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            count <= 0;
            toggle <= 1'b0;
            out <= 0;
        // end else if (pause_sig == 1'b1) begin
        end else if (count == MAX_COUNT) begin
            count <= 0;
            toggle <= ~toggle;
            out <= toggle;
        end else begin
            count <= count + 1;
            out <= 1'b0;
        end
    end

endmodule
