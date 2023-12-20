module lfsr (clk, rst, out);

parameter OUT_SIZE=8;
parameter LFSR_POLY='b1101000000001000;
parameter LFSR_SEED = 'b1;

localparam LFSR_SIZE=$clog2(LFSR_POLY);

input clk;
input rst;
output [OUT_SIZE-1:0] out;

reg [LFSR_SIZE-1:0] LFSR;

assign out = LFSR[OUT_SIZE-1:0];

wire LFSR_next;

assign LFSR_next = ^(LFSR & LFSR_POLY);

always @(posedge clk or posedge rst) begin
    if (rst) begin
	    LFSR <= LFSR_SEED;
	end
	else begin
		LFSR <= {LFSR[LFSR_SIZE-2:0], LFSR_next};
	end
end
endmodule