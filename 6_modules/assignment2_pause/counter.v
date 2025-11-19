module counter # (
    parameter                   UP          = 1
) (
    input wire          clk,
    input wire          div_clk,
    input wire          rst,
    input wire          en,

    output reg [3:0]    out,
    output reg          done_sig
);

    // Handle the out counter
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            if (UP) begin
                out <= 4'd0;
            end else begin
                out <= 4'hF;
            end
            done_sig <= 1'b0;
        end else if (div_clk) begin
            if (!en) begin
                // idle / paused: hold value, clear done
                done_sig <= 1'b0;
            end else if (UP) begin
                if (out == 4'hF) begin
                    done_sig <= 1'b1;
                    out <= 4'b0;
                end else begin
                    out      <= out + 1'b1;
                    done_sig <= 1'b0;
                end
            end else begin
                if (out == 4'd0) begin
                    done_sig <= 1'b1;
                    out <= 4'hF;
                end else begin
                    out      <= out - 1'b1;
                    done_sig <= 1'b0;
                end
            end
        end
    end

endmodule
