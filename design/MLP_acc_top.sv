module MLP_acc_top (
    input           clk,
    input           rst_n,
    input           load_en_i, //开始输入数据
    input  [31:0]   load_payload_i,//
    input           load_type_i,//input-1,weight-0
    input  [3:0]    input_load_number,//输入input第几排 0-15
    input  [2:0]    layer_number,//计算第几层0-7
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
    logic           load_type_i_r;
    logic  [3:0]    input_load_number_r;//输入input第几排 0-15
    logic  [2:0]    layer_number_r;//计算第几层0-7
    logic  [2:0]    weight_number_r;
//因为dataload打一拍，所以让输入到array的loadtype打一拍
    always_ff @(posedge clk) begin
        if(!rst_n)begin
            load_type_i_r <= 'd0;
            input_load_number_r<= 'd0;
            layer_number_r<= 'd0;
            weight_number_r<= 'd0;
        end
        else begin
            load_type_i_r <= load_type_i;
            input_load_number_r<= input_load_number;
            layer_number_r<= layer_number;
            weight_number_r<= weight_number;
        end
    end

//array input选择，控制信号
    logic   [15:0][15:0][15:0]      out_reg;
    logic   [15:0][15:0]                data_input_matrix_i;
    assign data_input_matrix_i = ( layer_number_r == 0) ? dataload_input_data : out_reg[input_load_number_r] ;//按位对应是否相同？
    assign  array_rounder_en =  (input_load_number_r == 15) && (dataload_weight_valid)  ;
    assign  array_keep =    load_type_i;

//pe_array
    parameter  col= 16, row = 2;
    logic                           array_keep,array_rounder_valid;
    logic   [3:0]                   round_number_o;
    logic                           array_rounder_en;
    logic   [255:0]                 data_input_matrix_i; 
    logic   [1:0][15:0][15:0]       pe_array_o;

    pe_array pe_array_inst(
        .clk                    (   clk                     ),
        .rst_n                  (   rst_n                   ),
        .data_input_matrix      (   data_input_matrix_i     ),//一行16个数，16bit*16
        .data_weight_matrix     (   dataload_weight_o       ),//一列中的两个数，16bit*2
        .add_number             (   weight_number_r         ),
        .rounder_en             (   array_rounder_en        ),
        .keep                   (   array_keep              ),
        .pe_array_out           (   pe_array_o              ),//?要不要打拍
        .rounder_valid          (   array_rounder_valid     ),
        .round_number           (   round_number_o          )
    );
//round结果保存
    reg [3:0] round_number_o_r;
    assign  round_number_o_r =   round_number_o;
    
    /* always_ff @(posedge clk)begin
            if(!rst_n) begin
                out_reg <= 'd0;
            end
            if(array_rounder_valid) begin
                //out_reg[round_number_o_r*2 +1: round_number_o_r*2] <= pe_array_o;
                out_reg[1:0] <= pe_array_o;
                out_reg <= (out_reg<<2*16*16);
                
            end
    end */
    
//output
logic [2:0] layer_num_rr,layer_num_r,layer_num_rrr;
always_ff   @(posedge  clk)begin
    if(!rst_n)begin
        layer_num_r<=0;
        layer_num_rr<=0;
        layer_num_rrr<=0;
    end
    else begin
        layer_num_r<=layer_number_r;
        layer_num_rr<=layer_num_r;
        layer_num_rrr<=layer_num_rr;
    end
end

    logic [31:0]   result_payload_o_c;
    logic           result_valid_o_r,result_valid_o_rr;
    always_ff @(posedge clk)begin
        if(!rst_n)begin
            result_valid_o_r <= 0;
        end
        else begin
                if((layer_num_rrr == 7) &&(round_number_o_r==7 )&&(array_rounder_valid)) begin
                    result_valid_o_r  <= 1;
                end
                else begin
                    result_valid_o_r <= result_valid_o_r;
                end
        end
    end



    always_ff @(  posedge clk )begin
        if(!rst_n)begin
            result_valid_o_rr<=0;
            result_payload_o_c<=0;
        end
        else begin
            result_valid_o_rr<=result_valid_o_r;
            if(result_valid_o_r ) begin
                    result_payload_o_c <= out_reg [0][0];
                    out_reg <=  (out_reg >> 32);
            end
            else if(array_rounder_valid) begin
                //out_reg[round_number_o_r*2 +1: round_number_o_r*2] <= pe_array_o;
                out_reg <= {out_reg[13:0],pe_array_o};
            end
            else begin
                result_valid_o_rr <=0;
            end
        end
    end
    assign result_payload_o =   result_payload_o_c ;
    assign result_valid_o   =   result_valid_o_rr  ;
endmodule