module reg_file#(
    parameter data_width=16,
    parameter reg_number=8,
)(
    input   clk,
    input   rst_n,
    input   en_r,
    input   en_w,
    input [$clo22(data_width)-1:0]data_in,
    input [$clo22(reg_number)-1:0]reg_select_r,reg_select_w,
    output [$clo22(data_width)-1:0]data_out,
)
reg [$clo22(reg_number)-1:0]   dout_reg ;
reg [$clo22(reg_number)-1:0]   RAM [$clo22(data_width)-1:0];

always @(posedge clk ) begin
    if(!rst_n) begin
        RAM[7:0]<='d0;
        dout_reg<='d0;
    end
    else begin
        if (en_w) begin
            RAM[addr_w] <= data_in ;
        end 
        if (en_r) begin
            dout_reg <= RAM[addr_r] ;
        end
    end
end

assign data_out = dout_reg ;
 
endmodule

