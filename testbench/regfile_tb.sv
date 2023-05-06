///////////////////////////////////////////////////////////
// Author: woodsning
///////////////////////////////////////////////////////////
module regfile_tb ();
    initial begin
        $dumpfile("out/regfile.vcd"); // 表示dump文件的路径与名字。
        $dumpvars(0,regfile_tb);        // 0表示记录xxx module下的所有信号
    end

    parameter data_width=16;
    parameter reg_number=8;

    logic   clk;
    logic    rst_n;
    logic    en_r;
    logic    en_w;
    logic  [data_width-1:0]data_in;
    logic  [$clog2(reg_number)-1:0] reg_select_r,reg_select_w;
    logic  [data_width-1:0]data_out;

    reg_file #(.data_width(data_width),.reg_number(reg_number))
    regfile_inst(
    .clk(clk),
    .rst_n(rst_n),
    .en_r(en_r),
    .en_w(en_w),
    .data_in(data_in),
    .reg_select_r(reg_select_r),
    .reg_select_w(reg_select_w),
    .data_out(data_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    integer  i;

    initial begin
    rst_n=1'b0;
    en_r=0;
    en_w=0;
    #20;
    rst_n=1'b1;
    #10;
    en_w=1'b1;
    //只写
    #10;
    for (i = 0;i<8 ;i++ ) begin
       data_in=16'd0+i;
        reg_select_w=i;
        #10;
    end
    //读和写
    #10;
    en_r=1;
    for (i = 1;i<8 ;i++ ) begin
       #10;
       reg_select_r=i;
       data_in=16'd0+i+10;
       reg_select_w=i-1;
       #10;
    end
    #10 ;
    en_w=0;
    //只读
    for (i = 0;i<8 ;i++ ) begin
       #10;
       reg_select_r=i;
       #10;
    end
    en_r = 1'b0;
    rst_n=1'b0;
    #15;
    $finish;
    end
endmodule