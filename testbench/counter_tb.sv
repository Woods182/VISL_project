`timescale 1ns/1ps
module counter_tb();
    logic   clk,rst_n,cnt_en;
    logic   [4:0] out;
    counter(
        .cnt_clk(clk)        ,
        .cnt_rst_n(rst_n)    ,
        .cnt_en(cnt_en)      ,
        .cnt_o(out)
    );
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("./out/tb_counter.vcd");
        $dumpvars(0, counter_tb);
    end

    initial begin
        rst_n=0;
        #10;
        rst_n=1;
        cnt_en=1;
        #200;
        rst_n=0;
        cnt_en=1;
        #200;
        rst_n=1;
        cnt_en=0;
        #200
        rst_n=0;
        cnt_en=0;
        $finish;
    end

endmodule
