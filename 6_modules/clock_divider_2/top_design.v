// Top-level design that produces 2 different divided clocks
module top_design (

    // Inputs
    input           clk,
    input           rst_btn,

    // Outputs
    output  [1:0]   led
);

    // Internal signal
    wire rst;

    // Invert active-low button
    assign rst = ~rst_btn;

    // Instantiate the first clock divider module
    clock_divider # (
        .COUNT_WIDTH(21),
        .MAX_COUNT(1500000 - 1)
    ) div_1 (
        .clk(clk),
        .rst(rst),
        .out(led[0])
    );

    // Instantiate the second clock divider module
    clock_divider div_2 (
        .clk(clk),
        .rst(rst),
        .out(led[1])
    );

endmodule
