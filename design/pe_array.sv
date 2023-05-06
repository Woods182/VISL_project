module pe_array#(
parameter  col= 16, row = 2
)(
    input           clk,
    input           rst_n,
    input [255:0]   data_input_matrix,//一行16个数，16bit*16
    input [31:0]    data_weight_matrix,//一列中的两个数，16bit*2
    input [3:0]     add_number,
    input [3:0]     rounder_number,
    output[15:0]    pe_array_out[1:0][15:0]
);
parameter para_int_bits = 7;
parameter para_frac_bits = 9;
logic [15:0]    data_input_matrix_cut [15:0];
logic [15:0]    data_weight_matrix_cut [1:0];
logic [3:0]     add_number_i;
logic [3:0]     rounder_number_i;

genvar i,j;
generate
    for (i = 0; i < 16; i++) begin : assign_input_cut
        assign data_input_matrix_cut[i] = data_input_matrix[i * 16 +: 16];
    end
endgenerate
generate
    for (j = 0; j < 2; j++) begin : assign_weight_cut
        assign data_weight_matrix_cut[j] = data_weight_matrix[j * 16 +: 16];
    end
endgenerate

genvar m, n;
generate
    for (m = 0; m < 2; m = m + 1) begin :array_genarate
        for (n = 0; n < 16; n = n + 1) begin
            pe_unit#(.para_int_bits(para_int_bits),.para_frac_bits(para_frac_bits)
            )   pe_unit_inst (
                .clk(clk),
                .rst_n(rst_n),
                .data_in_1(data_input_matrix_cut[n]),
                .data_in_2(ata_weight_matrix_cut[m]),
                .add_number(add_number),//选择mac调用的reg
                .round_number(round_number),//round调用的reg
                .rounder_en(rounder_en),
                .data_out(data_out)
            );
        end
    end
endgenerate


endmodule