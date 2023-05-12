module MLP_acc_top (
    input                     clk,
    input                     rst_n,
    input                     load_en_i,          //开始输入数据
    input  [31:0]             load_payload_i,     //
    input                     load_type_i,        //input-1,weight-0
    input  [ 3:0]             input_load_number,  //输入input第几排 0-15
    input  [ 3:0]             layer_number,       //计算第几层0-7
    input  [ 2:0]             weight_number,      //0-7   
    output                    result_valid_o,
    output [31:0]             result_payload_o
    //output [15:0][15:0][15:0] out_reg_c
);
  parameter col = 16, row = 2;
  logic [255:0] dataload_input_data;
  logic [ 31:0] dataload_weight_o;
  logic                     dataload_weight_valid, dataload_input_valid;
  logic                    load_type_i_r;
  logic [ 3:0]             input_load_number_r;  //输入input第几排 0-15
  logic [ 3:0]             layer_number_r;  //计算第几层0-7
  logic [ 2:0]             weight_number_r;
  logic [15:0][15:0][15:0] out_reg;
  logic                     array_keep, array_rounder_valid;
  logic [  2:0]             round_number_o;
  logic                     array_rounder_en;
  logic [255:0]             data_input_matrix_i;
  logic [  1:0][15:0][15:0] pe_array_o;
  logic [  8:0]             cnt_o;
  logic                     cnt_en;
  logic [  3:0]             cnt_tmp;
  logic                     cnt_rst_n_tmp;
  logic                     result_valid_o_r, result_valid_o_rr, result_valid_o_rrr;
  logic [3:0]               layer_num_rr, layer_num_r, layer_num_rrr;
  reg   [  3:0]             round_number_o_c;
  assign data_input_matrix_i = (layer_number_r == 0) ? dataload_input_data : out_reg[input_load_number_r];  //按位对应是否相同？
  assign array_rounder_en    = (input_load_number_r == 15) && (dataload_weight_valid) && (!result_valid_o_r);
  assign array_keep          = load_type_i || result_valid_o;
  assign round_number_o_c    = round_number_o;
  //dataload
  dataload dataload_inst (
      .clk                   (clk),
      .rst_n                 (rst_n),
      .data_i                (load_payload_i),
      .load_en_i             (load_en_i),
      .load_type             (load_type_i),            //0-weight,1-input
      .first_level_input_data(dataload_input_data),
      .weight_o              (dataload_weight_o),
      .weight_valid          (dataload_weight_valid),
      .input_valid           (dataload_input_valid)
  );

  //因为dataload打一拍，所以让输入到array的loadtype打一拍
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      load_type_i_r       <= 1'd0;
      input_load_number_r <= 4'd0;
      layer_number_r      <= 4'd0;
      weight_number_r     <= 3'd0;
    end else begin
      load_type_i_r       <= load_type_i;
      input_load_number_r <= input_load_number;
      layer_number_r      <= layer_number;
      weight_number_r     <= weight_number;
    end
  end
  //pe_array
  pe_array pe_array_inst (
      .clk               (clk),
      .rst_n             (rst_n),
      .data_input_matrix (data_input_matrix_i),  //一行16个数，16bit*16
      .data_weight_matrix(dataload_weight_o),    //一列中的两个数，16bit*2
      .add_number        (weight_number),
      .rounder_en        (array_rounder_en),
      .keep              (array_keep),
      .pe_array_out      (pe_array_o),           //?要不要打拍
      .rounder_valid     (array_rounder_valid),
      .round_number      (round_number_o)
  );
  //output

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      layer_num_r   <= 4'd0;
      layer_num_rr  <= 4'd0;
      layer_num_rrr <= 4'd0;
    end else begin
      layer_num_r   <= layer_number_r;
      layer_num_rr  <= layer_num_r;
      layer_num_rrr <= layer_num_rr;
    end
  end

  logic [31:0] result_payload_o_c;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      result_valid_o_r   <= 1'd0;
      result_valid_o_rrr <= 1'd0;
    end else begin
      result_valid_o_rrr <= result_valid_o_rr;
      if ((layer_num_rrr == 7) && (round_number_o_c == 7) && (array_rounder_valid)) begin
        result_valid_o_r <= 1'd1;
      end else begin
        result_valid_o_r <= result_valid_o_r;
      end
    end
  end
  //输出控制

  counter #(
      .cnt_WIDTH(9)
  ) counter_output_inst (
      .cnt_clk  (clk),
      .cnt_rst_n(rst_n),
      .cnt_en   (cnt_en),
      .cnt_o    (cnt_o)
  );
  counter #(
      .cnt_WIDTH(4)
  ) counter_output_inst0 (
      .cnt_clk  (clk),
      .cnt_rst_n(cnt_rst_n_tmp),
      .cnt_en   (array_rounder_valid),
      .cnt_o    (cnt_tmp)
  );
  assign cnt_rst_n_tmp = (rst_n) & (array_rounder_valid);
  assign cnt_en        = (result_valid_o_rr) && (cnt_o != 9'd128);  //16*8
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      result_valid_o_rr  <= 1'd0;
      result_payload_o_c <= 32'd0;
      out_reg            <= 4096'd0;
    end else begin
      result_valid_o_rr <= result_valid_o_r;
      if (cnt_en) begin
        result_payload_o_c <= {out_reg[0][0], out_reg[0][1]};
        out_reg            <= (out_reg >> 32);
      end else if (array_rounder_valid && !result_valid_o) begin
        case (cnt_tmp)
          3'd0: out_reg[1:0] <= pe_array_o;
          3'd1: out_reg[3:2] <= pe_array_o;
          3'd2: out_reg[5:4] <= pe_array_o;
          3'd3: out_reg[7:6] <= pe_array_o;
          3'd4: out_reg[9:8] <= pe_array_o;
          3'd5: out_reg[11:10] <= pe_array_o;
          3'd6: out_reg[13:12] <= pe_array_o;
          3'd7: out_reg[15:14] <= pe_array_o;
          default: out_reg <= out_reg;
        endcase
      end else begin
        result_valid_o_rr <= 1'd0;
      end
    end
  end
  assign result_payload_o = result_payload_o_c;
  assign result_valid_o   = result_valid_o_rrr;
  //assign out_reg_c        = out_reg;
endmodule
