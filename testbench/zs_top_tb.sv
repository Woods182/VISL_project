
module top_tb();

localparam LAYER_N  = 8   ;
localparam INPUT_R  = 16  ;
localparam INPUT_C  = 16  ;
localparam INIT_DW  = 32  ;
localparam MAT_C    = 16  ;
localparam MAT_R    = 2   ;
localparam MEM_W_DP = 1024;   // memory weight depth 
localparam MEM_F_DP = 1024;   // memory feature depth
localparam DL       = 16  ;   // data length
localparam DW       = 16  ;
localparam DIW      = 7   ;
localparam DFW      = 9   ;
localparam INIT_SECT     = INIT_DW/DW ; // 32/16
localparam INIT_TIME_ROW = MAT_C/INIT_SECT ;    // Time for single row ( 16/2 )
localparam INIT_ROWS_NUM = LAYER_N * INPUT_R ;  // The number of rows
localparam INIT_TIME_TOT = INIT_ROWS_NUM * INIT_TIME_ROW ; // Total time
localparam INIT_MASK     = {(INIT_SECT){1'b1} };

logic [63:0]    clk_cnt ;
reg             clk             ;
reg             rst_n           ;
reg             start_ready     ;
wire            start_valid     ;
wire            init_ready      ;
reg             init_valid      ;
wire            load_ready      ;
reg   [31:0]    load_payload    ;
wire            result_valid    ;
wire  [31:0]    result_payload  ;

reg             init_valid_pre ;
reg             start_ready_pre ;
reg   [31:0]    load_payload_pre    ;

reg   [DW-1:0]  matrix_weight [LAYER_N-1:0] [INPUT_R-1:0] [ INPUT_C-1:0 ] ;
reg   [DW-1:0]  matrix_inputs [INPUT_R-1:0] [ INPUT_C-1:0 ] ;
reg   [DW-1:0]  matrix_reference [INPUT_R-1:0] [ INPUT_C-1:0 ] ;
reg   [DW-1:0]  matrix_output [INPUT_R-1:0] [ INPUT_C-1:0 ] ;

integer         time_start ;
integer         time_end ;
// integer         time_consume ;

top inst_top(
.clk            ( clk ),
.rst_n          ( rst_n ),
.start_ready    ( start_ready ),
.start_valid    ( start_valid ),
.init_ready     ( init_ready ),
.init_valid     ( init_valid ),
.load_ready     ( load_ready ),
.load_payload   ( load_payload ),
.result_valid   ( result_valid ),
.result_payload ( result_payload )
);

always @(posedge clk) begin
    init_valid      <= init_valid_pre ;
    start_ready     <= start_ready_pre ;
    load_payload    <= load_payload_pre ;
end 

initial begin
    printf("---------------------------------");
    printf("Start the simulation.", "green");
    printf("---------------------------------");

    all_signals_idle();
    init_matrix_weight_with_file();
    init_matrix_inputs_with_file();
    // init_matrix_weight();
    // init_matrix_inputs();
    
    sys_rst(100);
    $write("INIT_TIME_TOT = %d\n", INIT_TIME_TOT);
    $write("INIT_ROWS_NUM = %d\n", INIT_ROWS_NUM);

    time_start = clk_cnt ;
    printf("Start init_weights.", "normal");
    init_weights();
    printf("Finish init_weights.", "normal");

    printf("Start computing first layer.", "normal");
    do_first_layer();
    printf("Finish icomputing first layer.", "normal");

    printf("Start computing other layers.", "normal");
    get_result();
    printf("Finish computing other layers.", "normal");
    time_end = clk_cnt ;

    delay(1000);
    compare_result();
    $display( "There are %d clock.", time_end-time_start );

    printf("---------------------------------");
    printf("Simulation is finished.", "green");
    printf("---------------------------------");
    $write("Totally %8d clock cycles passed.\n",clk_cnt);
    $finish ;
end

// *************************************************************************************
// custom task
// *************************************************************************************
task all_signals_idle();
    init_valid_pre   = 0 ;
    start_ready_pre  = 0 ;
    load_payload_pre = 0 ;
endtask


task init_matrix_inputs_with_file();
    integer fd, code ;
    integer idx_mat_r, idx_mat_c ;
    fd = $fopen("../../test/testcase/Input.txt", "r");
    for( idx_mat_c=0; idx_mat_c<INPUT_C; idx_mat_c=idx_mat_c+1 ) begin
        for( idx_mat_r=0; idx_mat_r<INPUT_R; idx_mat_r=idx_mat_r+1 ) begin
            code = $fscanf(fd, "%b", matrix_inputs[idx_mat_r][idx_mat_c]);
        end
    end
    $fclose(fd);
endtask 

task init_matrix_weight_with_file();
    integer fd, code ;
    integer idx_layer, idx_mat_r, idx_mat_c ;
    fd = $fopen("../../test/testcase/Weight.txt", "r");
    for(idx_layer=0; idx_layer<LAYER_N; idx_layer=idx_layer+1) begin
        for( idx_mat_c=0; idx_mat_c<INPUT_C; idx_mat_c=idx_mat_c+1 ) begin
            for( idx_mat_r=0; idx_mat_r<INPUT_R; idx_mat_r=idx_mat_r+1 ) begin
                code = $fscanf(fd, "%b", matrix_weight[idx_layer][idx_mat_r][idx_mat_c]);
            end
        end        
    end
    $fclose(fd);
endtask

task init_matrix_reference_with_file();
    integer fd, code ;
    integer idx_mat_r, idx_mat_c ;
    fd = $fopen("../../test/testcase/Output.txt", "r");
    for( idx_mat_c=0; idx_mat_c<INPUT_C; idx_mat_c=idx_mat_c+1 ) begin
        for( idx_mat_r=0; idx_mat_r<INPUT_R; idx_mat_r=idx_mat_r+1 ) begin
            code = $fscanf(fd, "%b", matrix_reference[idx_mat_r][idx_mat_c]);
        end
    end
    $fclose(fd);
endtask 

task init_matrix_weight();
    integer idx_layer, idx_mat_r, idx_mat_c ;
    for(idx_layer=0; idx_layer<LAYER_N; idx_layer=idx_layer+1) begin
        for( idx_mat_r=0; idx_mat_r<INPUT_R; idx_mat_r=idx_mat_r+1 ) begin
            for( idx_mat_c=0; idx_mat_c<INPUT_C; idx_mat_c=idx_mat_c+1 ) begin
                matrix_weight[idx_layer][idx_mat_r][idx_mat_c] = idx_mat_r + idx_mat_c ;
            end
        end        
    end
endtask

task init_matrix_inputs();
    integer idx_mat_r, idx_mat_c ;
    for( idx_mat_r=0; idx_mat_r<INPUT_R; idx_mat_r=idx_mat_r+1 ) begin
        for( idx_mat_c=0; idx_mat_c<INPUT_C; idx_mat_c=idx_mat_c+1 ) begin
            matrix_inputs[idx_mat_r][idx_mat_c] = idx_mat_r + idx_mat_c ;
        end
    end
endtask

task init_weights();
    integer idx_init_i, idx_init_j, idx_init_k ;
    init_valid_pre = 1 ;
    delay(1);
    for ( idx_init_i=0; idx_init_i<LAYER_N; idx_init_i=idx_init_i+1 ) begin
        for ( idx_init_j=0; idx_init_j<INPUT_R; idx_init_j=idx_init_j+1 ) begin
            for ( idx_init_k=0; idx_init_k<INIT_TIME_ROW; idx_init_k=idx_init_k+1 ) begin
                load_payload_pre = { matrix_weight[idx_init_i][idx_init_j][idx_init_k*2+1], matrix_weight[idx_init_i][idx_init_j][idx_init_k*2] };
                delay(1);
            end 
        end
    end
    init_valid_pre   = 0 ;
    load_payload_pre = 0 ;
endtask 

task do_first_layer();
    integer idx_first_col, idx_first_row ;
    start_ready_pre = 1 ;
    delay(2);
    for( idx_first_row=0; idx_first_row<8; idx_first_row=idx_first_row+1 ) begin
        for( idx_first_col=0; idx_first_col<16; idx_first_col=idx_first_col+1 ) begin
            // load_payload_pre = { {idx_first_col}[DW-1:0], {idx_first_col}[DW-1:0] } ;
            load_payload_pre = { matrix_inputs[idx_first_row*2+1][idx_first_col], matrix_inputs[idx_first_row*2][idx_first_col] } ;
            delay(1);
        end
    end
    start_ready_pre  = 0 ;
    delay(1);
endtask 

task get_result();
    integer idx_col, idx_row ;
    @(posedge result_valid);
    printf("Parsing Result.", "normal");
    for( idx_col=0; idx_col<16; idx_col=idx_col+1 ) begin
        for( idx_row=0; idx_row<8; idx_row=idx_row+1 ) begin
            @(posedge clk) ;
            // $display( "%h", result_payload);
            matrix_output[ idx_row*2+1 ][ idx_col ] = result_payload[DW+:DW] ;
            matrix_output[ idx_row*2+0 ][ idx_col ] = result_payload[0 +DW] ;
        end 
    end 
    printf("Done Parsing Result.", "normal");
endtask 

task compare_result();
    integer idx_col, idx_row ;
    integer error_cnt ;
    error_cnt = 0 ;
    for( idx_col=0; idx_col<16; idx_col=idx_col+1 ) begin
        for( idx_row=0; idx_row<16; idx_row=idx_row+1 ) begin
            if( matrix_output[idx_row][idx_col] != matrix_reference[idx_row][idx_col] ) begin
                error_cnt = error_cnt + 1 ;
            end
        end 
    end 
    $display( "There are %d errors.", error_cnt );
endtask 

// *************************************************************************************
// Necessary Component
// *************************************************************************************
parameter CLK_CYCLE = 10 ;

always begin
    clk = 0 ; #(CLK_CYCLE/2) ;
    clk = 1 ; #(CLK_CYCLE/2) ;
end

initial begin
    clk_cnt = 0 ;
end
always @(posedge clk) begin
    if(rst_n == 0) begin
        clk_cnt <= 0 ;
    end else begin
        clk_cnt <= clk_cnt + 1 ;
    end
end

initial begin
    $dumpfile("out/dump.vcd"); 
    $dumpvars(0, top_tb);
    $dumpon;
end

// *************************************************************************************
// Useful task
// *************************************************************************************
task delay(
    input [31:0] cycles
);
integer idx;
for(idx=0; idx<cycles; idx=idx+1) begin
    #(CLK_CYCLE) ;
end
endtask 

task sys_rst(
    input [31:0] cycles
);
    rst_n = 0 ;
    delay(cycles);
    rst_n = 1 ;
endtask 

task printf( string text, string color="normal" );
    if( color == "normal" ) begin
        $display( "%s", text );
    end else if (color == "red") begin
        $display("\033[0m\033[1;31m%s\033[0m", text);
    end else if(color == "green")begin
        $display("\033[0m\033[1;32m%s\033[0m", text);
    end else if (color == "yellow") begin
        $display("\033[0m\033[1;33m%s\033[0m", text);
    end else if (color == "blue") begin
        $display("\033[0m\033[1;34m%s\033[0m", text);
    end else if (color == "pink") begin
        $display("\033[0m\033[1;35m%s\033[0m", text);
    end else if (color == "cyan") begin
        $display("\033[0m\033[1;36m%s\033[0m", text);
    end 
endtask
task printf_red(string text);
    $display("\033[0m\033[1;31m%s\033[0m", text);
endtask 
task printf_green(string text);
    $display("\033[0m\033[1;32m%s\033[0m", text);
endtask 
task printf_yellow(string text);
    $display("\033[0m\033[1;33m%s\033[0m", text);
endtask 
task printf_blue(string text);
    $display("\033[0m\033[1;34m%s\033[0m", text);
endtask 
task printf_pink(string text);
    $display("\033[0m\033[1;35m%s\033[0m", text);
endtask 
task printf_cyan(string text);
    $display("\033[0m\033[1;36m%s\033[0m", text);
endtask 

task set_display_color(string color="normal");
    if( color == "normal" ) begin
        $write( "\033[0m" );
    end else if (color == "red") begin
        $write( "\033[0m\033[1;31m" );
    end else if(color == "green")begin
        $write( "\033[0m\033[1;32m" );
    end else if (color == "yellow") begin
        $write( "\033[0m\033[1;33m" );
    end else if (color == "blue") begin
        $write( "\033[0m\033[1;34m" );
    end else if (color == "pink") begin
        $write( "\033[0m\033[1;35m" );
    end else if (color == "cyan") begin
        $write( "\033[0m\033[1;36m" );
    end 
endtask 
task unset_display_color();
    $write("\033[0m");
endtask 


endmodule 
