///////////////////////////////////////////////////////////
// Author: woodsning
///////////////////////////////////////////////////////////
`timescale 1ns/1ps

module MLP_acc_top_tb();
initial begin
    $dumpfile("out/MLP_acc_top.vcd"); // 表示dump文件的路径与名字。
    $dumpvars(0,MLP_acc_top_tb);        // 0表示记录xxx module下的所有信号
end

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end


endmodule