///////////////////////////////////////////////////////////
// Author: woodsning
///////////////////////////////////////////////////////////
`timescale 1ns/1ps

module pe_unit_tb();
initial begin
    $dumpfile("out/pe_unit.vcd"); // 表示dump文件的路径与名字。
    $dumpvars(0,pe_unit_tb);        // 0表示记录xxx module下的所有信号
end

parameter para_int_bits = 7;
parameter para_frac_bits = 9;
logic                           clk;
logic                           rst_n,keep,rounder_valid;
logic   [3:0]                   add_number_i;
logic   [3:0]                   round_number_out;
logic                           rounder_en;
logic  [para_int_bits + para_frac_bits - 1:0]        data_in_1,data_in_2;
logic  [para_int_bits + para_frac_bits - 1:0]        data_out; 

pe_unit#(.para_int_bits(para_int_bits), .para_frac_bits(para_frac_bits))
pe_unit_inst (
    .clk         (  clk             ),
    .rst_n       (  rst_n           ),
    .data_in_1   (  data_in_1       ),
    .data_in_2   (  data_in_2       ),
    .add_number  (  add_number_i    ),//选择mac调用的reg
    .rounder_en  (  rounder_en      ),
    .keep        (  keep            ),
    .data_out    (  data_out        ),
    .rounder_valid(  rounder_valid      ),
    .round_number(  round_number_out)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

integer i;

initial begin
    rst_n = 0;
    rounder_en = 0;
    keep=0;
    add_number_i =0;
    data_in_2=0;
    data_in_1=0;
    //只mac
    #50;
    rst_n = 1;
    #10;
    //mac+0
    for (i = 0;i<8 ;i++ ) begin
        add_number_i=i;
        data_in_1 = i;
        data_in_2 = 1;
        #10;
    end
    //mac+1
    for (i = 0;i<8 ;i++ ) begin
        add_number_i=i;
        data_in_1 = 1;
        data_in_2 = 1;
        #10;
    end
    //keep
    keep=1;
    for (i = 0;i<8 ;i++ ) begin
        add_number_i=i;
        data_in_1 = i;
        data_in_2 = 1;
        #10;
    end
    keep=0;
    //mac+1
    rounder_en=1;
    for (i = 0;i<8 ;i++ ) begin
        add_number_i=i;
        data_in_1 = 1;
        data_in_2 = 1;
        #10;
    end

    
    #30;
    rst_n=0;
    $finish;
end

endmodule