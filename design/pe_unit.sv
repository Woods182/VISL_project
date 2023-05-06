module pe_unit#(
parameter para_int_bits = 7, para_frac_bits = 9
) (
    input clk,
    input rst_n,
    input [para_int_bits + para_frac_bits - 1:0]    data_in_1,
    input [para_int_bits + para_frac_bits - 1:0]    data_in_2,
    input [3:0]                                     add_number,//选择mac调用的reg
    input [3:0]                                     round_number,//round调用的reg
    input                                           rounder_en,
    input [2:0]                                     connection_state,
    output [para_int_bits + para_frac_bits - 1:0]   data_out,
);

///////////////////////////////////////////////////////////
// multiplier
///////////////////////////////////////////////////////////
logic [para_int_bits + para_frac_bits - 1:0]        muldata_in_1;
logic [para_int_bits + para_frac_bits - 1:0]        muldata_in_2;
logic [(para_int_bits + para_frac_bits) * 2 - 1:0]  muldata_out,muldata_out_reg;

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

always_ff @(posedge clk) begin
    if(!rst_n) muldata_out_reg<=0;
    else muldata_out_reg<=muldata_out;
end

///////////////////////////////////////////////////////////
// adder
///////////////////////////////////////////////////////////
logic [(para_int_bits + para_frac_bits) * 2 - 1:0] adddata_in_1,adddata_in_2; 
logic [(para_int_bits + para_frac_bits) * 2 - 1:0] adddata_out_reg[7:0]; 
logic [(para_int_bits + para_frac_bits) * 2 - 1:0] adddata_out; 
assign adddata_in_1= muldata_out_reg;
assign adddata_in_2= adddata_out_reg[add_number];

adder #(
    .para_int_bits(para_int_bits),
    .para_frac_bits(para_frac_bits) 
) adder_inst (
    .a(adddata_in_1),
    .b(adddata_in_2),
    .sum(adddata_out)
);
genvar i;
generate
    for (i = 0; i < 8; i++) begin : adddata_out_reg_reset
        always @(posedge clk) begin
            if (!rst_n) begin
                adddata_out_reg[i] <= 'd0;
            end
            else begin
             if(add_number==i)begin
                adddata_out_reg[i] <= adddata_out;
             end
             else begin
                adddata_out_reg[i] <= adddata_out_reg[i];
             end
            end
        end
    end
endgenerate

///////////////////////////////////////////////////////////
// formatter
///////////////////////////////////////////////////////////
logic                                               rounder_en;
logic [(para_int_bits + para_frac_bits) * 2 - 1:0]  rounder_data_in;
logic [para_int_bits + para_frac_bits - 1:0]        rounder_data_out;
logic [para_int_bits + para_frac_bits - 1:0]        rounder_data_out_reg;

rounder #(
    .para_int_bits(para_int_bits),
    .para_frac_bits(para_frac_bits) 
)(
    .in(rounder_data_in),
    .out(rounder_data_out)
)
assign rounder_data_in= (rounder_en)? adddata_out_reg[round_number]:'d0;
always_ff @(posedge clk)begin
    if (!rst_n) begin
        rounder_data_out_reg<='d0;
    end
    else begin
        rounder_data_out_reg<=rounder_data_out;
    end
end
///////////////////////////////////////////////////////////
// 输出
///////////////////////////////////////////////////////////
assign data_out=rounder_data_out_reg;
endmodule