///////////////////////////////////////////////////////////
// Author: woodsning
///////////////////////////////////////////////////////////
module pe_unit #(
    parameter para_int_bits = 7,
    para_frac_bits = 9
) (
    input                                         clk,
    input                                         rst_n,
    input  [para_int_bits + para_frac_bits - 1:0] data_in_1,
    input  [para_int_bits + para_frac_bits - 1:0] data_in_2,
    input  [                                 2:0] add_number,    //选择mac调用的reg
    input                                         rounder_en,
    input                                         keep,
    output [para_int_bits + para_frac_bits - 1:0] data_out,
    output                                        rounder_valid
);

  ///////////////////////////////////////////////////////////
  // multiplier
  ///////////////////////////////////////////////////////////
  logic [para_int_bits + para_frac_bits - 1:0] muldata_in_1;
  logic [para_int_bits + para_frac_bits - 1:0] muldata_in_2;
  logic [(para_int_bits + para_frac_bits) * 2 - 1:0] muldata_out, muldata_out_reg;

  assign muldata_in_1 = data_in_1;
  assign muldata_in_2 = data_in_2;

  multiplier #(
      .para_int_bits (para_int_bits),
      .para_frac_bits(para_frac_bits)
  ) mul_inst (
      .a      (muldata_in_1),
      .b      (muldata_in_2),
      .product(muldata_out)
  );
  logic keep_r, keep_rr;
  always_ff @(posedge clk) begin
    if (!rst_n) muldata_out_reg <= 0;
    else if (keep_r) muldata_out_reg <= muldata_out_reg;
    else muldata_out_reg <= muldata_out;
  end

  ///////////////////////////////////////////////////////////
  // adder
  ///////////////////////////////////////////////////////////
  logic [2:0] add_number_r;
  logic [(para_int_bits + para_frac_bits) * 2 - 1:0] adddata_in_1, adddata_in_2;
  logic [                                       7:0][(para_int_bits + para_frac_bits) * 2 - 1:0] adddata_out_reg;
  logic [(para_int_bits + para_frac_bits) * 2 - 1:0]                                             adddata_out;
  logic [2:0] round_number_r, round_number_rr;
  logic rounder_en_r, rounder_en_rr, rounder_en_rrr;
  assign adddata_in_1 = muldata_out_reg;
  assign adddata_in_2 = adddata_out_reg[add_number_r];

  adder #(
      .para_int_bits (para_int_bits),
      .para_frac_bits(para_frac_bits)
  ) adder_inst (
      .a  (adddata_in_1),
      .b  (adddata_in_2),
      .sum(adddata_out)
  );

  always_ff @(posedge clk) begin
    if (!rst_n) add_number_r <= 3'd0;
    else        add_number_r <= add_number;
  end

  always_ff @(posedge clk) begin
    keep_r  <= keep;
    keep_rr <= keep_r;
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      adddata_out_reg <= 256'd0;
    end else begin
      case ({
        keep_r, rounder_en_rrr
      })
        2'b10:   adddata_out_reg <= adddata_out_reg;
        2'b00: begin
          adddata_out_reg[round_number_rr] <= adddata_out_reg[round_number_rr];
          adddata_out_reg[add_number_r]    <= adddata_out;
        end
        2'b11: begin
          adddata_out_reg[round_number_rr] <= 'd0;
          adddata_out_reg[add_number_r]    <= adddata_out;
        end
        2'b01: begin
          adddata_out_reg[round_number_rr] <= 'd0;
          adddata_out_reg[add_number_r]    <= adddata_out;
        end
        default: adddata_out_reg <= adddata_out_reg;
      endcase
    end
  end

  ///////////////////////////////////////////////////////////
  // formatter
  ///////////////////////////////////////////////////////////
  logic [(para_int_bits + para_frac_bits) * 2 - 1:0] rounder_data_in;
  logic [      para_int_bits + para_frac_bits - 1:0] rounder_data_out;
  logic [      para_int_bits + para_frac_bits - 1:0] rounder_data_out_reg;
  assign rounder_data_in = (rounder_en_rr) ? adddata_out_reg[round_number_r] : 'd0;

  rounder #(
      .para_int_bits (para_int_bits),
      .para_frac_bits(para_frac_bits)
  ) rounder_inst (
      .in (rounder_data_in),
      .out(rounder_data_out)
  );

  always_ff @(posedge clk) begin
    if (!rst_n  /* || !rounder_en_rr */) begin
      round_number_r  <= 3'd0;
      round_number_rr <= 3'd0;
    end else begin
      round_number_r  <= add_number_r;
      round_number_rr <= round_number_r;
    end
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      rounder_en_r   <= 1'd0;
      rounder_en_rr  <= 1'd0;
      rounder_en_rrr <= 1'd0;
    end else begin
      rounder_en_r   <= rounder_en;
      rounder_en_rr  <= rounder_en_r;
      rounder_en_rrr <= rounder_en_rr;
    end
  end


  always_ff @(posedge clk) begin
    if (!rst_n) begin
      rounder_data_out_reg <= 16'd0;
    end else begin
      if (rounder_en_rr) begin
        rounder_data_out_reg <= rounder_data_out;
      end else begin
        rounder_data_out_reg <= rounder_data_out_reg;
      end
    end
  end

  ///////////////////////////////////////////////////////////
  // 输出
  ///////////////////////////////////////////////////////////
  assign data_out      = rounder_data_out_reg;
  assign rounder_valid = (rounder_en_rrr);// && (round_number_r <= 3'd7);
endmodule
