`timescale 1ns / 1ps

module cu(
    input wire[5:0] opcode,

    output wire regwrite,   // whether writes regfile?                0 no       1 yes
    output wire memtoreg,   // where regwrite data from ?            0 ALU_res  1 memory   
    output wire memwrite,   // whether writes memory?                0 no       1 yes    
    output wire branch,     // pc+4 or jump?                         0 pc+4     1 imm
    output wire alusrc,     // alu arg2  from imm or rd2(regfile) ?  0 rd2      1 imm
    output wire regdst,     // regfile write addr is rt or rd ?      0 rt       1 rd
    output wire jump,       
    output wire[3:0] aluop  // ALU op type                           1111 Rinstruction  
    );

    reg[10:0] signals;
    assign {regwrite, memtoreg, memwrite, branch, alusrc, regdst, jump, aluop} = signals;

    always @(*) begin
        case(opcode)
            6'b000000 : signals <= 11'b10000101111; // R-instruction
            6'b101011 : signals <= 11'b00101000000; // SW
            6'b100011 : signals <= 11'b11001000000; // LW
            6'b001111 : signals <= 11'b10001000000; // LUI
            6'b001100 : signals <= 11'b10001000001; // ANDI
            6'b001110 : signals <= 11'b10001000010; // XORI
            6'b001101 : signals <= 11'b10001000011; // ORI
            6'b001000 : signals <= 11'b10001000000; // ADDI
            6'b001010 : signals <= 11'b10001000100; // SLTI
            6'b000010 : signals <= 11'b00010010000; // J
            6'b000100 : signals <= 11'b00011000101; // BEQ
            default : signals <= 11'b00000000000; // fault case
        endcase
    end

endmodule
