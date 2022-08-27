`timescale 1ns / 1ps


module regfile(
    input wire clk,
    input wire we, // write enable
    input wire[4:0] regaddr1, regaddr2, writeaddr,
    input wire[31:0] writedata,

    output wire[31:0] rd1, rd2 // read data
    );

    reg[31:0] registers[31:0];

    always @(negedge clk) 
    begin
        if(we) registers[writeaddr] <= writedata;
    end

    assign rd1 = (regaddr1 == 0) ? 0 : registers[regaddr1];
    assign rd2 = (regaddr2 == 0) ? 0 : registers[regaddr2];

endmodule
