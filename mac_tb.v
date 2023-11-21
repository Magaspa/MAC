module testbench;

    // Signals
    reg clk;
    reg reset;
    reg [15:0] inputA;
    reg [15:0] inputB;
    wire [39:0] z;

    // Counter to run 256 test cases
    reg [7:0] counter;

    // Instantiate MAC_unit
    mac mac_unit (
        .clk(clk),
        .reset(reset),
        .inputA(inputA),
        .inputB(inputB),
        .z(z)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Testbench behavior
    initial begin
        // Initialize signals
        clk = 0;
        reset = 0;
        inputA = 16'h0000;
        inputB = 16'h0000;

        // Apply reset and wait for a few clock cycles
        reset = 1;
        #10 reset = 0;

        // Initialize the counter
        counter = 8'h00;

        // Start the test loop
        while (counter < 8'hFF) begin
            // Generate random 16-bit inputs
            inputA = $random;
            inputB = $random;

            // Display the current test case
            $display("Test Case %b:", counter);
            $display("Input A = %b", inputA);
            $display("Input B = %b", inputB);

            // Wait for a few clock cycles
            #10;

            // Display the results
            $display("Accumulated Result = %b", z);

            // Increment the counter
            counter = counter + 1;
        end

        // Finish simulation
        $finish;
    end

endmodule