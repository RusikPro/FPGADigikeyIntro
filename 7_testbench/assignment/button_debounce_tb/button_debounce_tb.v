// Defines timescale for simulation: <time_unit> / <time_precision>
`timescale 1 ns / 10 ps

// Define testbench
module button_debounce_tb();

    // Internal signals
    wire clean;

    // Storage elements (set initially to 0)
    reg     clk   = 0;
    reg     noisy = 0;

    // Simulation time
    localparam DURATION = 20000;

    // Generate ~12 MHz clock: period = 2 * 41.667 ns ≈ 83.33 ns
    always begin
        #41.667
        clk <= ~clk;
    end

    // Instantiate the unit under test (UUT).
    // Override params so CTR_MAX = (CLK_HZ/1000)*DEBOUNCE_MS is small enough
    // to reach within the simulation window:
    //   (12000 / 1000) * 1 = 12 clock cycles (~1 us) instead of 240,000.
    button_debounce #(
        .CLK_HZ(12_000),
        .DEBOUNCE_MS(1)
    ) uut (
        .clk(clk),
        .noisy(noisy),
        .clean(clean)
    );

    // Stimulus: simulate a bouncy button press then a bouncy release
    initial begin

        // Settle at 0
        #500;

        // --- Bouncy press ---
        noisy = 1'b1; #120;
        noisy = 1'b0; #90;
        noisy = 1'b1; #60;
        noisy = 1'b0; #40;
        noisy = 1'b1;          // finally settles high

        // Hold long enough to pass the debounce window (> ~1 us)
        #4000;

        // --- Bouncy release ---
        noisy = 1'b0; #100;
        noisy = 1'b1; #70;
        noisy = 1'b0;          // finally settles low

        // Hold low past the debounce window
        #4000;

        // --- Second clean press (no bounce) ---
        noisy = 1'b1;
        #4000;
        noisy = 1'b0;

    end

    // Run simulation (output to .vcd file)
    initial begin

        // VCD dumpfile is provided by Apio via vvp -dumpfile; do not set here
        $dumpvars(0, button_debounce_tb);

        // Wait for given amount of time for simulation to complete
        #(DURATION)

        // Notify and end simulation
        $display("Finished!");
        $finish;
    end

endmodule
