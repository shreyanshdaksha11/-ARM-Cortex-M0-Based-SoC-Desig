module SoC (
    input clk,                // System clock
    input reset,              // System reset
    output [7:0] led_out      // LED output (8-bit)
);

    // Wires to connect Timer peripheral
    wire [7:0] timer_count;
    wire timer_interrupt;

    // Internal memory (Single-Port RAM: 255 x 8-bit)
    reg [7:0] memory [0:254];

    // LED output register
    reg [7:0] led_reg;
    assign led_out = led_reg;

    // Timer Instance
    Timer timer_inst (
        .clk(clk),
        .reset(reset),
        .count(timer_count),
        .interrupt(timer_interrupt)
    );

    // State machine for interrupt response
    reg [1:0] state;
    reg [15:0] delay_counter; // simple delay counter

    localparam IDLE     = 2'b00,
               ON_STATE = 2'b01,
               DELAY    = 2'b10,
               OFF_STATE= 2'b11;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            led_reg <= 8'h00;
            memory[0] <= 8'h00;
            state <= IDLE;
            delay_counter <= 16'd0;
        end else begin
            case (state)
                IDLE: begin
                    if (timer_interrupt) begin
                        led_reg <= 8'hFF;       // Turn on LEDs
                        memory[0] <= 8'h55;     // Write 0x55 to memory[0]
                        delay_counter <= 16'd50000; // Some delay cycles
                        state <= DELAY;
                    end
                end

                DELAY: begin
                    if (delay_counter > 0)
                        delay_counter <= delay_counter - 1;
                    else
                        state <= OFF_STATE;
                end

                OFF_STATE: begin
                    led_reg <= 8'h00;         // Turn off LEDs
                    memory[0] <= 8'h00;       // Clear memory[0]
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule

module Timer (
    input clk,                 // Clock input
    input reset,               // Reset input
    output reg [7:0] count,    // 8-bit count value (from 0F to 00)
    output reg interrupt       // Interrupt signal when count hits 00
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 8'h0F;        // Initialize counter to 0F on reset
            interrupt <= 1'b0;
        end else begin
            if (count == 8'h00) begin
                interrupt <= 1'b1; // Raise interrupt when count reaches 00
            end else begin
                count <= count - 1'b1;  // Decrement count
                interrupt <= 1'b0;      // Clear interrupt if not at 00
            end
        end
    end
endmodule







