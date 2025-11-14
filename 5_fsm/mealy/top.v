// State machine that counts up when button is pressed
module fsm_mealy (

    // Inputs
    input               clk,
    input               rst_btn,
    input               go_btn,

    // Outputs
    output  reg [3:0]   led,
    output  reg         done_sig,
);

    localparam STATE_IDLE       = 2'd0;
    localparam STATE_COUNTING   = 2'd1;

    localparam MAX_CLK_COUNT    = 24'd1500000;
    localparam MAX_LED_COUNT    = 4'hF;

    // Internal signals
    wire rst;
    wire go;

    // Internal storage elements
    reg         div_clk;
    reg [1:0]   state = STATE_IDLE;
    reg [23:0]  clk_count;

    // For detecting a posedge of div_clk while operating in clk domain
    reg         div_clk_prev;
    wire        div_clk_posedge;

    // Invert active-low buttons
    assign rst_raw  = ~rst_btn;
    assign go_raw   = ~go_btn;


    wire debounced_go;
    wire debounced_rst;

    button_debounce #(
        .CLK_HZ(12_000_000),
        .DEBOUNCE_MS(20)
    ) db_go (
        .clk(clk),
        .noisy(go_raw),
        .clean(debounced_go)
    );

    button_debounce #(
        .CLK_HZ(12_000_000),
        .DEBOUNCE_MS(20)
    ) db_rst (
        .clk(clk),
        .noisy(rst_raw),
        .clean(debounced_rst)
    );

    reg last_go = 1'b0;
    reg last_rst = 1'b0;

    wire rst = debounced_rst & ~last_rst;
    wire go = debounced_go & ~last_go;

    always @ (posedge clk) begin
        last_go <= debounced_go;
        last_rst <= debounced_rst;
    end


    // Clock divider
    always @ (posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            clk_count <= 24'b0;
        end else if (clk_count == MAX_CLK_COUNT) begin
            clk_count <= 24'b0;
            div_clk <= ~div_clk;
        end else begin
            clk_count <= clk_count + 1;
        end
    end

    always @ (posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            div_clk_prev <= 1'b0;
        end else begin
            div_clk_prev <= div_clk;
        end
    end
    assign div_clk_posedge = (div_clk == 1'b1) && (div_clk_prev == 1'b0);

    // State transition logic
    always @ (posedge clk or posedge rst) begin

        // On reset, return to idle state
        if (rst == 1'b1) begin
            state <= STATE_IDLE;

        // Define the state transitions
        end else begin

            // Immediate: go button transition for responsive UX
            if (go == 1'b1 && state == STATE_IDLE) begin
                state <= STATE_COUNTING;
            end

            if (div_clk_posedge) begin
                case (state)

                    // Wait for go button to be pressed
                    STATE_IDLE: begin
                        done_sig <= 1'b0;
                    end

                    // Go from counting to done if counting reaches max
                    STATE_COUNTING: begin
                        if (led == MAX_LED_COUNT) begin
                            done_sig <= 1'b1;
                            state <= STATE_IDLE;
                        end
                    end

                    // Go to idle if in unknown state
                    default: state <= STATE_IDLE;
                endcase
            end
        end
    end

    // Handle the LED counter
    always @ (posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            led <= 4'd0;
        end else begin
            if (div_clk_posedge) begin
                if (state == STATE_COUNTING) begin
                    led <= led + 1;
                end else begin
                    led <= 4'd0;
                end
            end
        end
    end

endmodule
