module top #(
    parameter para_int_bits = 7,
    parameter para_frac_bits = 9
) (
    input clk,
    input rst_n,
    input start,
    input signed [para_int_bits + para_frac_bits - 1:0] A[0:15][0:15],
    input signed [para_int_bits + para_frac_bits - 1:0] B[0:15][0:15],
    output reg done = 0,
    output reg signed [para_int_bits + para_frac_bits - 1:0] C[0:15][0:15]
);

    // 参数化矩阵乘法器
    matrix_multiplier #(
        .para_int_bits(para_int_bits),
        .para_frac_bits(para_frac_bits)
    ) matrix_mult (
        .A(A),
        .B(B),
        .C(C)
    );

    reg [4:0] cnt = 0;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            cnt <= 0;
            done <= 0;
        end else begin
            if (start) begin
                cnt <= cnt + 1;
            end
            if (cnt == 5'd31) begin
                done <= 1;
            end else begin
                done <= 0;
            end
        end
    end

endmodule