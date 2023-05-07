module mac_round_array#(
parameter  col= 16, row = 2
)(
    input                       clk,
    input                       rst_n,
    input [255:0]               data_input_matrix,//一行16个数，16bit*16
    input [31:0]                data_weight_matrix,//一列中的两个数，16bit*2
    input [3:0]                 mac_number,
    input                       round_en,
    output [15:0][15:0][15:0]    pe_array_out
);
parameter DATA_WIDTH=16;
logic [15:0][15:0][31:0] mac_res ;
logic [15:0][15:0][15:0] round_res;
logic [16*2-1:0][15:0] mac_out,round_out;
logic [31:0] data_adder[2:0][15:0]
genvar m, n;
generate
    for (j = 0; j < row; j++) begin : assign_weight_cut
        assign data_weight_matrix_cut[j] = data_weight_matrix[j * 16 +: 16];
    end
endgenerate
generate
    for (m = 0; m < row; m = m + 1) begin :array_genarate
        for (n = 0; n < col; n = n + 1) begin
            mac_pe#(.para_int_bits(para_int_bits),.para_frac_bits(para_frac_bits)
            )   mac_pe_inst (
                .data_in_1(data_input_matrix[DATA_WIDTH*col+: DATA_WIDTH]),
                .data_in_2(data_weight_matrix[DATA_WIDTH*row+: DATA_WIDTH]),
                .data_adder(data_adder[row][col]),
                .mac_out(mac_out[row][col])
            );
        end
    end
endgenerate
always_ff @(posedge)begin
    if(!rst_n) 
end
generate
    for (m = 0; m < row; m = m + 1) begin :array_genarate
        for (n = 0; n < col; n = n + 1) begin
            mac_pe#(.para_int_bits(para_int_bits),.para_frac_bits(para_frac_bits)
            )   mac_pe_inst (
                .data_in_1(),
                .data_in_2(),
                .data_adder(),
                .mac_out()
            );
        end
    end
endgenerate
endmodule