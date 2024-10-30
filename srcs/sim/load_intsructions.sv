module load_intsructions();
    // Test Bench Signals
    logic clk;
    logic reset;
    logic run;
    logic load;
    
    logic [3:0]  hex_grid_left;
    logic [7:0]  hex_seg_left;
    logic [3:0]  hex_grid_right;
    logic [7:0]  hex_seg_right;

    // Instantiate the riscv_top module
    soc_top uut (
        .clk(clk),
        .reset(reset),
        .run(run),
        .load(load),
        .hex_grid_left(hex_grid_left),
        .hex_seg_left(hex_seg_left),
        .hex_grid_right(hex_grid_right),
        .hex_seg_right(hex_seg_right)
    );  

    // Clock Generation: 10ns period (50MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Initial Block for Simulation
    initial begin
        // Initial States
        reset = 0;
        run = 0;
        load = 0;
        #10
        
        // Apply Reset
        reset = 1;
        #20 reset = 0;

        // Start Loading Instructions
        load = 1;
        #20 load = 0;  // Assume it takes 100ns to load all instructions

        // Start Running the CPU
        #700 run = 1;
        #20 run = 0;

        // Finish the simulation
        $stop;
    end
endmodule
