module dataload(
    input           clk,
    input           rst_n,
    input  [31:0]   data_i,
    input           load_en_i,
    input           load_type,//0-weight,1-input
    output [255:0]  first_level_input_data,
    output [31:0]   weight_o, 
    output          weight_valid,
    output          input_valid    
);
    logic weight_wr_en,input_wr_en;
    shift_buffer #(.buffer_SIZE(1),.buffer_WIDTH(32)
    ) weight_buffer_inst (
        .clk(clk),
        .rst_n(rst_n)   ,
        .data_i(data_i)  ,
        .wr_en_i(weight_wr_en) ,
        .data_o(weight_o)  ,
        .data_valid_o(weight_valid)
    );
    
    shift_buffer input_buffer_inst (
        .clk(clk),
        .rst_n(rst_n)   ,
        .data_i(data_i)  ,
        .wr_en_i(input_wr_en) ,
        .data_o(first_level_input_data)  ,
        .data_valid_o(input_valid)
    );

    always_comb begin: enable_select
    case ({load_en_i,load_type})
        2'b11: begin//输入到input
            weight_wr_en=0;
            input_wr_en=1;
        end
        2'b10: begin//输入到weight
            weight_wr_en=1;
            input_wr_en=0;
        end
        default: begin
            weight_wr_en=0;
            input_wr_en=0;
        end
    endcase
    end
endmodule