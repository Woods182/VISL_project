module MLP_acc_top (
    input           clk,
    input           rst_n,
    input           load_en_i, //开始输入数据
    input  [31:0]   load_payload_i,//
    input           load_type_i,
    input  [3:0]    input_load_number,//输入input第几排 0-15
    input           layer_number,//计算第几层0-7
    input   [2:0]   weight_number,//0-7   
    output          result_valid_o,
    output [31:0]   result_payload_o
);
//dataload
    logic [255:0]  dataload_input_data;
    logic [31:0]   dataload_weight_o;
    logic          dataload_weight_valid,dataload_input_valid;      
    dataload    dataload_inst(
        .clk                        (   clk                     ),
        .rst_n                      (   rst_n                   ),
        .data_i                     (   load_payload_i          ),
        .load_en_i                  (   load_en_i               ),
        .load_type                  (   load_type_i             ),//0-weight,1-input
        .first_level_input_data     (   dataload_input_data     ),
        .weight_o                   (   dataload_weight_o       ), 
        .weight_valid               (   dataload_weight_valid   ),
        .input_valid                (   dataload_input_valid    )    
    );

    logic [255:0]  dataload_input_data_r;
    logic [31:0]   dataload_weight_o_r;
    logic [2:0]    weight_number_r;
    logic [3:0]    input_load_number_r;
    //因为状态机打一拍，所以让输入到array的所有数据都打一拍
    always_ff @(posedge clk) begin
        if(!rst_n)begin
            input_load_number_r <= 'd0;
            weight_number_r     <= 'd0;
        end
        else begin
            input_load_number_r <= input_load_number;
            weight_number_r     <= weight_number;
        end
    end
    always_ff @(posedge clk) begin
        if(!rst_n) begin
            dataload_input_data_r <=  0;
            dataload_weight_o_r   <=  0;
        end
        if(dataload_input_valid) begin 
             dataload_input_data_r  <=  dataload_input_data;
        end
        if(dataload_weight_valid) begin
            dataload_weight_o_r     <=  dataload_weight_o;
        end
    end
//FSM
    logic                   FSM_result_valid_o;
    logic                   FSM_dataload_type_o;
    logic                   FSM_dataload_en_i; 
    logic                   array_rounder_vaild;
    logic                   array_keep;
    logic                   array_rounder_en;
    logic                   array_input_type;                

    controller_FSM controller_FSM_inst (
        .clk                    (   clk     ),
        .rst_n                  (   rst_n   ),
        .input_load_number      (   input_load_number),//输入input第几排 0-15
        .layer_number           (   layer_number),//计算第几层0-7
        .weight_number          (   weight_number),//0-7  
        .result_valid_o         (   FSM_result_valid_o),                  
        .dataload_en_i          (   load_en_i),
        .dataload_weight_valid  (   dataload_weight_valid),
        .dataload_input_valid   (   dataload_input_valid),
        //pe_array
        .array_rounder_vaild    (   array_rounder_vaild),
        .array_keep             (   array_keep),
        .array_rounder_en       (   array_rounder_en),
        .array_input_type       (   array_input_type)
    );

//array input选择
    logic   [255:0]                 data_input_matrix_i;
    assign data_input_matrix_i = ( array_input_type == 0) ? dataload_input_data_r : pe_array_o //按位对应是否相同？
//pe_array
    parameter  col= 16, row = 2
    logic                           array_keep,array_rounder_valid;
    logic   [3:0]                   round_number_o;
    logic                           array_rounder_en;
    logic   [255:0]                 data_input_matrix_i; 
    logic   [1:0][15:0][15:0]       pe_array_o;

    pe_array pe_array_inst(
        .clk                    (   clk                     ),
        .rst_n                  (   rst_n                   ),
        .data_input_matrix      (   data_input_matrix_i     ),//一行16个数，16bit*16
        .data_weight_matrix     (   dataload_weight_o_r     ),//一列中的两个数，16bit*2
        .add_number             (   weight_number_r         ),
        .rounder_en             (   array_rounder_en        ),
        .keep                   (   array_keep              ),
        .pe_array_out           (   pe_array_o              ),//?要不要打拍
        .rounder_valid          (   array_rounder_valid     ),
        .round_number           (   round_number_o          )
    );
//round结果保存
    logic [15:0][15:0][15:0] out_reg;
    always_ff @(posedge clk)begin
            if(!rst_n) begin
                out_reg <= 'd0;
            end
            if(array_rounder_valid) begin
                out_reg[round_number_o*2 + :2] <= pe_array_o;
            end
            else out_reg <= out_reg;
    end
//output
    logic [31:0]   result_payload_o_c
    always_ff @(  posedge clk )begin
        if(result_valid_o ) begin
                串行输出
        end
    end


endmodule