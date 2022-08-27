`timescale 1ns / 1ps


module mux2 #(parameter WIDTH = 31)(
    input wire[WIDTH - 1 : 0] arg0, arg1,
    input wire signal,
    output wire[WIDTH - 1 : 0] out
    );

    assign out = signal ? arg1 : arg0;

endmodule
