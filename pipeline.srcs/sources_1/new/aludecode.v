`timescale 1ns / 1ps


module aludecode(
    input wire[5:0] func,
    input wire[3:0] aluop,

    output reg[3:0] alusignals
    );

    always @(*) begin
        case(aluop)
            4'b0000 : alusignals <= 4'b0010; // add(lw,sw,addi,lui)
            4'b0101 : alusignals <= 4'b0110; // sub
            4'b0001 : alusignals <= 4'b0000; // and
            4'b0011 : alusignals <= 4'b0001; // or
            default : case(func)
                6'b100000 : alusignals <= 4'b0010; // add
                6'b100010 : alusignals <= 4'b0110; // sub
				6'b100100 : alusignals <= 4'b0000; // and
				6'b100101 : alusignals <= 4'b0001; // or
				6'b101010 : alusignals <= 4'b0111; // slt
				default:  alusignals <= 4'b0000;
            endcase
        endcase
    end

endmodule
