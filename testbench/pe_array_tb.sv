///////////////////////////////////////////////////////////
// Author: woodsning
///////////////////////////////////////////////////////////
`timescale 1ns/1ps
module pe_array_tb();


logic                           clk;
logic                           rst_n,keep,rounder_valid;
logic   [3:0]                   add_number_i;
logic   [3:0]                   round_number_o;
logic                           rounder_en;
logic   [255:0]                 data_input_matrix_i;
logic   [31:0]                  data_weight_matrix_i; 
logic   [1:0][15:0][15:0]       pe_array_o;
pe_array pe_array_inst(
    .clk            (clk),
    .rst_n          (rst_n),
    .data_input_matrix(data_input_matrix_i),//一行16个数，16bit*16
    .data_weight_matrix(data_weight_matrix_i),//一列中的两个数，16bit*2
    .add_number     (add_number_i),
    .rounder_en     (rounder_en),
    .keep           (keep),
    .pe_array_out   (pe_array_o),
    .rounder_valid  (rounder_valid),
    .round_number   (round_number_o)
);
initial begin
    $dumpfile("out/pe_array.vcd"); // 表示dump文件的路径与名字。
    $dumpvars(0,pe_array_tb);        // 0表示记录xxx module下的所有信号
end

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
initial begin

end
endmodule