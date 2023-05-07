module pe_top(
    input clk;
    input rst_n;

);
parameter  col= 16, row = 2
    pe_array#(.col(col), .row(row)
    )(
        .clk,
        .rst_n,
        input [255:0]               data_input_matrix,//一行16个数，16bit*16
        input [31:0]                data_weight_matrix,//一列中的两个数，16bit*2
        input [3:0]                 add_number,
        input                       rounder_en,
        input                       keep,
        output [1:0][15:0][15:0]    pe_array_out
        output                      rounder_valid,
        output                      round_number,
    );
endmodule