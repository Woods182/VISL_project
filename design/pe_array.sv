module pe_array#(
parameter  col= 16, row = 2
)(
    input clk,
    input rst_n,

)
parameter para_int_bits = 7, para_frac_bits = 9;



pe_unit#(.para_int_bits = (para_int_bits), .para_frac_bits = (para_frac_bits)
)   pe_unit_inst (
    .clk(clk),
    .rst_n(),
    .data_in_1(),
    .data_in_2(),
    .add_number(),//选择mac调用的reg
    .round_number(),//round调用的reg
    .rounder_en(),
    .connection_state(),
    .data_out(),
)


endmodule