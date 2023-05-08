module controller_FSM #(
    parameter WIDTH_LBIT_CNT = 10,
    parameter WIDTH_HBIT_CNT = 3
    parameter WIDTH_MBIT_CNT = 4,
)(
    input                           clk             ,
    input                           rst_n           ,
    output                          result_valid_o,                  
    //dataload
    input                           dataload_weight_valid,
    input                           dataload_input_valid,
    output                          dataload_type,
    output                          dataload_en_i,
    //pe_array
    input                           array_rounder_vaild,
    output                          array_keep,
    output                          array_rounder_en,
    output                          array_input_type,//可以在top实现

    //  counter1
    output                          LCNT_en_o       ,
    output                          LCNT_rst_o      ,
    input  [WIDTH_LBIT_CNT-1 : 0]   LCNT_data_i     ,

);
localparam [2:0] // for 8 states
    IDLE = 0,
    FIRST_LAYER_LDDAT1  = 1//load 2 weight
    FIRST_LAYER_LDDAT2 = 2, //load one row weight cycle*16
    FIRST_LAYER_NORMAL= 3,  
    FIRST_LAYER_ROUND = 4, 
    OTHER_LAYER_NORMAL = 5, 
    OTHER_LAYER_ROUND = 6, 
    OUTPUT = 7;

reg[3:0] state_cur, state_next;
always_ff @( posedge clk ) begin
    if (!rst_n) begin
        state_cur <= IDLE;
    end else begin
        state_cur <= state_next;
    end
end
/*
还需要的接口
                                    input_load_number 初始输入的是第几排信号
                                    layer_number    在计算第几层
                                    clk_cnt_en_o_r
                                    clk_cnt_rst_o_r
                                    clk_cnt_data_i  时钟计数输出
*/
always_comb begin :N_state
    case (state_cur)
        IDLE : state_next = (!rst_n) ?  IDLE : FIRST_LAYER_LDDAT1 ;
        FIRST_LAYER_LDDAT1  :   state_next =    (!rst_n)                ?       IDLE:
                                                (dataload_weight_valid) ?       FIRST_LAYER_LDDAT2  :
                                                                                FIRST_LAYER_LDDAT1  ;


        FIRST_LAYER_LDDAT2  :    state_next =   (!rst_n)                ?       IDLE:
                                                (dataload_input_valid)  ?       FIRST_LAYER_NORMAL  :
                                                                                FIRST_LAYER_LDDAT2  ;                      

        FIRST_LAYER_NORMAL  :    state_next =   (!rst_n)                ?       IDLE:
                                                (clk_cnt_data_i==8 && input_load_number==15)      ?     FIRST_LAYER_ROUND  ://8还是7
                                                (clk_cnt_data_i==8 && input_load_number < 15)     ?     FIRST_LAYER_LDDAT2 :
                                                                                                        FIRST_LAYER_ROUND   ;

        FIRST_LAYER_ROUND   :    state_next =   (!rst_n)                ?       IDLE:
                                                (clk_cnt_data_i==8)     ?       OTHER_LAYER_NORMAL  ://8还是7
                                                FIRST_LAYER_ROUND   ;

        OTHER_LAYER_NORMAL  :   state_next =    (!rst_n)                ?       IDLE:
                                                (clk_cnt_data_i==8*15)  ?       OTHER_LAYER_NORMAL  ://8还是7
                                                OTHER_LAYER_NORMAL   ;

        OTHER_LAYER_ROUND   :   state_next =    (!rst_n)                ?       IDLE:
                                                (clk_cnt_data_i==8 && layer_number<8)  ?      OTHER_LAYER_NORMAL  ://8还是7
                                                (clk_cnt_data_i==8 && layer_number==8) ?      OUTPUT              :
                                                OTHER_LAYER_ROUND   ;

        OUTPUT : state_next =    (!rst_n)                ?       IDLE:OUTPUT;
        default: state_next = IDLE;
    endcase
end

///////////////////////////////////////////////////////////
// output assign
///////////////////////////////////////////////////////////
always_comb begin : OUTPUT_BLOCK
    dataload_type=0;
    dataload_en_i=0;
    array_keep=0;
    array_rounder_en=0;
    array_input_type=0;
    result_valid_o=0;
    case (state_cur)
        IDLE : begin
            dataload_type=0;
            dataload_en_i=0;
            array_keep=0;
            array_rounder_en=0;
            array_input_type=0;
            result_valid_o=0;
        end
        FIRST_LAYER_LDDAT1 : begin
            dataload_type=0;
            dataload_en_i=1;
            array_keep=0;
            array_rounder_en=0;
            array_input_type=0;
            result_valid_o=0;
        end
        FIRST_LAYER_LDDAT2 : begin
            dataload_type=1;
            dataload_en_i=1;
            array_keep=1;
            array_rounder_en=0;
            array_input_type=0;
            result_valid_o=0;
        end
        FIRST_LAYER_NORMAL : begin
            dataload_type=0;
            dataload_en_i=1;
            array_keep=0;
            array_rounder_en=0;
            array_input_type=0;
            result_valid_o=0;
        end
        FIRST_LAYER_ROUND : begin
            dataload_type=0;
            dataload_en_i=1;
            array_keep=0;
            array_rounder_en=1;
            array_input_type=0;
            result_valid_o=0;
        end
        OTHER_LAYER_NORMAL : begin
            dataload_type=0;
            dataload_en_i=1;
            array_keep=0;
            array_rounder_en=0;
            array_input_type=1;
            result_valid_o=0;
        end
        OTHER_LAYER_ROUND : begin
            dataload_type=0;
            dataload_en_i=1;
            array_keep=0;
            array_rounder_en=1;
            array_input_type=1;
            result_valid_o=0;
        end
        OUTPUT : begin
            dataload_type=0;
            dataload_en_i=0;
            array_keep=0;
            array_rounder_en=0;
            array_input_type=0;
            result_valid_o=1;
        end
    endcase
end

endmodule