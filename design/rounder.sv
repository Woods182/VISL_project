module rounder #(parameter para_int_bits = 7, para_frac_bits = 9) (
    input signed [(para_int_bits + para_frac_bits) * 2 - 1:0] in,
    output signed [para_int_bits + para_frac_bits - 1:0] out
);

parameter WIDTH_OUTPUT=para_int_bits + para_frac_bits;
parameter WIDTH_INPUT=(para_int_bits + para_frac_bits)*2;


///////////////////////////////////////////////////////////
// necessary vars
///////////////////////////////////////////////////////////
logic frac_carry_bit;
logic [WIDTH_INPUT - para_frac_bits  : 0] rounded_data;


assign frac_carry_bit = in[para_frac_bits -1];
assign rounded_data = {in[WIDTH_INPUT-1], in[WIDTH_INPUT-1 : para_frac_bits ]} + frac_carry_bit;

///////////////////////////////////////////////////////////
// saturation rounding
///////////////////////////////////////////////////////////
logic sign_bit;
logic [WIDTH_INPUT - 2*para_frac_bits  - para_int_bits - 1 : 0] overflow_bits;

assign sign_bit = rounded_data[WIDTH_INPUT - para_frac_bits ];
assign overflow_bits =  rounded_data[WIDTH_INPUT - para_frac_bits  - 1 -: WIDTH_INPUT - 2*para_frac_bits  - para_int_bits];

///////////////////////////////////////////////////////////
// results
///////////////////////////////////////////////////////////
logic and_sig;
logic or_sig;

assign and_sig = &overflow_bits;
assign or_sig  = |overflow_bits;

logic [WIDTH_OUTPUT - 1 : 0] normal_result;
assign normal_result = {sign_bit, rounded_data[0 +: WIDTH_OUTPUT-1]};

logic [WIDTH_OUTPUT - 1 : 0] data_o_reg;
always_comb begin
    if (sign_bit) begin
        // neg number
        if (and_sig) begin
            // all 1
            data_o_reg = normal_result;
        end else begin
            // not all 1
            data_o_reg = {sign_bit, {(WIDTH_OUTPUT-1){1'b0}}};
        end
    end else begin
        // pos number
        if (or_sig) begin
            // 1 sta
            data_o_reg = {sign_bit, {(WIDTH_OUTPUT-1){1'b1}}};
        end else begin
            // not sta
            data_o_reg = normal_result;
        end
    end
end

assign out = data_o_reg;

//assign out = in[para_int_bits + para_frac_bits - 1:0];//简化rounder 用于module_tb
//assign out = in[19:4];
endmodule
