module shift_buffer2 #(
    parameter buffer_SIZE  = 8,
    parameter buffer_WIDTH = 32
) (
    input                                 clk,
    input                                 rst_n,
    input                                 wr_en_i,
    input  [            buffer_WIDTH-1:0] data_i,
    output [buffer_WIDTH*buffer_SIZE-1:0] data_o,
    output                                data_valid_o
);

  logic [buffer_WIDTH*buffer_SIZE-1:0] buffer, buffer_reg;
  logic [buffer_WIDTH*buffer_SIZE-1:0] data_o_r;
  logic data_valid_o_r;
  integer cnt, cnt_reg;

  always_ff @(posedge clk) begin
    if (rst_n) begin
      buffer_reg <= buffer;
      cnt_reg    <= cnt;
      if (cnt_reg == buffer_SIZE - 1) begin
        data_o_r <= buffer;
      end
    end else begin
      // reset
      buffer_reg <= 0;
      cnt_reg    <= 0;
      data_o_r   <= 0;
    end
  end

  always_comb begin
    buffer = buffer_reg;
    cnt    = cnt_reg;
    if (wr_en_i) begin
      buffer = {data_i};
      cnt    = cnt_reg + 1'b1;
    end

    if (cnt_reg == buffer_SIZE - 1) begin
      cnt = 0;
    end
  end

  always_ff @(posedge clk) begin
    data_valid_o_r <= (cnt_reg == buffer_SIZE - 1) && wr_en_i;
  end
  
  assign data_valid_o = data_valid_o_r;
  assign data_o       = data_o_r;

endmodule
