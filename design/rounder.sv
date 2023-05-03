module rounder #(parameter para_int_bits = 7, para_frac_bits = 9) (
    input signed [(para_int_bits + para_frac_bits) * 2 - 1:0] in,
    output signed [para_int_bits + para_frac_bits - 1:0] out
);
    assign out = in[para_int_bits + para_frac_bits:para_frac_bits] + (in[para_frac_bits-1] & ~(|in[para_frac_bits-2:0])); // Round to nearest, saturate high bits
endmodule