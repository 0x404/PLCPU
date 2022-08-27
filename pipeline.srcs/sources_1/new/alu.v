`timescale 1ns / 1ps

module alu(
    input wire[31:0] arg0,
    input wire[31:0] arg1,
    input wire[3:0] alusignals,

    output reg[31:0] res,
    output reg overflow,
    output wire zero
    );


    wire[31:0] sum, reverse;
    
    assign reverse = alusignals[2] ? ~arg1 : arg1;
    assign sum = arg0 + reverse + alusignals[2];

    always @(*) begin
        case(alusignals[1:0])
            2'b00 : res <= arg0 & reverse;
            2'b01 : res <= arg0 | reverse;
            2'b10 : res <= sum;
            2'b11 : res <= sum[31];
        endcase
    end 

    always @(*) begin
        case(alusignals[2:1])
            2'b01 : overflow <= arg0[31] & arg1[31] & ~sum[31] | ~arg0[31] & ~arg1[31] & ~sum[31];
            2'b11 : overflow <= ~arg0[31] & arg1[31] & sum[31] | arg0[31] & ~arg1[31] & ~sum[31];
            default : overflow <= 1'b0;
        endcase
    end

endmodule
