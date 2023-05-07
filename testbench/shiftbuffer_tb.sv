`timescale 1ns/1ps
module shiftbuffer_tb();
    logic           clk  ;
    logic           rst_n       ;
    logic [31:0]    data_i      ;
    logic           wr_en_i     ;
    logic [255:0]   data_o      ;
    logic           data_valid_o;

    shift_buffer shift_buffer_inst (
        .clk(clk),
        .rst_n(rst_n),
        .data_i(data_i),
        .wr_en_i(wr_en_i),
        .data_o(data_o),
        .data_valid_o(data_valid_o)
    );

    initial begin
        $dumpfile("./out/shiftbuffer_tb.vcd");
        $dumpvars(0, shiftbuffer_tb);
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    integer i;

    initial begin
        rst_n = 0;
        data_i = 0;
        wr_en_i = 0;
        #100;
        rst_n = 1;
        #10;
        wr_en_i = 1;
        for (i = 0; i<8 ; i++ ) begin
            data_i = i+10;
            #10;
        end
        for (i = 0; i<8 ; i++ ) begin
            data_i = i+20;
            #10;
        end
        wr_en_i = 0;
        #100;
        wr_en_i = 1;
        for (i = 0; i<8 ; i++ ) begin
            data_i = i+30;
            #10;
        end
        #100;
        $finish;
    end
        
endmodule
