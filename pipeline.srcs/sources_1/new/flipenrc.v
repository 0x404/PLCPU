`timescale 1ns / 1ps

// flip-flop
// clock, enable, reset, clear
module flipenrc #(parameter WIDTH = 8)(
    input wire clk, rst, en, clr,
    input wire[WIDTH - 1 : 0] d,

    output reg[WIDTH - 1 : 0] q
    );

    always @(posedge clk)
    begin
        if(rst) q <= 0;
        else if(clr) q <= 0;
        else if(en) q <= d;
    end
endmodule
