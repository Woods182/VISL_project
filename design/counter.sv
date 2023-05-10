///////////////////////////////////////////////////////////
// Author: woodsning
///////////////////////////////////////////////////////////
module counter#(    cnt_WIDTH   =   4
)(
    input                            cnt_clk        ,
    input                            cnt_rst_n      ,
    input                            cnt_en         ,
    output        [cnt_WIDTH-1:0]              cnt_o
);
logic [cnt_WIDTH-1:0] counter;
always_ff @(    posedge cnt_clk     )begin
    if(!cnt_rst_n) begin
        counter<=0;
    end
    else if(cnt_en)begin
        counter<=counter+1;
    end 
    else counter<=counter;
end
assign cnt_o=counter;
endmodule