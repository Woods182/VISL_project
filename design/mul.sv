module multiplier #(
    parameter para_int_bits = 7, para_frac_bits = 9
    ) (
    input signed [para_int_bits + para_frac_bits - 1:0] a,
    input signed [para_int_bits + para_frac_bits - 1:0] b,
    output signed [(para_int_bits + para_frac_bits) * 2 - 1:0] product
);
    assign product = a * b;
endmodule