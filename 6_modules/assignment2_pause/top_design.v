
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

    wire pause_pulse;

    button_debounce pause_db (
        .clk(clk),
        .noisy(pause),
        .clean(pause_pulse)
    );

    wire system_idle = (up_done == 1'b0) && (down_done == 1'b0) &&
                       (up_out == 4'd0) && (down_out == 4'hF);

    reg is_paused = 1'b0;

    // Track global pause state (one flip-flop)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            is_paused <= 1'b0;
        end else if (pause_pulse && !system_idle) begin
            is_paused <= ~is_paused;   // toggle pause
        end
    end

    wire go_pulse;

    button_debounce go_db (
        .clk(clk),
        .noisy(go),
        .clean(go_pulse)
    );

    // The divided clock
    wire divided_clk;

    clock_divider # (
        .COUNT_WIDTH(24),
        .MAX_COUNT(2000000 - 1)
    ) div (
        .clk(clk),
        .rst(rst),
        .out(divided_clk),
        .pause_sig(pause_sig)
    );

    // Remember if we're counting up or down
    always @ (posedge divided_clk or posedge rst) begin
        if (rst == 1'b1) begin
            counting_up <= 4'b1;
            // up_done <= 1'b0;
            // down_done <= 1'b0;
            // up_out <= 4'b0;
            // down_out <= 4'hF;
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

    wire go_allowed = go_pulse & system_idle;

    counter cnt_up (
        .clk(clk),
        .div_clk(divided_clk),
        .rst(rst),
        .go_sig( (go_allowed) | (down_done & ~is_paused) ),
        .pause_sig(pause_pulse),
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
        .go_sig( up_done & ~is_paused ),
        .pause_sig(pause_pulse),
        .out(down_out),
        .done_sig(down_done)
    );


endmodule
