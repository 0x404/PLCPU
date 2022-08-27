`timescale 1ns / 1ps


module cpu(
    input wire clk,
    input wire rst,
    input wire[31:0] instrF,        // read from instru_ram
    input wire[31:0] readdataM,     // read from data_ram

    output wire[31:0] pcF,                // pc
    output wire memwriteM,          // whehre write data_ram
    output wire[31:0] aluresM,      // data_ram write addr
    output wire[31:0] writedataM    // data write to data_ram
    );

    // decode
    wire[5:0] opD, funcD;

    wire pcsrcD, branchD, equalD, jumpD;

    // execute
    wire flushE, memtoregE, regwriteE, alusrcE, regdstE;
    wire[3:0] alusignalsE;

    // memory
    wire memtoregM, regwriteM;

    // write back
    wire memtoregW, regwriteW;


    controller ctrl(
        .clk(clk),
        .rst(rst),

        // decode 
        .opD(opD),
        .funcD(funcD),
        .equalD(equalD),
        
        .pcsrcD(pcsrcD),
        .branchD(branchD),
        .jumpD(jumpD),

        // execute
        .flushE(flushE),

        .memtoregE(memtoregE),
        .regwriteE(regwriteE),
        .alusrcE(alusrcE),
        .regdstE(regdstE),
        .alusignalsE(alusignalsE),

        // memory
        .memtoregM(memtoregM),
        .memwriteM(memwriteM),
        .regwriteM(regwriteM),

        // write back
        .memtoregW(memtoregW), 
        .regwriteW(regwriteW)
    );

    path path(
    .clk(clk), 
    .rst(rst),

    // fetch
    .instrF(instrF),
    
    .pcF(pcF),
    
    // decode
    .pcsrcD(pcsrcD),
    .branchD(branchD),
    .jumpD(jumpD),

    .equalD(equalD),
    .funcD(funcD),
    .opD(opD),

    // execute
    .memtoregE(memtoregE),
    .alusrcE(alusrcE), 
    .regdstE(regdstE),
    .regwriteE(regwriteE),
    .alusignalsE(alusignalsE),

    .flushE(flushE),

    // memory
    .memtoregM(memtoregM),
    .regwriteM(regwriteM),
    .readdataM(readdataM),

    .aluresM(aluresM),
    .writedataM(writedataM),

    // writeback 
    .memtoregW(memtoregW),
    .regwriteW(regwriteW)
    );  

endmodule