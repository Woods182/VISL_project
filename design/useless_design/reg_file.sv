///////////////////////////////////////////////////////////
// Author: woodsning
///////////////////////////////////////////////////////////
module reg_file#(
    parameter data_width=16,
    parameter reg_number=8
)(
    input   clk,
    input   rst_n,
    input   en_r,
    input   en_w,
    input   [data_width-1:0] data_in,
    input   [$clog2(reg_number):0] reg_select_r, reg_select_w,
    output  [data_width-1:0] data_out
);

logic [data_width-1:0]   dout_reg;
logic [data_width-1:0]   RAM [reg_number-1:0];

always @(posedge clk) begin
    if (!rst_n) begin
        dout_reg <= 'd0;
    end else begin
        if (en_w) begin
            RAM[reg_select_w] <= data_in;
        end
        if (en_r) begin
            dout_reg <= RAM[reg_select_r];
        end
    end
end

genvar i;
generate
    for (i = 0; i < reg_number; i++) begin : ram_reset
        always @(posedge clk) begin
            if (!rst_n) begin
                RAM[i] <= 'd0;
            end
        end
    end
endgenerate

assign data_out = dout_reg;

endmodule