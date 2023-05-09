module test_tb ( );
    reg   [7:0] [15:0] [ 15:0 ][15:0]  matrix_weight  ;
    reg   [15:0] [ 15:0 ][15:0]  matrix_inputs  ;
    reg   [15:0] [ 15:0 ][15:0]  matrix_reference  ;

    initial begin
    $dumpfile("out/test.vcd"); // 表示dump文件的路径与名字。
    $dumpvars(0,test1_tb);        // 0表示记录xxx module下的所有信号
    end

    initial begin
        printf("---------------------------------");
        printf("Start the simulation.", "green");
        printf("---------------------------------");
        init_matrix_weight_with_file();
        init_matrix_inputs_with_file();

    end

task init_matrix_inputs_with_file();
    integer fd, code ;
    integer idx_mat_r, idx_mat_c ;
    fd = $fopen("./testcase/Input.txt", "r");
    for( idx_mat_c=0; idx_mat_c<16; idx_mat_c=idx_mat_c+1 ) begin
        for( idx_mat_r=0; idx_mat_r<16; idx_mat_r=idx_mat_r+1 ) begin
            code = $fscanf(fd, "%b", matrix_inputs[idx_mat_r][idx_mat_c]);
        end
    end
    $fclose(fd);
endtask 

task init_matrix_weight_with_file();
    integer fd, code ;
    integer idx_layer, idx_mat_r, idx_mat_c ;
    fd = $fopen("./testcase/Weight.txt", "r");
    for(idx_layer=0; idx_layer<8; idx_layer=idx_layer+1) begin
        for( idx_mat_c=0; idx_mat_c<16; idx_mat_c=idx_mat_c+1 ) begin
            for( idx_mat_r=0; idx_mat_r<16; idx_mat_r=idx_mat_r+1 ) begin
                code = $fscanf(fd,"%b", matrix_weight[idx_layer][idx_mat_r][idx_mat_c]);
            end
        end        
    end
    $fclose(fd);
endtask

task init_matrix_reference_with_file();
    integer fd, code ;
    integer idx_mat_r, idx_mat_c ;
    fd = $fopen("./testcase/Output.txt", "r");
    for( idx_mat_c=0; idx_mat_c<16; idx_mat_c=idx_mat_c+1 ) begin
        for( idx_mat_r=0; idx_mat_r<16; idx_mat_r=idx_mat_r+1 ) begin
            code = $fscanf(fd, "%b", matrix_reference[idx_mat_r][idx_mat_c]);
        end
    end
    $fclose(fd);
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