module rounder #(
    parameter para_int_bits = 7,
    para_frac_bits = 9
) (
    input  signed [(para_int_bits + para_frac_bits) * 2 - 1:0] in,
    output signed [      para_int_bits + para_frac_bits - 1:0] out
);
  parameter WIDTH_OUTPUT = para_int_bits + para_frac_bits;  //32
  parameter WIDTH_INPUT = (para_int_bits + para_frac_bits) * 2;  //16
  logic                                    and_sig;
  logic                                    or_sig;
  logic [            WIDTH_OUTPUT - 1 : 0] data_o_reg;
  logic [            WIDTH_OUTPUT - 1 : 0] normal_result;
  logic                                    frac_carry_bit;
  logic [WIDTH_INPUT - para_frac_bits : 0] rounded_data;
  logic                                    sign_bit;
  logic [           para_int_bits - 1 : 0] overflow_bits;
  assign frac_carry_bit = in[para_frac_bits-1];
  assign rounded_data   = {in[WIDTH_INPUT-1], in[WIDTH_INPUT-1 : para_frac_bits]} + frac_carry_bit;
  ///////////////////////////////////////////////////////////
  // saturation rounding
  ///////////////////////////////////////////////////////////
  assign sign_bit       = rounded_data[WIDTH_INPUT-para_frac_bits];
  assign overflow_bits  = {rounded_data[WIDTH_INPUT-para_frac_bits-1], rounded_data[WIDTH_INPUT-para_frac_bits-3-:6]};
  ///////////////////////////////////////////////////////////
  // results
  ///////////////////////////////////////////////////////////
  assign and_sig        = &overflow_bits;
  assign or_sig         = |overflow_bits;
  assign normal_result  = {sign_bit, rounded_data[0+:WIDTH_OUTPUT-1]};
  assign data_o_reg     = (sign_bit) ? ((and_sig) ? normal_result : {sign_bit, {(WIDTH_OUTPUT - 1) {1'b0}}}) : ((or_sig) ? {sign_bit, {(WIDTH_OUTPUT - 1) {1'b1}}} : normal_result);
  assign out            = data_o_reg;

endmodule
