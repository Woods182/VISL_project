module fixedpoint_formatter_tb();
logic   [31:0]  rounder_data_in;
logic   [15:0]  rounder_data_out;
fixedpoint_formatter fixedpoint_formatte_inst(
    .data_i(rounder_data_in),
    .data_o(rounder_data_out)  
);
initial begin
    $dumpfile("out/fixedpoint_formatter.vcd"); // 表示dump文件的路径与名字。
    $dumpvars(0,fixedpoint_formatter_tb);        // 0表示记录xxx module下的所有信号
end
initial begin
    rounder_data_in = 32'd17030722;
    #10;
    rounder_data_in = 32'd0;
end
endmodule