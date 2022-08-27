`timescale 1ns / 1ps

module mux3 #(parameter WIDTH = 32)(
    input wire[WIDTH - 1 : 0] arg0, arg1, arg2,
    input wire signal,
    
    output wire[WIDTH - 1 : 0] out
    );

    assign out = (signal == 2'b00) ? arg0 :
                 (signal == 2'b01) ? arg1 :
                 (signal == 2'b10) ? arg2 : arg0;
endmodule
