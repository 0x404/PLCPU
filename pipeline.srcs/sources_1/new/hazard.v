`timescale 1ns / 1ps

module hazard(
    // fetch
    output wire stallF,

    // decode
    input wire[4:0] rsD, rtD,
    input wire branchD,

    output wire forwardaD, forwardbD,
    output wire stallD,

    // execute
    input wire[4:0] rsE, rtE,
    input wire[4:0] writeregE,
    input wire regwriteE,
    input wire memtoregE,

    output reg[1:0] forwardaE, forwardbE,
    output wire flushE,

    // memory
    input wire[4:0] writeregM,
    input wire regwriteM,
    input wire memtoregM,

    // writeback
    input wire[4:0] writeregW,
    input wire regwriteW
    );

    always @(*) 
    begin
        forwardaE = 2'b00;
        forwardbE = 2'b00;
        if(rsE != 0) 
        begin
            if(rsE == writeregM & regwriteM) begin
                forwardaE = 2'b10;
            end

            else if(rsE == writeregW & regwriteW) begin
                forwardaE = 2'b01;
            end
        end
		if(rtE != 0) begin
			if(rtE == writeregM & regwriteM) begin
				forwardbE = 2'b10;
			end else if(rtE == writeregW & regwriteW) begin
				forwardbE = 2'b01;
			end
		end
    end

    // data forward for branch
    assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
    assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);


    wire lwstallD, branchstallD;

	assign  lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	assign  branchstallD = branchD &
				(regwriteE & 
				(writeregE == rsD | writeregE == rtD) |
				 memtoregM &
				(writeregM == rsD | writeregM == rtD));
	assign  stallD = lwstallD | branchstallD;
	assign  stallF = stallD;

	assign  flushE = stallD;   

endmodule
