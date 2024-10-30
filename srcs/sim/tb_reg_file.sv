module tb_reg_file;

    // Declare testbench variables
    logic clk;
    
    logic [4:0] rd_addr_1;
    logic [4:0] rd_addr_2;
    logic [31:0] rd_data_1;
    logic [31:0] rd_data_2;
    
    logic wr_en;
    logic [4:0] wr_addr;
    logic [31:0] wr_data;

    // Instantiate Reg_File (Unit Under Test
    reg_file uut (
        .clk(clk),
        
        .rd_addr_1(rd_addr_1),
        .rd_addr_2(rd_addr_2),
        .rd_data_1(rd_data_1),
        .rd_data_2(rd_data_2),
        
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units clock period
    end

    // Register Write Task
    task write_reg(input [4:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            wr_en = 1;
            wr_addr = addr;
            wr_data = data;
            @(posedge clk);
            wr_en = 0;
        end
    endtask

    // Register Read Task
    task read_reg(input [4:0] addr1, input [4:0] addr2);
        begin
            rd_addr_1 = addr1;
            rd_addr_2 = addr2;
            #1; // Small delay to allow for combinational read
        end
    endtask

     // Validation Task
    task check_read(input [31:0] expected_data_1, input [31:0] expected_data_2);
        begin
            if (rd_data_1 !== expected_data_1) begin
                $display("ERROR: Read data 1: %h, expected: %h", rd_data_1, expected_data_1);
            end else begin
                $display("PASS: Read data 1: %h", rd_data_1);
            end
            
            if (rd_data_2 !== expected_data_2) begin
                $display("ERROR: Read data 2: %h, expected: %h", rd_data_2, expected_data_2);
            end else begin
                $display("PASS: Read data 2: %h", rd_data_2);
            end
        end
    endtask

    // Initial block to apply test vectors
    initial begin
        // Initialize inputs
        wr_en = 0;
        wr_addr = 0;
        wr_data = 0;
        rd_addr_1 = 0;
        rd_addr_2 = 0;

        // Write specific values to registers 0 through 4
        write_reg(5'd0, 32'd0);
        write_reg(5'd1, 32'd1);
        write_reg(5'd2, 32'd2);
        write_reg(5'd3, 32'd3);

        // Read and check the values
        read_reg(5'd0, 5'd1);
        check_read(32'd0, 32'd1);

        read_reg(5'd2, 5'd3);
        check_read(32'd2, 32'd3);

        // End simulation
        $finish;
    end

endmodule