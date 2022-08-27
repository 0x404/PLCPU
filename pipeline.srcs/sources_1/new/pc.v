`timescale 1ns / 1ps

module pc(
    input wire clk, rst, en,
    input wire[31:0] npc,
    
    output reg [31:0] pc
    );

    always @(posedge clk) 
    begin
        if(rst)  pc <= 0; 
        else if(en)  pc <= npc; 
    end

endmodule
