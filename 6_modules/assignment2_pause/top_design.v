
module main (

    // Inputs
    input               clk,
    input               rst_btn,
    input               go_btn,
    input               pause_btn,

    // Outputs
    output reg [3:0]    led
);

    // Active-high button signals
    wire rst   = ~rst_btn;
    wire go    = ~go_btn;
    wire pause = ~pause_btn;

    // Debounced button pulses
    wire go_pulse;
    wire pause_pulse;

    button_debounce go_db (
        .clk(clk),
        .noisy(go),
        .clean(go_pulse)
    );

    button_debounce pause_db (
        .clk(clk),
        .noisy(pause),
        .clean(pause_pulse)
    );

    // The divided clock
    wire divided_clk;

    clock_divider # (
        .COUNT_WIDTH(24),
        .MAX_COUNT(2000000 - 1)
    ) div (
        .clk(clk),
        .rst(rst),
        .out(divided_clk)
    );


     // Counter outputs
    wire [3:0] up_out;
    wire [3:0] down_out;
    wire       up_done;
    wire       down_done;

    // Enables for counters
    reg up_en;
    reg down_en;

    // Which direction is currently active (for LED mux)
    reg counting_up;

    // --------------------------- Main FSM -----------------------------------

    localparam S_IDLE        = 3'd0;
    localparam S_UP          = 3'd1;
    localparam S_DOWN        = 3'd2;
    localparam S_PAUSE_UP    = 3'd3;
    localparam S_PAUSE_DOWN  = 3'd4;

    reg [2:0] state = S_IDLE;
    reg       first_cycle = 1'b1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // After FPGA init or rst: always IDLE
            state       <= S_IDLE;
            up_en       <= 1'b0;
            down_en     <= 1'b0;
            counting_up <= 1'b1;
        end else if (first_cycle) begin
            // *** implicit reset on first clock after power‑up ***
            state       <= S_IDLE;
            up_en       <= 1'b0;
            down_en     <= 1'b0;
            counting_up <= 1'b1;
            first_cycle <= 1'b0;   // next cycles behave normally
        end else begin
            // Defaults each cycle; overridden in states
            up_en   <= 1'b0;
            down_en <= 1'b0;

            case (state)
                S_IDLE: begin

                    counting_up <= 1'b1;

                    // Only GO can leave IDLE
                    if (go_pulse) begin
                        // Start UP phase
                        state       <= S_UP;
                        up_en       <= 1'b1;
                        counting_up <= 1'b1;
                    end
                end

                S_UP: begin
                    counting_up <= 1'b1;
                    up_en       <= 1'b1;

                    // PAUSE can freeze only during counting
                    if (pause_pulse) begin
                        state <= S_PAUSE_UP;

                    end else if (up_done) begin
                        // UP finished -> go DOWN
                        state       <= S_DOWN;
                        down_en     <= 1'b1;
                        counting_up <= 1'b0;
                    end

                    // GO ignored while in UP (we don't check go_pulse here)
                end

                S_DOWN: begin
                    counting_up <= 1'b0;
                    down_en     <= 1'b1;

                    // PAUSE can freeze only during counting
                    if (pause_pulse) begin
                        state <= S_PAUSE_DOWN;

                    end else if (down_done) begin
                        // Eternal loop: after DOWN, go back to UP
                        state       <= S_UP;
                        up_en       <= 1'b1;
                        counting_up <= 1'b1;
                    end

                    // GO ignored while in DOWN
                end

                S_PAUSE_UP: begin
                    // Paused during UP, freeze counters
                    counting_up <= 1'b1;
                    // up_en = 0 (default), so counter is held

                    // While paused, GO must NOT change anything:

                    // PAUSE again resumes from same position
                    if (pause_pulse) begin
                        state <= S_UP;
                        up_en <= 1'b1;
                    end
                end

                S_PAUSE_DOWN: begin
                    // Paused during DOWN, freeze counters
                    counting_up <= 1'b0;
                    // down_en = 0 (default), so counter is held

                    // GO ignored here as well

                    // PAUSE again resumes from same position
                    if (pause_pulse) begin
                        state   <= S_DOWN;
                        down_en <= 1'b1;
                    end
                end

                default: begin
                    state       <= S_IDLE;
                    up_en       <= 1'b0;
                    down_en     <= 1'b0;
                    counting_up <= 1'b1;
                end
            endcase
        end
    end

    // LED mux
    always @(*) begin
        if (counting_up)
            led = up_out;
        else
            led = down_out;
    end

    // ------------ Counter instances ------------

    counter #(.UP(1)) cnt_up (
        .clk(clk),
        .div_clk(divided_clk),
        .rst(rst | first_cycle),
        .en(up_en),
        .out(up_out),
        .done_sig(up_done)
    );

    counter #(.UP(0)) cnt_down (
        .clk(clk),
        .div_clk(divided_clk),
        .rst(rst | first_cycle),
        .en(down_en),
        .out(down_out),
        .done_sig(down_done)
    );


endmodule
