///////////////////////////////////////////////////////////
// Author: woodsning
///////////////////////////////////////////////////////////
`timescale 1ns/1ps

module controller_FSM_tb();
initial begin
    $dumpfile("out/controller_FSM.vcd"); // 表示dump文件的路径与名字。
    $dumpvars(0,controller_FSM_tb);        // 0表示记录xxx module下的所有信号
end

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

endmodule