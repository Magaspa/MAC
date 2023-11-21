`timescale 1ns/100ps

//VERILOG CODE FOR MAC UNIT:
module mac (
    input wire clk,           // Clock signal
    input wire reset,         // Reset signal
    input wire [15:0] inputA, // 16-bit input A
    input wire [15:0] inputB, // 16-bit input B
    output wire [39:0] z     // Accumulated result output
    
);

    wire [31:0] multiply_result;  // Result from the multiplier
    wire [39:0] add_result;      // Result from the adder

    // Registers to store accumulated result and carry-in for next stage
    reg [39:0] accumulator = 40'h00000000;

    // Instantiate the booth multiplier
    boothmul multiplier (
        .X(inputA),
        .Y(inputB),
        .Z(multiply_result)
    );

    // Instantiate the 40-bit carry-lookahead adder
    bit40cla adder (
        .A(accumulator),
        .B(multiply_result),
        .Cin(1'b0),   // Connect carry-in to the register's output
        .SumAndCarry(add_result)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset accumulator and trunc when the reset signal is asserted
            accumulator <= 40'h00000000;
        end else begin
            // Accumulate the result by adding it to the accumulator
            accumulator <= add_result;
            

        end
    end

    // Connect the output to z
    assign z = accumulator;
endmodule
// Project Name: Carry Look Ahead Adder
///////////////////////////////////////////////////////////////////////////
module bit40cla (
    input [39:0] A,
    input [39:0] B,
    input Cin,
    output [40:0] SumAndCarry
);

    wire [3:0] A_part[9:0], B_part[9:0];
    wire [3:0] S_part[9:0];
    wire Cout_partial[9:0];

    // Instantiate 4-bit CLA adders for each 4-bit chunk (total of 10)
    genvar i;
    generate
        for (i = 0; i < 10; i = i + 1) begin
            bit4cla u_adder (
                .a(A[4*i +: 4]),
                .b(B[4*i +: 4]),
                .cin(i == 0 ? Cin : Cout_partial[i - 1]),
                .sum(S_part[i]),
                .cout(Cout_partial[i])
            );
        end
    endgenerate

    // Concatenate the 4-bit results to obtain the final 40-bit sum
    assign SumAndCarry = {Cout_partial[9], S_part[9], S_part[8], S_part[7], S_part[6], S_part[5], S_part[4], S_part[3], S_part[2], S_part[1], S_part[0]};

endmodule

module bit4cla(a, b, cin, sum, cout);
    input [3:0] a, b;
    input cin;
    output [3:0] sum;
    output cout;

    // 4-bit CLA logic (similar to the 32-bit CLA adder, just for 4 bits)
    wire p0, p1, p2, p3, g0, g1, g2, g3, c1, c2, c3, c4;

    assign p0 = (a[0] ^ b[0]);
    assign p1 = (a[1] ^ b[1]);
    assign p2 = (a[2] ^ b[2]);
    assign p3 = (a[3] ^ b[3]);

    assign g0 = (a[0] & b[0]);
    assign g1 = (a[1] & b[1]);
    assign g2 = (a[2] & b[2]);
    assign g3 = (a[3] & b[3]);

    assign c0 = cin;
    assign c1 = g0 | (p0 & cin);
    assign c2 = g1 | (p1 & g0) | (p1 & p0 & cin);
    assign c3 = g2 | (p2 & g1) | (p2 & p1 & g0) | (p1 & p1 & p0 & cin);
    assign c4 = g3 | (p3 & g2) | (p3 & p2 & g1) | (p3 & p2 & p1 & g0) | (p3 & p2 & p1 & p0 & cin);

    assign sum[0] = p0 ^ c0;
    assign sum[1] = p1 ^ c1;
    assign sum[2] = p2 ^ c2;
    assign sum[3] = p3 ^ c3;

    assign cout = c4;

endmodule

module boothmul(X, Y, Z);
input signed [15:0] X, Y;
output signed [31:0] Z;
reg signed [31:0] Z;
reg [1:0] temp;
integer i;
reg E1;
reg [15:0] Y1;
always @ (X, Y)
begin
Z = 32'd0;
E1 = 1'd0;
Y1 = - Y;
Z[15:0]=X;
for (i = 0; i < 16; i = i + 1)
begin
temp = {X[i], E1};
case (temp)
2'd2 : Z [31 : 16] = Z [31 : 16] + Y1;
2'd1 : Z [31 : 16] = Z [31 : 16] + Y;
default : begin end
endcase
Z = Z >> 1;
Z[31] = Z[30];
E1 = X[i];
end

end
endmodule