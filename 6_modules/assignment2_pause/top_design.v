
module main (

    // Inputs
    input               clk,
    input               rst_btn,
    input               go_btn,
    input               pause_btn,

    // Outputs
    output reg [3:0]    led
);

    // Internal signal
    wire        rst;
    wire        go;
    wire        pause;
    wire        up_done;
    wire        down_done;
    wire [3:0]  up_out;
    wire [3:0]  down_out;

    reg         counting_up     = 1'b1;
    reg         is_pause        = 1'b0;

    // Invert active-low button
    assign rst      = ~rst_btn;
    assign go       = ~go_btn;
    assign pause    = ~pause_btn;

    wire pause_sig;

    assign pause_sig = is_pause;

    wire pause_pulse;

    button_debounce pause_db (
        .clk(clk),
        .noisy(pause),
        .clean(pause_pulse)
    );

    always @ (posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            is_pause <= 1'b0;
        end else if (pause_pulse) begin
            is_pause <= ~is_pause;
        end
    end

    // The divided clock
    wire divided_clk;

    clock_divider # (
        .COUNT_WIDTH(24),
        .MAX_COUNT(1500000 - 1)
    ) div (
        .clk(clk),
        .rst(rst),
        .out(divided_clk),
        .pause_sig(pause_sig)
    );


    wire go_pulse;

    button_debounce go_db (
        .clk(clk),
        .noisy(go),
        .clean(go_pulse)
    );

    // Remember if we're counting up or down
    always @ (posedge divided_clk or posedge rst) begin
        if (rst == 1'b1) begin
            counting_up <= 1'b1;
        end else begin
            if (up_done == 1'b1) begin
                counting_up <= 1'b0;
            end else if (down_done == 1'b1) begin
                counting_up <= 1'b1;
            end
        end
    end

    always @ ( * ) begin
        if (counting_up == 1'b1) begin
            led = up_out;
        end else begin
            led = down_out;
        end
    end

    wire done_sig;

    counter cnt_up (
        .clk(clk),
        .div_clk(divided_clk),
        .rst(rst),
        .go_sig(go_pulse | down_done),
        .out(up_out),
        .done_sig(up_done)
    );

    counter # (
        .COUNT_WIDTH(24),
        .MAX_COUNT(6000000 - 1),
        .UP(0)
    ) cnt_down (
        .clk(clk),
        .div_clk(divided_clk),
        .rst(rst),
        .go_sig(up_done),
        .out(down_out),
        .done_sig(down_done)
    );


endmodule
