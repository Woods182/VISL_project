module matrix_multiplier #(
    parameter para_int_bits = 7,
    parameter para_frac_bits = 9
) (
    input signed [para_int_bits + para_frac_bits - 1:0] A[0:15][0:15], // 16x16 matrix A
    input signed [para_int_bits + para_frac_bits - 1:0] B[0:15][0:15], // 16x16 matrix B
    output signed [para_int_bits + para_frac_bits - 1:0] C[0:15][0:15] // 16x16 result matrix C
);

integer i, j, k;
wire signed [(para_int_bits + para_frac_bits) * 2 - 1:0] products[0:15][0:15][0:15];
wire signed [(para_int_bits + para_frac_bits) * 2 - 1:0] sums[0:15][0:15][0:15];

// Instantiate multipliers
genvar m, n, p;
generate
    for (m = 0; m < 16; m = m + 1) begin
        for (n = 0; n < 16; n = n + 1) begin
            for (p = 0; p < 16; p = p + 1) begin
                multiplier #(.para_int_bits(para_int_bits), .para_frac_bits(para_frac_bits)) mult(.a(A[m][p]), .b(B[p][n]), .product(products[m][n][p]));
            end
        end
    end
endgenerate

// Instantiate adders
generate
    for (m = 0; m < 16; m = m + 1) begin
        for (n = 0; n < 16; n = n + 1) begin
            for (p = 1; p < 16; p = p + 1) begin
                adder #(.para_int_bits(para_int_bits), .para_frac_bits(para_frac_bits)) add(.a(sums[m][n][p-1]), .b(products[m][n][p]), .sum(sums[m][n][p]));
            end
        end
    end
endgenerate

// Connect the first product to the first sum wire
assign sums[0:15][0:15][0] = products[0:15][0:15][0];

// Instantiate rounders
generate
    for (m = 0; m < 16; m = m + 1) begin
        for (n = 0; n < 16; n = n + 1) begin
            rounder #(.para_int_bits(para_int_bits), .para_frac_bits(para_frac_bits)) r(.in(sums[m][n][15]), .out(C[m][n]));
        end
    end
endgenerate

endmodule