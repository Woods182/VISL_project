module MLP_acc_top (
    input           clk,
    input           rst_n,
    input           load_en_i, //开始输入数据
    input  [31:0]   load_payload_i,//
    input           load_type_i,
    input  [3:0]    input_load_number//输入input第几排
    input           layer_number,//计算第几层
    output          result_valid_o,
    output [31:0]   result_payload_o
);
    logic [2:0][15:0][15:0] round_out_r;
    logic [15:0][15:0][15:0] reg_out;
    logic round_number;
    logic rounder_valid;
    logic OUTPUT_STATE;


//dataload
    logic [255:0]  dataload_input_data;
    logic [31:0]   dataload_weight_o;
    logic          dataload_weight_valid,dataload_input_valid;      
    dataload    dataload_inst(
        .clk        (clk),
        .rst_n      (rst_n),
        .data_i     (load_payload_i),
        .load_en_i  (load_en_i),
        .load_type  (load_type_i),//0-weight,1-input
        .first_level_input_data(dataload_input_data),
        .weight_o   (dataload_weight_o), 
        .weight_valid(dataload_weight_valid),
        .input_valid(dataload_input_valid)    
    );


//计数器
    parameter cnt_WIDTH = 8;
    logic cnt_en,cnt_rst_n;
    logic [cnt_WIDTH-1:0]    cnt_out;
    counter # (.cnt_WIDTH(cnt_WIDTH)
    )   counter_inst1   (
        .cnt_clk    (clk            )      ,
        .cnt_rst_n  (cnt_rst_n      )      ,
        .cnt_en     (cnt_en         )      ,
        .cnt_o      (cnt_o          )
    );
//FSM

//array input选择
logic   [255:0]                 data_input_matrix_i;
assign data_input_matrix_i = (layer_number == 1) ? dataload_input_data : pe_array_o //按位对应是否相同？
//pe_array
    parameter  col= 16, row = 2
    logic                           array_keep,array_rounder_valid;
    logic   [3:0]                   add_number_i;
    logic   [3:0]                   round_number_o;
    logic                           array_rounder_en;
    logic   [255:0]                 data_input_matrix_i;
    logic   [31:0]                  data_weight_matrix_i; 
    logic   [1:0][15:0][15:0]       pe_array_o;

    pe_array pe_array_inst(
        .clk            (clk),
        .rst_n          (rst_n),
        .data_input_matrix(data_input_matrix_i),//一行16个数，16bit*16
        .data_weight_matrix(data_weight_matrix_i),//一列中的两个数，16bit*2
        .add_number     (add_number_i),//cnt控制
        .rounder_en     (array_rounder_en),
        .keep           (array_keep),
        .pe_array_out   (pe_array_o),
        .rounder_valid  (array_rounder_valid),
        .round_number   (round_number_o)
    );
    //round结果保存
    logic [15:0][15:0][15:0] out_reg;
   always_ff @(posedge clk)begin
        if(!rst_n) out_reg<=0;
        if(array_rounder_valid) begin
            out_reg[round_number_o*2 + :2] <= pe_array_o;
        end
        else out_reg    <=  out_reg;
   end
    //output
        always_ff @(  posedge clk )begin
            if(result_valid_o ) begin
                    串行输出
            end
        end


endmodule