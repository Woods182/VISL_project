module top (
    input           clk,
    input           rst_n,
    input           load_en_i,
    input  [31:0]   load_payload_i,
    output          result_valid_o,
    output [31:0]   result_payload_o
);
endmodule