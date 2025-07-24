`timescale 1ns / 1ps

module SoC_tb;

    // Testbench signals
    reg clk;
    reg reset;
    wire [7:0] led_out;

    // Instantiate the SoC
    SoC uut (
        .clk(clk),
        .reset(reset),
        .led_out(led_out)
    );

    // Clock generation: 10ns period (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus block
    initial begin
        // Monitor output
        $monitor("Time: %0t | Reset: %b | LED: %h", $time, reset, led_out);

        // Initialize
        reset = 1;
        #20;
        
        // Deassert reset
        reset = 0;

        // Run simulation for some time to observe behavior
        #500000;

        // Finish simulation
        $finish;
    end

endmodule

