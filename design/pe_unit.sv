///////////////////////////////////////////////////////////
// Author: woodsning
///////////////////////////////////////////////////////////
module pe_unit#(
parameter para_int_bits = 7, para_frac_bits = 9
) (
    input clk,
    input rst_n,
    input [para_int_bits + para_frac_bits - 1:0]    data_in_1,
    input [para_int_bits + para_frac_bits - 1:0]    data_in_2,
    input [3:0]                                     add_number,//选择mac调用的reg
    input                                           rounder_en,
    input                                           keep,
    output [para_int_bits + para_frac_bits - 1:0]   data_out,
    output                                          rounder_valid,
    output [3:0]                                    round_number
    //output rounder_number
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
    else if(keep) muldata_out_reg<=muldata_out_reg;

    else muldata_out_reg<=muldata_out;
end

///////////////////////////////////////////////////////////
// adder
///////////////////////////////////////////////////////////
logic [3:0]                                         add_number_r;
always_ff @(posedge clk)begin
    if(!rst_n) add_number_r<=0;
    else if(keep) add_number_r<=add_number_r;
    else add_number_r<=add_number;
end

logic [(para_int_bits + para_frac_bits) * 2 - 1:0] adddata_in_1,adddata_in_2; 
logic [7:0] [(para_int_bits + para_frac_bits) * 2 - 1:0] adddata_out_reg; 
logic [(para_int_bits + para_frac_bits) * 2 - 1:0] adddata_out; 
logic [3:0] round_number_r;
logic       rounder_en_r,rounder_en_rr;

assign adddata_in_1= muldata_out_reg;
assign adddata_in_2= adddata_out_reg[add_number_r];


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
            else if(keep) adddata_out_reg[i] <= adddata_out_reg[i];
                    else begin
                    if(add_number_r==i)begin
                        adddata_out_reg[i] <= adddata_out;
                    end
                    if(rounder_en_rr) begin
                        adddata_out_reg[round_number_r]<=0;
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


always_ff @(posedge clk)begin
    if(!rst_n ) begin
        round_number_r<=0;
    end
    else begin
        round_number_r<=add_number_r;
    end
end

always_ff @(posedge clk)begin
    if(!rst_n ) begin
        rounder_en_r<=0;
        rounder_en_rr<=0;
    end
    else begin
        rounder_en_r<=rounder_en;
        rounder_en_rr<=rounder_en_r;
    end
end

logic [(para_int_bits + para_frac_bits) * 2 - 1:0]  rounder_data_in;
logic [para_int_bits + para_frac_bits - 1:0]        rounder_data_out;
logic [para_int_bits + para_frac_bits - 1:0]        rounder_data_out_reg;

rounder #(
    .para_int_bits(para_int_bits),
    .para_frac_bits(para_frac_bits) 
)(
    .in(rounder_data_in),
    .out(rounder_data_out)
);

assign rounder_data_in= (rounder_en_rr)? adddata_out_reg[round_number_r]:'d0;
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
assign round_number=round_number_r;
assign rounder_valid=rounder_en_rr;
endmodule