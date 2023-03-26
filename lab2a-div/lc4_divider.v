`timescale 1ns / 1ps
`default_nettype none

module lc4_divider(input  wire [15:0] i_dividend,
                   input  wire [15:0] i_divisor,
                   output wire [15:0] o_remainder,
                   output wire [15:0] o_quotient);

wire [15:0] next_remainder_arr[15:0];
wire [15:0] next_quotient_arr[15:0];
wire [15:0] next_dividend_arr[15:0];

lc4_divider_one_iter d1(.i_dividend(i_dividend), .i_divisor(i_divisor), .i_remainder(16'b0), .i_quotient(16'b0), .o_dividend(next_dividend_arr[0]), .o_remainder(next_remainder_arr[0]), .o_quotient(next_quotient_arr[0]));

genvar i;
for (i = 1; i < 16; i = i + 1) begin
  lc4_divider_one_iter iter(.i_dividend(next_dividend_arr[i-1]), .i_divisor(i_divisor), .i_remainder(next_remainder_arr[i-1]), .i_quotient(next_quotient_arr[i-1]), .o_dividend(next_dividend_arr[i]), .o_remainder(next_remainder_arr[i]), .o_quotient(next_quotient_arr[i]));
end

assign o_quotient = i_divisor == 0 ? 16'b0 : next_quotient_arr[15];
assign o_remainder = i_divisor == 0 ? 16'b0 : next_remainder_arr[15];

endmodule // lc4_divider

module lc4_divider_one_iter(input  wire [15:0] i_dividend,
                            input  wire [15:0] i_divisor,
                            input  wire [15:0] i_remainder,
                            input  wire [15:0] i_quotient,
                            output wire [15:0] o_dividend,
                            output wire [15:0] o_remainder,
                            output wire [15:0] o_quotient);

wire [15:0] i_remainder_shifted;

assign i_remainder_shifted = (i_remainder << 1) | ((i_dividend >> 15) & 1);
assign o_quotient = i_remainder_shifted < i_divisor ?  (i_quotient << 1) : ((i_quotient << 1) | 1);
assign o_remainder = i_remainder_shifted < i_divisor ? i_remainder_shifted : (i_remainder_shifted - i_divisor);
assign o_dividend = i_dividend << 1;

endmodule
