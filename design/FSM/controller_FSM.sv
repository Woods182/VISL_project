module controller_FSM (
    input                           clk             ,
    input                           rst_n           ,
    input   [3:0]                   input_load_number,//输入input第几排 0-15
    input   [2:0]                   layer_number,//计算第几层0-7
    input   [2:0]                   weight_number,//0-7  
    output                          result_valid_o,                  
    //dataload
    input                           dataload_weight_valid,
    input                           dataload_input_valid,
    input                          dataload_en_i,
    //pe_array
    input                           array_rounder_vaild,
    output                          array_keep,
    output                          array_rounder_en,
    output                          array_input_type//可以在top实现
);
localparam [2:0] // for 8 states
    IDLE = 0,
    FIRST_LAYER_LDDAT1  = 1,//load 2 weight
    FIRST_LAYER_LDDAT2 = 2, //
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

always_comb begin :N_state
    case (state_cur)
        IDLE : state_next = (!rst_n || !dataload_en_i) ?  IDLE : FIRST_LAYER_LDDAT1 ;
        FIRST_LAYER_LDDAT1  :   state_next =    (!rst_n)                ?       IDLE:
                                                (dataload_weight_valid) ?       FIRST_LAYER_LDDAT2  :
                                                FIRST_LAYER_LDDAT1  ;

        FIRST_LAYER_LDDAT2  :    state_next =   (!rst_n)                ?       IDLE:
                                                (dataload_input_valid)  ?       FIRST_LAYER_NORMAL  :
                                                FIRST_LAYER_LDDAT2  ;                      

        FIRST_LAYER_NORMAL  :    state_next =   (!rst_n)                ?       IDLE:
                                                (weight_number==7 && input_load_number==15)      ?     FIRST_LAYER_ROUND  :
                                                (weight_number==7 && input_load_number <15)      ?     FIRST_LAYER_LDDAT2 :
                                                FIRST_LAYER_ROUND   ;

        FIRST_LAYER_ROUND   :    state_next =   (!rst_n)                ?       IDLE:
                                                (weight_number==7 )     ?       OTHER_LAYER_NORMAL  :
                                                FIRST_LAYER_ROUND   ;

        OTHER_LAYER_NORMAL  :   state_next =    (!rst_n)                ?       IDLE:
                                                (weight_number==7 && input_load_number==15)  ?       OTHER_LAYER_NORMAL  :
                                                OTHER_LAYER_NORMAL   ;

        OTHER_LAYER_ROUND   :   state_next =    (!rst_n)                               ?       IDLE:
                                                (weight_number==7  && layer_number<7)  ?      OTHER_LAYER_NORMAL  :
                                                (weight_number==7  && layer_number==7) ?      OUTPUT              :
                                                OTHER_LAYER_ROUND   ;

        OUTPUT              :   state_next =    (!rst_n)    ?       IDLE   :   OUTPUT;

        default: state_next = IDLE;
    endcase
end
///////////////////////////////////////////////////////////
// output assign
///////////////////////////////////////////////////////////
    logic   array_keep_r;
    logic   array_rounder_en_r=0;
    logic   array_input_type_r=0;
    logic   result_valid_o_r=0;

    assign  array_keep=array_keep_r;
    assign   array_rounder_en=array_rounder_en_r;
    assign   array_input_type=array_input_type_r;
    assign   result_valid_o=result_valid_o_r;


    
always_comb begin : OUTPUT_BLOCK
    //dataload_en_i=0;
    array_keep_r=0;
    array_rounder_en_r=0;
    array_input_type_r=0;
    result_valid_o_r=0;
    case (state_cur)
        IDLE : begin
            //dataload_en_i=0;
            array_keep_r=0;
            array_rounder_en_r=0;
            array_input_type_r=0;
            result_valid_o_r=0;
        end
        FIRST_LAYER_LDDAT1 : begin
            //dataload_en_i=1;
            array_keep_r=0;
            array_rounder_en_r=0;
            array_input_type_r=0;
            result_valid_o_r=0;
        end
        FIRST_LAYER_LDDAT2 : begin
            //dataload_en_i=1;
            array_keep_r=1;
            array_rounder_en_r=0;
            array_input_type_r=0;
            result_valid_o_r=0;
        end
        FIRST_LAYER_NORMAL : begin
            //dataload_en_i=1;
            array_keep_r=0;
            array_rounder_en_r=0;
            array_input_type_r=0;
            result_valid_o_r=0;
        end
        FIRST_LAYER_ROUND : begin
            //dataload_en_i=1;
            array_keep_r=0;
            array_rounder_en_r=1;
            array_input_type_r=0;
            result_valid_o_r=0;
        end
        OTHER_LAYER_NORMAL : begin
            //dataload_en_i=1;
            array_keep_r=0;
            array_rounder_en_r=0;
            array_input_type_r=1;
            result_valid_o_r=0;
        end
        OTHER_LAYER_ROUND : begin
            //dataload_en_i=1;
            array_keep_r=0;
            array_rounder_en_r=1;
            array_input_type_r=1;
            result_valid_o_r=0;
        end
        OUTPUT : begin
            //dataload_en_i=0;
            array_keep_r=0;
            array_rounder_en_r=0;
            array_input_type_r=0;
            result_valid_o_r=1;
        end
    endcase
end

endmodule