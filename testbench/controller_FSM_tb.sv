///////////////////////////////////////////////////////////
// Author: woodsning
///////////////////////////////////////////////////////////
`timescale 1ns/1ps

module controller_FSM_tb();
    logic   clk                     ;
    logic   rst_n           ;
    logic  [3:0] input_load_number;//输入input第几排 0-15
    logic   [2:0]layer_number;//计算第几层0-7
    logic   [2:0] weight_number;//0-7  
    logic   result_valid_o;                 
    //dataload
    logic   dataload_weight_valid;
    logic   dataload_input_valid;
    logic   dataload_en_i;
    //pe_array
    logic   array_rounder_vaild;
    logic   array_keep;
    logic   array_rounder_en;
    logic   array_input_type;

    controller_FSM controller_FSM_inst (
            .clk                    (   clk     ),
            .rst_n                  (   rst_n   ),
            .input_load_number      (   input_load_number),//输入input第几排 0-15
            .layer_number           (   layer_number),//计算第几层0-7
            .weight_number          (   weight_number),//0-7  
            .result_valid_o         (   result_valid_o), //o                 
            .dataload_en_i          (   dataload_en_i),
            .dataload_weight_valid  (   dataload_weight_valid),
            .dataload_input_valid   (   dataload_input_valid),
            //pe_array
            .array_rounder_vaild    (   array_rounder_vaild),
            .array_keep             (   array_keep),//o
            .array_rounder_en       (   array_rounder_en),//o
            .array_input_type       (   array_input_type)//o
        );


initial begin
    $dumpfile("out/controller_FSM.vcd"); // 表示dump文件的路径与名字。
    $dumpvars(0,controller_FSM_tb);        // 0表示记录xxx module下的所有信号
end

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
logic   [3:0] layer,w_num;
logic  [4:0] i_num;
initial begin
    rst_n=0;
    input_load_number= 0;//输入input第几排 0-15
    layer_number= 0;//计算第几层0-7
    weight_number= 0;//0-7              
    dataload_weight_valid= 0;
    dataload_input_valid= 0;
    dataload_en_i= 0;
    array_rounder_vaild= 0;
    #20;
    //idle
    rst_n=1;
    dataload_en_i= 1;
    #10;
    //2
    dataload_weight_valid=1;
    #10;
    //3
    dataload_weight_valid=0;
    #80;
    dataload_input_valid=1;
    //4
    for ( layer=0 ;layer<=7 ;layer++ ) begin
        layer_number = layer;
        if(layer == 0)begin
            for (   i_num =1 ;i_num <=15;i_num++)begin
                for(   w_num = 0; w_num <= 7; w_num ++)begin
                    weight_number =w_num[2:0];
                    #10;
                    dataload_weight_valid =1;
                    dataload_input_valid=0;
                end
                #80;
                input_load_number=i_num[3:0];
                dataload_input_valid=1;
                dataload_weight_valid =0; 
            end
        end
        else begin
            for (   i_num =0 ;i_num <=15;i_num++)begin
                for(   w_num = 0; w_num <=7; w_num ++)begin
                    input_load_number=i_num;
                    weight_number =w_num;
                    #10;
                end
            end
        end     
    end
    #2560;
    rst_n=0;
    $finish;
end

endmodule