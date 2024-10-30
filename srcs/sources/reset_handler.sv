module reset_handler(
    input logic clk,
    input logic reset,
    input logic run,
    input logic load_done,
    
    output logic cpu_reset
    );
    
    logic run_prev;
    logic run_rising_edge;
    
    // Detect rising edge of the run signal
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            run_prev <= 1'b0;        // Reset the previous run state
            run_rising_edge <= 1'b0; // Reset the rising edge detector
        end else begin
            run_rising_edge <= run && !run_prev; // Detect rising edge of run
            run_prev <= run;  // Update previous run state
        end
    end
    
    // Control the CPU reset based on the load_done, run, and reset signals
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            cpu_reset <= 1'b1; // Set cpu_reset on reset
        end else begin
            if (load_done && run_rising_edge) begin
                cpu_reset <= 1'b0; // Clear cpu_reset on rising edge of run after loading is done
            end else if (!reset) begin // Add condition to prevent overriding reset
                cpu_reset <= cpu_reset; // Keep cpu_reset unchanged
            end
        end
    end
endmodule
