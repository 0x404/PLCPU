`timescale 1ns / 1ps


module adder(
    input wire[31:0] arg0,
    input wire[31:0] arg1,

    output wire[31:0] sum
    );

    assign sum = arg0 + arg1;

endmodule
