module counter # (
    parameter                   COUNT_WIDTH = 24,
    parameter   [COUNT_WIDTH:0] MAX_COUNT   = 6000000 - 1,
    parameter                   UP          = 1
) (
    input wire          clk,
    input wire          div_clk,
    input wire          rst,
    input wire          go_sig,
    input wire          pause_sig,

    output reg [3:0]    out,
    output reg          done_sig
);
    localparam STATE_IDLE           = 2'd0;
    localparam STATE_COUNTING       = 2'd1;
    localparam STATE_PAUSE          = 2'd2;

    reg [1:0]   state       =   STATE_IDLE;
    reg [1:0]   prev_state  =   STATE_IDLE;

    always @ (posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            state <= STATE_IDLE;
        end else if (pause_sig == 1'b1 && state == STATE_COUNTING) begin
            // out <= out;
            // pause_sig <= 0;
            prev_state <= state;
            state <= STATE_PAUSE;
        end else begin
            if (go_sig == 1'b1 && ( state == STATE_IDLE || state == STATE_PAUSE ) ) begin
                state <= STATE_COUNTING;
                prev_state <= STATE_IDLE;
            end else if (pause_sig == 1'b1 && state == STATE_PAUSE) begin
                state <= prev_state;
            end

            if (div_clk) begin
                case (state)

                STATE_IDLE: begin
                    done_sig <= 1'b0;
                end

                STATE_PAUSE: begin
                end

                STATE_COUNTING: begin
                    // Check if done (counting up)
                    if (UP == 1'b1 && out == 4'hF) begin
                        done_sig <= 1'b1;
                        state <= STATE_IDLE;
                    end
                    // Check if done (counting down)
                    else if (UP == 1'b0 && out == 0) begin
                        done_sig <= 1'b1;
                        state <= STATE_IDLE;
                    end

                end

                default: state <= STATE_IDLE;

                endcase
            end
        end
    end

    // Handle the out counter
    always @ (posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            out <= 4'd0;
        end else begin
            if (div_clk) begin
                case (state)
                STATE_IDLE: begin
                    if (UP == 1'b1) begin
                        out <= 4'd0;
                    end else begin
                        out <= 4'hF;
                    end
                end
                STATE_PAUSE: begin
                end
                STATE_COUNTING: begin
                    if (UP == 1'b1) begin
                        if (out != 4'hF) out <= out + 1;
                    end else begin
                        if (out != 4'h0) out <= out - 1;
                    end
                end

                default: out <= out;
                endcase
            end
        end
    end

endmodule
