///////////////////////////////////////////////////////////
// Author: woodsning
///////////////////////////////////////////////////////////
`timescale 1ns/1ps

module top_testcase_tb();
logic           clk;
logic           rst_n;
logic           load_en_i; //开始输入数据
logic  [31:0]   load_payload_i;//
logic           load_type_i;//logic-1,weight-0
logic  [3:0]    input_load_number;//输入logic第几排 0-15
logic  [2:0]    layer_number;//计算第几层0-7
logic  [2:0]    weight_number;//0-7   
logic           result_valid_o;
logic [31:0]    result_payload_o;
logic [3:0]     layer_num_top;
logic [63:0]    clk_cnt ;
reg  signed [7:0] [15:0] [ 15:0 ][15:0]  matrix_weight  ;
reg  signed [15:0] [ 15:0 ][15:0]  matrix_inputs  ;
reg  signed [15:0] [ 15:0 ][15:0]  matrix_reference  ;
logic signed  [15:0][15:0][15:0]      out_reg;
integer         time_start ;
integer         time_end ;

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
    .result_payload_o       (   result_payload_o),
    .out_reg_c                (   out_reg         )
);

initial begin
    //init
    init_matrix_weight_with_file();
    init_matrix_inputs_with_file();
    init_matrix_inputs_with_file();
    printf("---------------------------------");
    printf("matrix_inputs.", "green");
    printf("---------------------------------");
    printf_3d_array( matrix_inputs );
    printf("---------------------------------");
    printf("matrix_weight_0.", "green");
    printf("---------------------------------");
    printf_3d_array( matrix_weight[0] );
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

    init_matrix_weight_with_file();
    init_matrix_inputs_with_file();
    init_matrix_reference_with_file();
    delay(5);
    rst_n      =   1;
    time_start = clk_cnt ;
    //开始输入数据 第一层
    printf("Start computing first layer.", "normal");
    compute_weight1();
    printf("Finish icomputing first layer.", "normal");
    printf("Start computing other layers.", "normal");
   for (layer_num_top = 1;layer_num_top <=7 ;layer_num_top++ ) begin
        compute_weight_other(layer_num_top);
    end
    weight_number   = 0;  
    //compute_weight_other(1); 
    //compute_weight_other(2); 
    printf("Finish computing other layers.", "normal");
    printf("---------------------------------");
    printf("Simulation is finished.", "green");
    printf("---------------------------------");
    delay(4);
    printf_3d_array(out_reg);
    //compere_max(out_reg  );
    printf("---------------------------------");
    printf_3d_array(matrix_reference);
    delay(130);
    
    time_end = clk_cnt ;
    $display( "There are %d clock.", time_end-time_start );
    rst_n =0;
    $write("Totally %8d clock cycles passed.\n",clk_cnt);
    $finish ;
end
// *************************************************************************************
// custom task
// *************************************************************************************
task init_matrix_inputs_with_file();
    integer fd, code ;
    integer idx_mat_r, idx_mat_c ;
    fd = $fopen("./testcase/Input.txt", "r");
    for( idx_mat_c=0; idx_mat_c<16; idx_mat_c=idx_mat_c+1 ) begin
        for( idx_mat_r=0; idx_mat_r<16; idx_mat_r=idx_mat_r+1 ) begin
            code = $fscanf(fd, "%b", matrix_inputs[idx_mat_r][idx_mat_c]);
        end
    end
    $fclose(fd);
endtask 

task init_matrix_weight_with_file();
    integer fd, code ;
    integer idx_layer, idx_mat_r, idx_mat_c ;
    fd = $fopen("./testcase/Weight.txt", "r");
    for(idx_layer=0; idx_layer<8; idx_layer=idx_layer+1) begin
        for( idx_mat_c=0; idx_mat_c<16; idx_mat_c=idx_mat_c+1 ) begin
            for( idx_mat_r=0; idx_mat_r<16; idx_mat_r=idx_mat_r+1 ) begin
                code = $fscanf(fd,"%b", matrix_weight[idx_layer][idx_mat_r][idx_mat_c]);
            end
        end        
    end
    $fclose(fd);
endtask



task init_matrix_reference_with_file();
    integer fd, code ;
    integer idx_mat_r, idx_mat_c ;
    fd = $fopen("./testcase/Output.txt", "r");
    for( idx_mat_c=0; idx_mat_c<16; idx_mat_c=idx_mat_c+1 ) begin
        for( idx_mat_r=0; idx_mat_r<16; idx_mat_r=idx_mat_r+1 ) begin
            code = $fscanf(fd, "%b", matrix_reference[idx_mat_r][idx_mat_c]);
        end
    end
    $fclose(fd);
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
            load_payload_i= {matrix_inputs[i_cnt*2+1][i_num], matrix_inputs[i_cnt*2][i_num] };
            delay(1);
        end
        for (w_num = 0  ;  w_num<=7 ; w_num++) begin
            weight_number   = w_num; 
            load_type_i     = 0;
            load_payload_i  ={ matrix_weight[layer_number][i_num][w_num*2+1], matrix_weight[layer_number][i_num][w_num*2] };
            delay(1);
        end
    end
endtask

task compute_weight_other(
    input [2:0] l_num   //第几个输入
);
    logic   [5:0] w_num,i_num,i_cnt;
    layer_number =  l_num;
    for(i_num =0 ; i_num <=15 ; i_num++)begin
        input_load_number   = i_num;
        for (w_num = 0  ;  w_num<=7 ; w_num++) begin
            weight_number   = w_num; 
            load_type_i     =   0;
            load_payload_i  ={matrix_weight[layer_number][i_num][w_num*2+1], matrix_weight[layer_number][i_num][w_num*2] };
            delay(1);
        end
    end
endtask


// *************************************************************************************
// Necessary Component
// *************************************************************************************

parameter CLK_CYCLE = 10 ;

initial begin
    $dumpfile("out/top_testcase.vcd"); // 表示dump文件的路径与名字。
    $dumpvars(0,top_testcase_tb);        // 0表示记录xxx module下的所有信号
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
// Useful task
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

task printf_3d_array(  
    input   [15:0] [ 15:0 ][15:0]  matrix
  );
  integer i, j;
    begin
      for (i = 0; i < 16; i = i + 1) begin
        for (j = 0; j < 16; j = j + 1) begin
            $write("\033[0m\033[1;32m%d\033[0m  ",$signed(matrix[i][j]));
          end
          $display(""); // print a newline at the end of each row
        end
    end
endtask

task compere_max(  
    input   [15:0] [ 15:0 ][15:0]  matrix
  );
  integer i, j;
    begin
      for (i = 0; i < 16; i = i + 1) begin
        for (j = 0; j < 16; j = j + 1) begin
            if(matrix[i][j] != matrix_reference[i][j]) begin
                $write("\033[0m\033[1;31m%d\033[0m ",$signed(matrix[i][j]));//红色
            end
            else begin
                $write("\033[0m\033[1;32m%d\033[0m ",$signed(matrix[i][j]));
            end
          end
          $display(""); // print a newline at the end of each row
        end
    end
endtask
//打印结果

/* logic   [15:0]  output_high,output_low;
assign  output_low  =   result_payload_o[15:0];
assign  output_high =   result_payload_o[31:16];  */

/* always  begin
    integer f,k;
    if(result_valid_o == 1) begin
        printf("---------------------------------");
        printf("output", "green");
        printf("---------------------------------");
        for (f = 0;f<16 ;  f++  ) begin
            for (k=0;k<=7;k++)  begin
            $write("%d ",$signed(output_low));
            $write("%d ",$signed(output_high));
            delay(1);
            end
            $display("");
        end
        $display("");
    end
end */


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