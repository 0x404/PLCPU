`timescale 1ns / 1ps

module top(
    input wire clk, 
    input wire rst
    );

    wire[31:0] pc, instrF;
    wire[31:0] writeData, readData, memAddr;
    wire memWriteSignal;

    cpu cpu(
        .clk(clk),
        .rst(rst),
        .instrF(instrF),                // read from instru_ram
        .readdataM(readData),           // read from data_ram

        .pcF(pc),                       // pc
        .memwriteM(memWriteSignal),     // whehre write data_ram
        .aluresM(memAddr),              // data_ram write addr
        .writedataM(writeData)          // data write to data_ram
    );

    inst_rom inst_rom_4k(
        .a(pc[11:2]),                    // input wire [9 : 0] a
        .spo(instrF)                      // output wire [31 : 0] spo
    );

    data_ram data_ram_4k(
        .a(memAddr[11:2]),                // input wire [9 : 0] a
        .d(writeData),                    // input wire [31 : 0] d
        .clk(clk),                        // input wire clk
        .we(memWriteSignal),              // input wire we
        .spo(readData)                    // output wire [31 : 0] spo
    );

endmodule
