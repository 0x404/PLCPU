`timescale 1ns / 1ps

module testbench();
reg clk;
reg rst;
top top(
    .clk(clk), 
    .rst(rst)
    );

always  #20 clk = ~clk;

initial begin
    rst = 1;
    clk = 0;

    #40 rst = 0;
    #540 $stop;
end

endmodule
