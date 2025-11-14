
module Main #(
    parameter integer N = 3_000_000
) (
    input  CLK,   // 12MHz clock
    output LED0,
    output LED1,
    output LED2,
    output LED3,
    output LED4,
);


  reg [31:0] counter = 0;
  reg [4:0] leds = 0; // internal active-HIGH for the selected LED

  // counter: 0 .. 5*N-1
  always @(posedge CLK) begin
    if (counter == 7*N - 1)
      counter <= 0;
    else
      counter <= counter + 1;
  end

  // choose which LED is ON based on the range
  always @* begin
    leds = 5'b00000;                 // default: all off
    if      (counter < 1*N) leds = 5'b00010; // LED0 - far left
    else if (counter < 2*N) leds = 5'b00001; // LED1 - front
    else if (counter < 3*N) leds = 5'b01000; // LED2 - far right
    else if (counter < 4*N) leds = 5'b00100; // LED3 - back
    else if (counter < 5*N) leds = 5'b10000; // LED4 - green
    else if (counter < 6*N) leds = 5'b11111;
    else                    leds = 5'b00000;
  end

  // iCEstick LEDs are ACTIVE-LOW
  assign LED0 = leds[0];
  assign LED1 = leds[1];
  assign LED2 = leds[2];
  assign LED3 = leds[3];
  assign LED4 = leds[4];

endmodule


