module MLP_acc_top (
    input           clk,
    input           rst_n,
    input           load_en_i, //开始输入数据
    input  [31:0]   load_payload_i,//
    output          result_valid_o,
    output [31:0]   result_payload_o
);
    logic [2:0][15:0][15:0] round_out_r;
    logic [15:0][15:0][15:0] reg_out;
    logic round_number;
    logic rounder_valid;
    logic OUTPUT_STATE;
    parameter  col= 16, row = 2

//计数器
counter counter_inst1(
    .cnt_clk    (       )      ,
    .cnt_rst_n  (       )      ,
    .cnt_en     (       )      ,
    .cnt_o      (       )
);
//dataload
dataload    dataload_inst(
    .clk        (),
    .rst_n      (),
    .data_i     (),
    .load_en_i  (),
    .load_type  (),//0-weight,1-input
    .first_level_input_data(),
    .weight_o   (  ), 
    .weight_valid(),
    .input_valid()    
);
//FSM

    pe_array#(.col(col),.row(row)
    )(
        .clk                (   clk),
        .rst_n              (pe_rst_n),
        .data_input_matrix  (buffer[]),//一行16个数，16bit*16
        .data_weight_matrix (buffer[]),//一列中的两个数，16bit*2
        .add_number         (controller_FSM_o   ),
        .rounder_en         (controller_FSM_o),
        .keep               (controller_FSM             ),
        .pe_array_out       (round_out_r),
        .rounder_valid      (rounder_valid),
        .round_number       (round_number),
    );

    always_ff @(    posedge clk )begin
        if(!rst_n) begin
            reg_out<=0;
        end
        else if(rounder_valid)begin
            reg_out[2*round_number+:2]<=round_out_r;
        end
        else reg_out<=reg_out;     
    end
//数据输出
    always_ff @(    posedge clk )begin
        if(result_valid_o ) begin

        end
    end


endmodule