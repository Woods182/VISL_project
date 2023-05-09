///////////////////////////////////////////////////////////
// Author: woodsning
///////////////////////////////////////////////////////////
`timescale 1ns/1ps

module top_tb();

logic           clk,
logic           rst_n,
logic           load_en_i, //开始输入数据
logic  [31:0]   load_payload_i,//
logic           load_type_i,//logic-1,weight-0
logic  [3:0]    logic_load_number,//输入logic第几排 0-15
logic  [2:0]    layer_number,//计算第几层0-7
logic   [2:0]   weight_number,//0-7   
logic          result_valid_o,
logic [31:0]   result_payload_o

MLP_acc_top MLP_acc_top_inst(
    .clk                    (   clk             ),
    .rst_n                  (   rst_n           ),
    .load_en_i              (   load_en_i       ), //开始输入数据
    .load_payload_i         (   load_payload_i  ),//
    .load_type_i            (   load_type_i     ),//-1,weight-0
    .input_load_number      (   input_load_number),//输入logic第几排 0-15
    .layer_number           (   layer_number    ),//计算第几层0-7
    .weight_number          (   weight_number   ),//0-7   
    .result_valid_o         (   result_valid_o  ),
    .result_payload_o       (   result_payload_o)
);


// *************************************************************************************
// custom task
// *************************************************************************************






// *************************************************************************************
// Necessary Component
// *************************************************************************************
parameter CLK_CYCLE = 10 ;

initial begin
    $dumpfile("out/top.vcd"); // 表示dump文件的路径与名字。
    $dumpvars(0,top_tb);        // 0表示记录xxx module下的所有信号
end
always begin
    clk = 0 ; #(CLK_CYCLE/2) ;
    clk = 1 ; #(CLK_CYCLE/2) ;
end

initial begin
    clk_cnt = 0 ;
end

always @(posedge clk) begin
    if(rst_n == 0) begin
        clk_cnt <= 0 ;
    end else begin
        clk_cnt <= clk_cnt + 1 ;
    end
end

// *************************************************************************************
// Useful tas
// *************************************************************************************
//delay 多少周期数
task delay(                                 
    input [31:0] cycles
);
integer idx;
for(idx=0; idx<cycles; idx=idx+1) begin
    #(CLK_CYCLE) ;
end
endtask 


task sys_rst(
    input [31:0] cycles
);
    rst_n = 0 ;
    delay(cycles);
    rst_n = 1 ;
endtask 

endmodule