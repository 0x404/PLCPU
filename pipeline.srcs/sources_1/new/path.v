`timescale 1ns / 1ps


module path(
    input wire clk, rst,

    // fetch
    input wire[31:0] instrF,
    
    output wire[31:0] pcF,
    
    // decode
    input wire pcsrcD,
    input wire branchD,
    input wire jumpD,
    
    output wire equalD,
    output wire[5:0] funcD,
    output wire[5:0] opD,

    // execute
    input wire memtoregE,
    input wire alusrcE, 
    input wire regdstE,
    input wire regwriteE,
    input wire[3:0] alusignalsE,

    output wire flushE,

    // memory
    input wire memtoregM,
    input wire regwriteM,
    input wire[31:0] readdataM,

    output wire[31:0] aluresM,
    output wire[31:0] writedataM,

    // writeback 
    input wire memtoregW,
    input wire regwriteW
    );

    // pc generat ------------
    wire[31:0] pctemp, npc, pcplus4F, pcbranchD;
    wire[31:0] pcplus4D, instrD;

    mux2 #(32) whether_beq(
        .arg0(pcplus4F),    // pc+4
        .arg1(pcbranchD),   // pc+imm16
        .signal(pcsrcD),
        .out(pctemp)
    );

    mux2 #(32) whether_jump(
        .arg0(pctemp),
        .arg1({pcplus4D[31:28], instrD[25:0], 2'b00}), // imm26
        .signal(jumpD),
        .out(npc)        
    );

    // fetch ----------------
    wire stallF;

    pc pc0(
        .clk(clk),
        .rst(rst),
        .en(~stallF),
        .npc(npc),

        .pc(pcF)
    );
    
    adder plus4(
        .arg0(pcF),
        .arg1(32'b100),

        .sum(pcplus4F)
    );


    // decode ---------------

    wire[31:0] signimmD, signimmshD;

    wire[4:0] rsD, rtD, rdD; // used in execute stage for data forwarding
    wire forwardaD, forwardbD;
    wire flushD, stallD;
    
    wire[31:0] rd1D, rd2D, rd1Da, rd2Db;
    wire[4:0] regWriteAddrW, regWriteDataW;

    regfile registers(
        .clk(clk),
        .we(regwriteW),
        .regaddr1(rsD),
        .regaddr2(rtD),
        .writeaddr(regWriteAddrW),
        .writedata(regWriteDataW),
        .rd1(rd1D),     // read data1
        .rd2(rd2D)      // read data2
    );

    flipenrc #(32) f2d_pc(
        .clk(clk),
        .rst(rst),
        .en(~stallD),
        .clr(1'b0),
        .d(pcplus4F),
        .q(pcplus4D)
    );

    flipenrc #(32) f2d_instr(
        .clk(clk),
        .rst(rst),
        .en(~stallD),
        .clr(flushD),
        .d(instrF),
        .q(instrD)        
    );

    signextend se(
        .imm16(instrD[15:0]),
        .imm32(signimmD)
    );

    assign signimmshD = {signimmD[29:0], 2'b00};     // shift left 2 bit


    adder getBEQpc(
        .arg0(pcplus4D),
        .arg1(signimmshD),
        .sum(pcbranchD)
    );

    mux2 #(32) forward1(
        .arg0(rd1D),
        .arg1(aluresM),
        .signal(forwardaD),
        .out(rd1Da)
    );
    mux2 #(32) forward2(
        .arg0(rd2D),
        .arg1(aluresM),
        .signal(forwardbD),
        .out(rd2Db)        
    );

    assign equalD = (rd1Da == rd2Db) ? 1 : 0;

    assign opD = instrD[31:26];
    assign func = instrD[5:0];
    assign rsD = instrD[25:21];
    assign rtD = instrD[20:16];
    assign rdD = instrD[15:11];


    // execute
    wire[31:0] signimmE;
    wire[4:0] rsE, rdE, rtE;
    wire forwardaE, forwardbE;
    wire[31:0] aluresE, aluArg1, aluArg2;
    wire[4:0] writeregE, writeregM;


    flipenrc #(32) r1Exe(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .clr(flushE),
        .d(rd1D),
        .q(rd1E)
    );

    flipenrc #(32) r2Exe(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .clr(flushE),
        .d(rd2D),
        .q(rd2E)
    );

    flipenrc #(32) immE(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .clr(flushE),
        .d(signimmD),
        .q(signimmE)
    );

    flipenrc #(5) rsExe(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .clr(flushE),
        .d(rsD),
        .q(rsE)
    );

    flipenrc #(5) rtExe(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .clr(flushE),
        .d(rtD),
        .q(rtE)
    );

    flipenrc #(5) rdExe(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .clr(flushE),
        .d(rdD),
        .q(rdE)
    );        

    mux3 #(32) forwardrd1(
        .arg0(rd1E),
        .arg1(regWriteDataW),
        .arg2(aluresM),
        .signal(forwardaE),
        .out(aluArg1)
    );

    mux3 #(32) forwardrd2(
        .arg0(rd2E),
        .arg1(regWriteDataW),
        .arg2(aluresM),
        .signal(forwardbE),
        .out(rd2EE)
    );

    mux2 #(32) getAluArg2(
        .arg0(rd2EE),
        .arg1(signimmE),
        .signal(alusrcE),
        .out(aluArg2)          
    );

    alu alu(
    .arg0(aluArg1),
    .arg1(aluArg2),
    .alusignals(alusignalsE),
    .res(aluresE),
    .overflow(),
    .zero()        
    );

    mux2 #(5) writeReg(
        .arg0(rtE),
        .arg1(rdE),
        .signal(regdstE),
        .out(writeregE)
    );

    // memory
    flipenrc #(32) rd2E2M(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .clr(1'b0),
        .d(rd2EE),      
        .q(writedataM)  // memory write data
    );

    flipenrc #(32) aluresE2M(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .clr(1'b0),
        .d(aluresE),
        .q(aluresM)        
    );

    flipenrc #(5) writeRegE2M(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .clr(1'b0),
        .d(writeregE),
        .q(writeregM)        
    );


    // write back
    wire[31:0] aluresW, readdataW;

    flipenrc #(32) aluresM2W(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .clr(1'b0),
        .d(aluresM),
        .q(aluresW)        
    );

    flipenrc #(32) readDatafilp(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .clr(1'b0),
        .d(readdataM),
        .q(readdataW)        
    );

    flipenrc #(5) writeregM2W(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .clr(1'b0),
        .d(writeregM),
        .q(regWriteAddrW)
    );    

    mux2 #(32) regWriteDataM2W(
        .arg0(aluresW),
        .arg1(readdataW),
        .signal(memtoregW),
        .out(regWriteDataW)
    ); 


    // hazard
    hazard hz(
    
    // fetch
    .stallF(stallF),

    // decode
    .rsD(rsD),
    .rtD(rtD),
    .branchD(branchD),

    .forwardaD(forwardaD), 
    .forwardbD(forwardbD),
    .stallD(stallD),

    // execute
    .rsE(rsE), 
    .rtE(rtE ),
    .writeregE(writeregE),
    .regwriteE(regwriteE),
    .memtoregE(memtoregE),

    .forwardaE(forwardaE), 
    .forwardbE(forwardbE),
    .flushE(flushE),

    // memory
    .writeregM(writeregM),
    .regwriteM(regwriteM),
    .memtoregM(memtoregM),

    // writeback
    .writeregW(regWriteAddrW),
    .regwriteW(regwriteW)
    );

endmodule
