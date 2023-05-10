module rounder_tb();
parameter para_int_bits = 7, para_frac_bits = 9;
logic   [31:0]  rounder_data_in;
logic   [15:0]  rounder_data_out;
rounder  #(
    .para_int_bits(para_int_bits),
    .para_frac_bits(para_frac_bits) 
) (
    .in(rounder_data_in),
    .out(rounder_data_out)
);
initial begin
    $dumpfile("out/rounder.vcd"); // 表示dump文件的路径与名字。
    $dumpvars(0,rounder_tb);        // 0表示记录xxx module下的所有信号
end
initial begin
    rounder_data_in = 32'd17030722;
    #10;
    rounder_data_in = 32'd0;
end
endmodule