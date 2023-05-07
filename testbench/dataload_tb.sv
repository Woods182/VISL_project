`timescale 1ns/1ps
module dataload_tb();
    logic           clk  ;
    logic           rst_n       ;
    logic [31:0]    data_i      ;
    logic           load_en_i     ;
    logic           load_en_i;
    logic           load_type;//0-weight,1-input
    logic [255:0]  first_level_input_data;
    logic [31:0]   weight_o;
    logic           weight_valid,input_valid;
    dataload dataload_inst (
        .clk(clk),
        .rst_n(rst_n),
        .data_i(data_i),
        .load_en_i(load_en_i),
        .load_type(load_type),
        .first_level_input_data(first_level_input_data),
        .weight_o(weight_o),
        .weight_valid(weight_valid),
        .input_valid(input_valid)   
    );

    initial begin
        $dumpfile("./out/dataload_tb.vcd");
        $dumpvars(0, dataload_tb);
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    integer i;

    initial begin
        rst_n = 0;
        data_i = 0;
        load_en_i =0;
        load_type =0;
        #100;
        rst_n = 1;
        #10;
        load_en_i = 1;
        load_type =1;
        for (i = 0; i<8 ; i++ ) begin
            data_i = i+10;
            #10;
        end
        load_en_i = 1;
        load_type =0;
        for (i = 0; i<8 ; i++ ) begin
            data_i = i+20;
            #10;
        end
        load_en_i = 0;
        #100;
        rst_n = 0;
        #100;
        $finish;
    end
        
endmodule
