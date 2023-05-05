module pe_unit#(
parameter para_int_bits = 7, para_frac_bits = 9
) (
    input clk,
    input rst_n,
    input [para_int_bits + para_frac_bits - 1:0] data_in_1,
    input [para_int_bits + para_frac_bits - 1:0] data_in_2,
    input adder_en,
    input rounder_en,
    input [2:0] connection_state,
    output [para_int_bits + para_frac_bits - 1:0] data_out,
);
logic [(para_int_bits + para_frac_bits) * 2 - 1:0] adder_out[8:0];


///////////////////////////////////////////////////////////
// multiplier
///////////////////////////////////////////////////////////
logic [para_int_bits + para_frac_bits - 1:0] muldata_in_1;
logic [para_int_bits + para_frac_bits - 1:0] muldata_in_2;
logic [(para_int_bits + para_frac_bits) * 2 - 1:0] muldata_out;

assign muldata_in_1=data_in_1;
assign muldata_in_2=data_in_2;

multiplier #(
    .para_int_bits(para_int_bits),
    .para_frac_bits(para_frac_bits)
)  mul_inst (
    .a(muldata_in_1),
    .b(muldata_in_2),
    .product(muldata_out)
);

///////////////////////////////////////////////////////////
// adder
///////////////////////////////////////////////////////////
logic [(para_int_bits + para_frac_bits) * 2 - 1:0] adddata_in_1,adddata_in_2; 
logic [(para_int_bits + para_frac_bits) * 2 - 1:0] lastmac_data;
logic [(para_int_bits + para_frac_bits) * 2 - 1:0] adddata_out; 
assign adddata_in_1=muldata_out;
assign adddata_in_2= (adder_en) ? lastmac_data  : 'b0;

adder #(
    .para_int_bits(para_int_bits),
    .para_frac_bits(para_frac_bits) 
) adder_inst (
    .a(adddata_in_1),
    .b(adddata_in_2),
    .sum(adddata_out)
);



///////////////////////////////////////////////////////////
// formatter
///////////////////////////////////////////////////////////


endmodule