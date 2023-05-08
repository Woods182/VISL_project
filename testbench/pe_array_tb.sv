///////////////////////////////////////////////////////////
// Author: woodsning
///////////////////////////////////////////////////////////
`timescale 1ns/1ps
module pe_array_tb();
logic                           clk;
logic                           rst_n,keep,rounder_valid;
logic   [3:0]                   add_number_i;
logic   [3:0]                   round_number_o;
logic                           rounder_en;
logic   [255:0]                 data_input_matrix_i;
logic   [31:0]                  data_weight_matrix_i; 
logic   [1:0][15:0][15:0]       pe_array_o;
pe_array pe_array_inst(
    .clk            (clk),
    .rst_n          (rst_n),
    .data_input_matrix(data_input_matrix_i),//一行16个数，16bit*16
    .data_weight_matrix(data_weight_matrix_i),//一列中的两个数，16bit*2
    .add_number     (add_number_i),
    .rounder_en     (rounder_en),
    .keep           (keep),
    .pe_array_out   (pe_array_o),
    .rounder_valid  (rounder_valid),
    .round_number   (round_number_o)
);
initial begin
    $dumpfile("out/pe_array.vcd"); // 表示dump文件的路径与名字。
    $dumpvars(0,pe_array_tb);        // 0表示记录xxx module下的所有信号
end

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
logic [15:0] i,j;
initial begin
    rst_n = 0;
    data_input_matrix_i = 'b0;
    data_weight_matrix_i = 'b0;
    keep=0;
    rounder_en=0;
    add_number_i=0;
    #50;
    rst_n = 1;
    #10;
    //只mac+0
    for (i = 0; i < 16 ; i++ ) begin
        for(j = 0; j < 8 ; j++ )begin
            add_number_i=j;
            data_input_matrix_i = { 16'd0+i, 16'd1+i, 16'd2+i, 16'd3+i, 16'd4+i,
                        16'd5+i, 16'd6+i, 16'd7+i, 16'd8+i, 16'd9+i,
                        16'd10+i, 16'd11+i, 16'd12+i, 16'd13+i, 16'd14+i,
                        16'd15+i};
            data_weight_matrix_i = { 16'd1+i, 16'd1+i};
            #10;
        end
    end
    //只mac+1
    for (i = 0; i < 16 ; i++ ) begin
        for(j = 0; j < 8 ; j++ )begin
            add_number_i=j;
            data_input_matrix_i = { 16'd0+i, 16'd1+i, 16'd2+i, 16'd3+i, 16'd4+i,
                        16'd5+i, 16'd6+i, 16'd7+i, 16'd8+i, 16'd9+i,
                        16'd10+i, 16'd11+i, 16'd12+i, 16'd13+i, 16'd14+i,
                        16'd15+i};
            data_weight_matrix_i = { 16'd0+j, 16'd1+j};
            #10;
        end
    end
    //keep
    keep=1;
    for (i = 0; i < 16 ; i++ ) begin
        for(j = 0; j < 8 ; j++ )begin
            add_number_i=j;
            data_input_matrix_i = { 16'd0+i, 16'd1+i, 16'd2+i, 16'd3+i, 16'd4+i,
                        16'd5+i, 16'd6+i, 16'd7+i, 16'd8+i, 16'd9+i,
                        16'd10+i, 16'd11+i, 16'd12+i, 16'd13+i, 16'd14+i,
                        16'd15+i};
            data_weight_matrix_i = { 16'd0+j, 16'd1+j};
            #10;
        end
    end    
    //rounder
    keep=0;

    for (i = 0; i < 16 ; i++ ) begin
        if(i==15)begin
            rounder_en=1;
        end
        for(j = 0; j < 8 ; j++ )begin
            add_number_i=j;
            data_input_matrix_i = { 16'd0+i, 16'd1+i, 16'd2+i, 16'd3+i, 16'd4+i,
                        16'd5+i, 16'd6+i, 16'd7+i, 16'd8+i, 16'd9+i,
                        16'd10+i, 16'd11+i, 16'd12+i, 16'd13+i, 16'd14+i,
                        16'd15+i};
            data_weight_matrix_i = { 16'd0+j, 16'd1+j};
            #10;
        end
    end
    rounder_en=0;
    //只mac+0
    for (i = 0; i < 16 ; i++ ) begin
        for(j = 0; j < 8 ; j++ )begin
            add_number_i=j;
            data_input_matrix_i = { 16'd0+i, 16'd1+i, 16'd2+i, 16'd3+i, 16'd4+i,
                        16'd5+i, 16'd6+i, 16'd7+i, 16'd8+i, 16'd9+i,
                        16'd10+i, 16'd11+i, 16'd12+i, 16'd13+i, 16'd14+i,
                        16'd15+i};
            data_weight_matrix_i = { 16'd0+j, 16'd1+j};
            #10;
        end
    end 
    rst_n = 0;
    data_input_matrix_i = 'b0;
    data_weight_matrix_i = 'b0;
    keep=0;
    rounder_en=0;
    add_number_i=0;
    #1000;
    $finish;
end
endmodule