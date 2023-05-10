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
    output                                          rounder_valid
    //output [3:0]                                    round_number
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
logic keep_r,keep_rr;
always_ff @(posedge clk)begin
    if(!rst_n) add_number_r<=0;
    // else if(keep_rr) add_number_r<=add_number_r;
    else add_number_r<=add_number;
end

always_ff @(posedge clk)begin
    keep_r <= keep;
    keep_rr <= keep_r;
end
logic [(para_int_bits + para_frac_bits) * 2 - 1:0] adddata_in_1,adddata_in_2; 
logic [7:0] [(para_int_bits + para_frac_bits) * 2 - 1:0] adddata_out_reg; 
logic [(para_int_bits + para_frac_bits) * 2 - 1:0] adddata_out; 
logic [3:0] round_number_r;
logic       rounder_en_r,rounder_en_rr,rounder_en_rrr;

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

always_ff @(posedge clk) begin
    if(!rst_n)begin
        adddata_out_reg <= 'd0;
    end
    else begin
        case ({keep_rr,rounder_en_rr})
            2'b10: adddata_out_reg <= adddata_out_reg;
            2'b00:begin
                adddata_out_reg[add_number_r] <= adddata_out;
            end
             2'b01:begin
                adddata_out_reg[add_number_r] <= adddata_out;
            end 
            /*
            2'b11: adddata_out_reg[round_number_r] <= 'd0;
            2'b01: adddata_out_reg[round_number_r] <= 'd0;
            */
            default: adddata_out_reg <= adddata_out_reg;
        endcase
    end
end
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
        rounder_en_rrr<=0;
    end
    else begin
        rounder_en_r<=rounder_en;
        rounder_en_rr<=rounder_en_r;
        rounder_en_rrr<=rounder_en_rr;
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
//assign round_number=round_number_r;
assign rounder_valid=(rounder_en_rrr)   &&  (round_number_r == 7);
endmodule