///////////////////////////////////////////////////////////
// Author: woodsning
///////////////////////////////////////////////////////////
`timescale 1ns/1ps
module top_testcase100_tb();
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
reg  signed [99:0] [15:0] [ 15:0 ][15:0]  matrix_inputs  ;
reg  signed [99:0]  [15:0] [ 15:0 ][15:0]  matrix_reference  ;
reg  signed  [99:0][15:0][15:0][15:0]   matrix_output;
integer         time_start ;
integer         time_begin_compute,time_end_compute;
parameter CLK_CYCLE = 10 ;
integer input_data_num;
integer         error_round;
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
    //.out_reg_c              (   out_reg         )
);
logic [15:0]    result_out_high,result_out_low;
assign  result_out_high=result_payload_o[31:16];
assign  result_out_low=result_payload_o[15:0];

initial begin
//init
    printf("    ---------------------------------\n");
    printf("    Initialize data.\n", "blue");
    printf("-   --------------------------------\n");
    init_matrix_weight_with_file();
    init_matrix_inputs_with_file();
    init_matrix_reference_with_file();
    error_round = 0;
    printf("    ---------------------------------\n");
    printf("    Start the simulation.\n ", "blue");
    printf("    ---------------------------------\n");
    idle();
    Compute_main(0);
    printf_3d_array( matrix_output[0]);
    if (error_round==0)begin
            printf("    ---------------------------------");
            printf("     Successfully    !   ", "yellow");
            printf("    ---------------------------------");
        end
        else begin
            printf("    ---------------------------------");
            printf("      Failed    !   ", "red");
            printf("    ---------------------------------");
    end
    rst_n =0;
    $finish ;
end



// *************************************************************************************
// custom task
// *************************************************************************************
task init_matrix_inputs_with_file();
    integer fd, code ;
    integer idx_mat_r, idx_mat_c,idx_mat_num ;
    fd = $fopen("./testcase/Input_100.txt", "r");
    for (idx_mat_num = 0 ; idx_mat_num <100 ;idx_mat_num++)begin
        for( idx_mat_c=0; idx_mat_c<16; idx_mat_c=idx_mat_c+1 ) begin
            for( idx_mat_r=0; idx_mat_r<16; idx_mat_r=idx_mat_r+1 ) begin
                code = $fscanf(fd, "%b", matrix_inputs[idx_mat_num][idx_mat_r][idx_mat_c]);
            end
        end
    end
    $fclose(fd);
endtask 

task init_matrix_weight_with_file();
    integer fd, code ;
    integer idx_layer, idx_mat_r, idx_mat_c ;
    fd = $fopen("./testcase/Weight_100.txt", "r");
    for(idx_layer=0; idx_layer<8; idx_layer=idx_layer+1) begin
        for( idx_mat_c=0; idx_mat_c<16; idx_mat_c=idx_mat_c+1 ) begin
            for( idx_mat_r=0; idx_mat_r<16; idx_mat_r=idx_mat_r+1 ) begin
                code = $fscanf(fd,"%b", matrix_weight[idx_layer][idx_mat_r][idx_mat_c]);
            end
        end        
    end
    $fclose(fd);
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

task init_matrix_reference_with_file();
    integer fd, code ;
    integer idx_mat_r, idx_mat_c,idx_mat_num ;
    fd = $fopen("./testcase/Output_100.txt", "r");
    for (idx_mat_num = 0 ; idx_mat_num <100 ;idx_mat_num++)begin
        for( idx_mat_c=0; idx_mat_c<16; idx_mat_c=idx_mat_c+1 ) begin
            for( idx_mat_r=0; idx_mat_r<16; idx_mat_r=idx_mat_r+1 ) begin
                code = $fscanf(fd, "%b", matrix_reference[idx_mat_num][idx_mat_c][idx_mat_r]);
            end
        end
    end
    $fclose(fd);
endtask 

task idle();
    rst_n               =   0;
    load_en_i           =   0;
    load_payload_i      =   0;
    load_type_i         =   0;
    input_load_number   =   0;    
    layer_number        =   0;
    weight_number       =   0;
    delay(5);
    rst_n      =   1;
endtask

task compute_weight1(
    input   [6:0] input_data_num
);
    logic   [5:0] w_num,i_num,i_cnt;
    layer_number = 3'd0;
    load_en_i = 1'd1;
    for(i_num =0 ; i_num <=15 ; i_num++)begin
        load_type_i         = 1'd1;
        input_load_number   = i_num;
        //input一行八拍
        for (i_cnt = 6'd0  ;  i_cnt<=6'd7 ; i_cnt++)begin
            load_payload_i= {matrix_inputs[input_data_num][i_cnt*2+1][i_num], matrix_inputs[input_data_num][i_cnt*2][i_num] };
            delay(1);
        end
        for (w_num = 6'd0  ;  w_num<=6'd7 ; w_num++) begin
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

task compere100(  
    input   [6:0]   input_data_num
  );
  integer i, j;
  integer error_cnt ;
  error_cnt = 0 ;
    begin
      for (i = 0; i < 16; i = i + 1) begin
        for (j = 0; j < 16; j = j + 1) begin
            if(matrix_output[input_data_num][i][j] != matrix_reference[input_data_num][i][j]) begin
                //$write("\033[0m\033[1;31m%d\033[0m ",$signed(matrix_output[input_data_num][i][j]));//红色
                error_cnt = error_cnt + 1 ;
            end
          end
        end
        $display("  input[%d] -> %d errors. "   ,input_data_num,error_cnt);
         if (error_cnt!=0)begin
            error_round ++;
        end
    end
endtask

task Compute_main(
    input [6:0] input_data_num
);
    //开始输入数据 第一层
    idle();
    compute_weight1(input_data_num);
//  其他层计算
    for (layer_num_top = 1;layer_num_top <=7 ;layer_num_top++ ) begin
        compute_weight_other(layer_num_top);
    end
    weight_number   = 0;  
    delay(4);
    get_result(input_data_num);
    delay(130);
    compere100(input_data_num );
endtask

// *************************************************************************************
// Necessary Component
// *************************************************************************************

/* initial begin
    $dumpfile("out/top_testcase100.vcd"); // 表示dump文件的路径与名字。
    $dumpvars(0,top_testcase100_tb);        // 0表示记录xxx module下的所有信号
end */

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



task get_result(
    input [6:0] input_data_num
);
    integer idx_col, idx_row ;
    @(posedge result_valid_o);
    for( idx_col=0; idx_col<16; idx_col=idx_col+1 ) begin
        for( idx_row=0; idx_row<8; idx_row=idx_row+1 ) begin
            @(posedge clk) ;
            matrix_output[input_data_num][ idx_col ][ idx_row*2 ] = result_out_high ;
            matrix_output[input_data_num][ idx_col ][ idx_row*2+1 ] = result_out_low ;
        end 
    end 
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


endmodule
