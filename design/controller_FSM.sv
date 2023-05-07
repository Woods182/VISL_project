module controller_FSM #(
    parameter WIDTH_LBIT_CNT = 10,
    parameter WIDTH_HBIT_CNT = 3
    parameter WIDTH_MBIT_CNT = 4,
)(
    input                           clk             ,
    input                           rst_n           ,
    input                           data_rdy_i      ,

    //  counter1
    output                          LCNT_en_o       ,
    output                          LCNT_rst_o      ,
    input  [WIDTH_LBIT_CNT-1 : 0]   LCNT_data_i     ,
    // counter2
    output                          MCNT_en_o       ,
    output                          MCNT_rst_o      ,
    input  [WIDTH_MBIT_CNT-1 : 0]   MCNT_data_i     ,
    //counter3
    output                          HCNT_en_o       ,
    output                          HCNT_rst_o      ,
    input  [WIDTH_HBIT_CNT-1 : 0]   HCNT_data_i     ,

    output                          output_en_o     ,
    output                          read_en_o       ,
    output [1:0]                    wire_connect_o
);
localparam [3:0] // for 8 states
    IDLE = 0,
    FIRST_LAYER_LDDAT = 1, //repeat 8+1 cycle*16
    FIRST_LAYER_NORMAL= 2,  //repeat 8 cycle*16
    FIRST_LAYER_ROUND = 3, //start format module
    OTHER_LAYER_GETDAT = 4, //get the formatted data
    OTHER_LAYER_NORMAL = 5, //repeat 16 cycle
    OTHER_LAYER_ROUND = 6, //start format module
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
        IDLE : begin
            state_next = (loaddata_rdy_i) ?  FIRST_LAYER_LDDAT : IDLE;
        end
        FIRST_LAYER_LDDAT  : begin
            state_next = (!data_rdy_i)      ?     FIRST_LAYER_LDDAT   :
                         (HCNT_data_i==16)  ?     FIRST_LAYER_ROUND   :
                         FIRST_LAYER_NORMAL;                          
        end
        FIRST_LAYER_NORMAL : begin
            state_next = (LCNT_data_i == 8) ? FIRST_LAYER_LDDAT : FIRST_LAYER_NORMAL;
        end
        FIRST_LAYER_ROUND   :begin
            state_next = (LCNT_data_i == 8) ? OTHER_LAYER_NORMAL : FIRST_LAYER_ROUND ;
        end
        OTHER_LAYER_NORMAL : begin
            state_next = (LCNT_data_i == 8*15) ? OTHER_LAYER_ROUND :OTHER_LAYER_NORMAL;
        end
        OTHER_LAYER_ROUND : begin
            if(LCNT_data_i==8)begin
                if(MCNT_data_i==8)begin
                    state_next = OUTPUT;
                end
                else begin
                    state_next =OTHER_LAYER_NORMAL;
                end
            end
            else state_next = OTHER_LAYER_ROUND;
        end
        OUTPUT : begin
            state_next = OUTPUT;
        end
        default: state_next = IDLE;
    endcase
end

///////////////////////////////////////////////////////////
// output assign
///////////////////////////////////////////////////////////
always_comb begin : OUTPUT_BLOCK

    LCNT_en_o_r = 0;
    LCNT_rst_o_r = 1;
    HCNT_en_o_r = 0;
    HCNT_rst_o_r = 1;
    read_en_o_r = 0;
    wire_connect_o_r = 3;
    output_en_o_r = 0;
    case (state_cur)
        IDLE : begin
            LCNT_en_o_r = 0;
            LCNT_rst_o_r = 1;
            HCNT_en_o_r = 0;
            HCNT_rst_o_r = 1;
            read_en_o_r = 0;
            wire_connect_o_r = 3;
        end
        FIRST_LAYER_NORMAL : begin
            LCNT_en_o_r = 1;
            LCNT_rst_o_r = 0;
            HCNT_en_o_r = 0;
            HCNT_rst_o_r = 1;

            read_en_o_r = LCNT_data_i[0];
            wire_connect_o_r = 0;
        end
        FIRST_LAYER_FORMAT : begin
            LCNT_en_o_r = 1;
            LCNT_rst_o_r = 0;
            HCNT_en_o_r = 0;
            HCNT_rst_o_r = 1;

            read_en_o_r = 0;
            wire_connect_o_r = 3;
        end
        OTHER_LAYER_GETDAT : begin
            LCNT_en_o_r = 0;
            LCNT_rst_o_r = 1;
            HCNT_en_o_r = 0;
            HCNT_rst_o_r = 0;

            read_en_o_r = 1;
            wire_connect_o_r = 1;
        end
        OTHER_LAYER_NORMAL : begin
            LCNT_en_o_r = 1;
            LCNT_rst_o_r = 0;
            HCNT_en_o_r = 0;
            HCNT_rst_o_r = 0;

            read_en_o_r = 1;
            wire_connect_o_r = 2;
        end
        OTHER_LAYER_FORMAT : begin
            LCNT_en_o_r = 1;
            LCNT_rst_o_r = 0;
            HCNT_en_o_r = (LCNT_data_i == 17) ? 1 : 0;
            HCNT_rst_o_r = 0;

            read_en_o_r = 0;
            wire_connect_o_r = 3;
        end
        OUTPUT : begin
            LCNT_en_o_r = 0;
            LCNT_rst_o_r = 1;
            HCNT_en_o_r = 0;
            HCNT_rst_o_r = 1;

            read_en_o_r = 0;
            wire_connect_o_r = 3;
            output_en_o_r = 1;
        end
    endcase
end

endmodule