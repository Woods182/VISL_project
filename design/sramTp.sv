module sramTp (
    input       clk,
    input       rst_n,
    input       en_r,
    input       en_w,
    input [3:0] addr_r,
    input [3:0] addr_w,
    input [7:0] din,
    output[7:0] dout
);

reg [7:0]   dout_reg ;
reg [7:0]   RAM [15:0];

always @(posedge clk ) begin
    if (en_w) begin
        RAM[addr_w] <= din ;
    end 
    if (en_r) begin
        dout_reg <= RAM[addr_r] ;
    end
end

assign dout = dout_reg ;

endmodule 
