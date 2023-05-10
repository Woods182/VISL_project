///////////////////////////////////////////////////////////
// Author: woodsning
///////////////////////////////////////////////////////////
`timescale 1ns/1ps

module top_tb();

logic           clk;
logic           rst_n;
logic           load_en_i; //开始输入数据
logic  [31:0]   load_payload_i;//
logic           load_type_i;//logic-1,weight-0
logic  [3:0]    input_load_number;//输入logic第几排 0-15
logic  [2:0]    layer_number;//计算第几层0-7
logic   [2:0]   weight_number;//0-7   
logic          result_valid_o;
logic [31:0]   result_payload_o;

logic [63:0]    clk_cnt ;
reg   [7:0] [15:0] [ 15:0 ][15:0]  matrix_weight  ;
reg   [15:0] [ 15:0 ][15:0]  matrix_inputs  ;
reg   [15:0] [ 15:0 ][15:0]  matrix_reference  ;

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

initial begin
    printf("---------------------------------");
    printf("Start the simulation.", "green");
    printf("---------------------------------");
    //idle
    rst_n               =   0;
    load_en_i           =   0;
    load_payload_i      =   0;
    load_type_i         =   0;
    input_load_number   =   0;    
    layer_number        =   0;
    weight_number       =   0;
    init_matrix_weight();
    init_matrix_inputs();
    delay(5);
    rst_n               =   1;
    //开始输入数据 第一层
    compute_weight1();
    printf("---------------------------------");
    printf("Simulation is finished.", "green");
    printf("---------------------------------");
    $write("Totally %8d clock cycles passed.\n",clk_cnt);
    load_payload_i      =   0;
    load_type_i         =   0;
    input_load_number   =   0;    
    layer_number        =   1;
    weight_number       =   0;
    delay(10);
    $finish ;


end
// *************************************************************************************
// custom task
// *************************************************************************************
task init_matrix_weight();
    integer idx_layer, idx_mat_r, idx_mat_c ;
    for(idx_layer=0; idx_layer<8; idx_layer=idx_layer+1) begin
        for( idx_mat_r=0; idx_mat_r<16; idx_mat_r=idx_mat_r+1 ) begin
            for( idx_mat_c=0; idx_mat_c<16; idx_mat_c=idx_mat_c+1 ) begin
                matrix_weight[idx_layer][idx_mat_r][idx_mat_c] = 1;
            end
        end        
    end
endtask

task init_matrix_inputs();
    integer idx_mat_r, idx_mat_c ;
    for( idx_mat_r=0; idx_mat_r<16; idx_mat_r=idx_mat_r+1 ) begin
        for( idx_mat_c=0; idx_mat_c<16; idx_mat_c=idx_mat_c+1 ) begin
            matrix_inputs[idx_mat_r][idx_mat_c] = idx_mat_r + idx_mat_c ;
        end
    end
endtask


task compute_weight1();
    logic   [5:0] w_num,i_num,i_cnt;
    layer_number =  0;
    load_en_i = 1;
    for(i_num =0 ; i_num <=15 ; i_num++)begin
        load_type_i         =1;
        input_load_number   = i_num;
        //input一行八拍
        for (i_cnt = 0  ;  i_cnt<=7 ; i_cnt++)begin
            load_payload_i= {matrix_inputs[i_num][i_cnt*2+1], matrix_inputs[i_num][i_cnt*2] };
            delay(1);
        end
        for (w_num = 0  ;  w_num<=7 ; w_num++) begin
            weight_number   = w_num; 
            load_type_i     =0;
            load_payload_i  ={ matrix_weight[layer_number][w_num*2+1][i_num], matrix_weight[layer_number][w_num*2][i_num] };
            delay(1);
        end
    end
endtask

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


task printf( string text, string color="normal" );
    if( color == "normal" ) begin
        $display( "%s", text );
    end else if (color == "red") begin
        $display("\033[0m\033[1;31m%s\033[0m", text);
    end else if(color == "green")begin
        $display("\033[0m\033[1;32m%s\033[0m", text);
    end else if (color == "yellow") begin
        $display("\033[0m\033[1;33m%s\033[0m", text);
    end else if (color == "blue") begin
        $display("\033[0m\033[1;34m%s\033[0m", text);
    end else if (color == "pink") begin
        $display("\033[0m\033[1;35m%s\033[0m", text);
    end else if (color == "cyan") begin
        $display("\033[0m\033[1;36m%s\033[0m", text);
    end 
endtask
task printf_red(string text);
    $display("\033[0m\033[1;31m%s\033[0m", text);
endtask 
task printf_green(string text);
    $display("\033[0m\033[1;32m%s\033[0m", text);
endtask 
task printf_yellow(string text);
    $display("\033[0m\033[1;33m%s\033[0m", text);
endtask 
task printf_blue(string text);
    $display("\033[0m\033[1;34m%s\033[0m", text);
endtask 
task printf_pink(string text);
    $display("\033[0m\033[1;35m%s\033[0m", text);
endtask 
task printf_cyan(string text);
    $display("\033[0m\033[1;36m%s\033[0m", text);
endtask 

task set_display_color(string color="normal");
    if( color == "normal" ) begin
        $write( "\033[0m" );
    end else if (color == "red") begin
        $write( "\033[0m\033[1;31m" );
    end else if(color == "green")begin
        $write( "\033[0m\033[1;32m" );
    end else if (color == "yellow") begin
        $write( "\033[0m\033[1;33m" );
    end else if (color == "blue") begin
        $write( "\033[0m\033[1;34m" );
    end else if (color == "pink") begin
        $write( "\033[0m\033[1;35m" );
    end else if (color == "cyan") begin
        $write( "\033[0m\033[1;36m" );
    end 
endtask 
task unset_display_color();
    $write("\033[0m");
endtask 
endmodule