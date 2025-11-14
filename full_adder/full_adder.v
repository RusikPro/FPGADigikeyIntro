// Module: button 0 lights up 2 LEDs, button 0 and 1 light up another
module full_adder (

    // Inputs
    input   [2:0]   pmod,

    // Outputs
    output  [1:0]led,
);

    // Wire (net) declarations (internal to module)
    wire not_pmod_01;

    // Continuous assignment: First xor block for pmod[0] ^ pmod[1] - A ^ B
    assign not_pmod_01 = ~pmod[0] ^ ~pmod[1];

    // (A ^ B) ^ Carry
    assign led[0] = not_pmod_01 ^ ~pmod[2];


    // Continuous assignment: Carry bit
    assign led[1] = (not_pmod_01 & ~pmod[2]) | (~pmod[0] & ~pmod[1]);

    // assign led_2 = 1'b0;
    // assign led_3 = 1'b0;
    // assign led_4 = 1'b0;

endmodule


