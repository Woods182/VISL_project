///////////////////////////////////////////////////////////
// Author: woodsning
///////////////////////////////////////////////////////////
module mac_pe#(
parameter para_int_bits = 7, para_frac_bits = 9
) (
    input [para_int_bits + para_frac_bits - 1:0]    data_in_1,
    input [para_int_bits + para_frac_bits - 1:0]    data_in_2,
    input [para_int_bits + para_frac_bits - 1:0]    data_adder,
    output [(para_int_bits + para_frac_bits)* 2 - 1:0]   mac_out
    //output rounder_number
);

///////////////////////////////////////////////////////////
// multiplier
///////////////////////////////////////////////////////////
logic [para_int_bits + para_frac_bits - 1:0]        muldata_in_1;
logic [para_int_bits + para_frac_bits - 1:0]        muldata_in_2;
logic [(para_int_bits + para_frac_bits) * 2 - 1:0]  muldata_out;

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
logic [(para_int_bits + para_frac_bits) * 2 - 1:0]  adddata_in_2,adddata_in_2,adddata_out;


assign adddata_in_1= muldata_out;
assign adddata_in_2= data_adder;


adder #(
    .para_int_bits(para_int_bits),
    .para_frac_bits(para_frac_bits) 
) adder_inst (
    .a(adddata_in_1),
    .b(adddata_in_2),
    .sum(adddata_out)
);

///////////////////////////////////////////////////////////
// 输出
///////////////////////////////////////////////////////////
assign mac_out=adddata_out;
endmodule