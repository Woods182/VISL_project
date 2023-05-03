module test_tb ( );
    reg [2:0] a,b;
    wire  [3:0] c;
    test test1(.a(a),.b(b),.c(c));
    
    initial begin
    $dumpfile("out/test.vcd"); // 表示dump文件的路径与名字。
    $dumpvars(0,test_tb);        // 0表示记录xxx module下的所有信号
    end

    initial begin
        #10;
        a=3'd0;
        b=3'd3;
        #20;
        a=3'd2;
        b=3'd3;
        #40;
        a=3'd2;
        b=3'd3;
        #10;
        a=0;
        b=0;
        $finish;
    end
endmodule