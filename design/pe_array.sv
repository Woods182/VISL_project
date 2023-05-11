module pe_array #(
    parameter col = 16,
    row = 2
) (
    input                      clk,
    input                      rst_n,
    input  [255:0]             data_input_matrix,   //一行16个数，16bit*16
    input  [ 31:0]             data_weight_matrix,  //一列中的两个数，16bit*2
    input  [  3:0]             add_number,
    input                      rounder_en,
    input                      keep,
    output [  1:0][15:0][15:0] pe_array_out,
    output                     rounder_valid,
    output [  3:0]             round_number
);
  parameter para_int_bits = 7;
  parameter para_frac_bits = 9;
  logic [15:0][15:0] data_input_matrix_cut;
  logic [ 1:0][15:0] data_weight_matrix_cut;
  logic [3:0] round_number_rr, round_number_r, round_number_rrr;
  genvar i, j;
  genvar m, n;
  
  generate
    for (i = 0; i < col; i++) begin : assign_input_cut
      assign data_input_matrix_cut[i] = data_input_matrix[i*16+:16];
    end
  endgenerate
  generate
    for (j = 0; j < row; j++) begin : assign_weight_cut
      assign data_weight_matrix_cut[j] = data_weight_matrix[j*16+:16];
    end
  endgenerate


  generate
    for (m = 0; m < row; m = m + 1) begin : array_genarate
      for (n = 0; n < col; n = n + 1) begin
        pe_unit #(
            .para_int_bits (para_int_bits),
            .para_frac_bits(para_frac_bits)
        ) pe_unit_inst (
            .clk          (clk),
            .rst_n        (rst_n),
            .data_in_1    (data_input_matrix_cut[n]),
            .data_in_2    (data_weight_matrix_cut[m]),
            .add_number   (add_number),                 //选择mac调用的reg
            .rounder_en   (rounder_en),
            .keep         (keep),
            .data_out     (pe_array_out[m][n]),
            .rounder_valid(rounder_valid)
            //.round_number   (   round_number            )
        );
      end
    end
  endgenerate

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      round_number_r   <= 4'd0;
      round_number_rr  <= 4'd0;
      round_number_rrr <= 4'd0;
    end else begin
      round_number_r   <= add_number;
      round_number_rr  <= round_number_r;
      round_number_rrr <= round_number_rr;
    end
  end
  assign round_number = (rounder_valid) ? round_number_rrr : 4'd0;

endmodule
