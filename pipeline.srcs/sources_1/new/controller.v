`timescale 1ns / 1ps


// signals transmit at each stages through flip-flops
module controller(
    input wire clk,
    input wire rst,

    // decode 
    input wire[5:0] opD,
    input wire[5:0] funcD,
    input wire equalD,

    output wire pcsrcD,
    output wire branchD,
    output wire jumpD,

    // execute
    input wire flushE,

    output wire memtoregE,
    output wire regwriteE,
    output wire alusrcE,
    output wire regdstE,
    output wire[3:0] alusignalsE,

    // memory
    output wire memtoregM,
    output wire memwriteM,
    output wire regwriteM,

    // write back
    output wire memtoregW, 
    output wire regwriteW
    );


    // decode 
    wire[3:0] aluopD;
    wire[3:0] alusignalsD;
    wire regwriteD, memtoregD, memwriteD, alusrcD, regdstD;
    

    cu cu(
        .opcode(opD),

        .regwrite(regwriteD),
        .memtoreg(memtoregD),
        .memwrite(memwriteD),
        .branch(branchD),
        .alusrc(alusrcD),
        .regdst(regdstD),
        .jump(jumpD),
        .aluop(aluopD)
    );

    aludecode aludec(
        .func(funcD),
        .aluop(aluopD),

        .alusignals(alusignalsD)
    );

    assign pcsrcD = branchD & equalD;

 
    // posedge changes all below

    wire memwriteE;

    // decode to execute
    flipenrc #(8) d2e(
        .clk(clk),
        .rst(rst),
        .clr(flushE),
        .en(1'b1),
        .d( {memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alusignalsD} ),
        .q( {memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alusignalsE} )
    );

    
    // execute to memory
    flipenrc #(8) e2m(
        .clk(clk),
        .rst(rst),
        .clr(1'b0),
        .en(1'b1),
        .d( {memtoregE,memwriteE,regwriteE} ),
        .q( {memtoregM,memwriteM,regwriteM} )
    );

    // memory to write back
    flipenrc #(8) m2wb(
        .clk(clk),
        .rst(rst),
        .clr(1'b0),
        .en(1'b1),
        .d( {memtoregM,regwriteM} ),
        .q( {memtoregW,regwriteW} )
    );

endmodule
