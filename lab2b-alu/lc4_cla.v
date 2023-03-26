`timescale 1ns / 1ps
`default_nettype none

/**
 * @param a first 1-bit input
 * @param b second 1-bit input
 * @param g whether a and b generate a carry
 * @param p whether a and b would propagate an incoming carry
 */
module gp1(input wire a, b,
           output wire g, p);
   assign g = a & b;
   assign p = a | b;
endmodule

/**
 * Computes aggregate generate/propagate signals over a 4-bit window.
 * @param gin incoming generate signals 
 * @param pin incoming propagate signals
 * @param cin the incoming carry
 * @param gout whether these 4 bits collectively generate a carry (ignoring cin)
 * @param pout whether these 4 bits collectively would propagate an incoming carry (ignoring cin)
 * @param cout the carry outs for the low-order 3 bits
 */
module gp4(input wire [3:0] gin, pin,
           input wire cin,
           output wire gout, pout,
           output wire [2:0] cout);

           assign cout[0] = gin[0] | (cin & pin[0]);
           assign cout[1] = gin[1] | (pin[1] & cout[0]);
           assign cout[2] = (pin[2] & cout[1]) | gin[2];

           assign gout = (gin[0] & (& pin[3:1])) | (gin[1] & (& pin[3:2])) | (gin[2] & pin[3]) | gin[3];
           assign pout = (& pin);
endmodule

/**
 * 16-bit Carry-Lookahead Adder
 * @param a first input
 * @param b second input
 * @param cin carry in
 * @param sum sum of a + b + carry-in
 */
module cla16
  (input wire [15:0]  a, b,
   input wire         cin,
   output wire [15:0] sum);

   wire [15:0] gin;
   wire [15:0] pin;
   wire [4:0] gout;
   wire [4:0] pout;
   wire [15:0] cout;

   genvar i;
   for (i = 0; i < 16; i = i + 1) begin
      gp1 g_indiv(.a(a[i]), .b(b[i]), .g(gin[i]), .p(pin[i]));
   end

   assign cout[0] = cin;
   gp4 g_first_level_1(.gin(gin[3:0]), .pin(pin[3:0]), .cin(cin), .gout(gout[0]), .pout(pout[0]), .cout(cout[3:1]));
   assign cout[4] = (pout[0] & cin) | gout[0];
   gp4 g_first_level_2(.gin(gin[7:4]), .pin(pin[7:4]), .cin(cout[4]), .gout(gout[1]), .pout(pout[1]), .cout(cout[7:5]));
   assign cout[8] = (pout[1] & cout[4]) | gout[1];
   gp4 g_first_level_3(.gin(gin[11:8]), .pin(pin[11:8]), .cin(cout[8]), .gout(gout[2]), .pout(pout[2]), .cout(cout[11:9]));
   assign cout[12] = (pout[2] & cout[8]) | gout[2];
   gp4 g_first_level_4(.gin(gin[15:12]), .pin(pin[15:12]), .cin(cout[12]), .gout(gout[3]), .pout(pout[3]), .cout(cout[15:13]));

   assign sum = a ^ b ^ cout;

endmodule


/** Lab 2 Extra Credit, see details at
  https://github.com/upenn-acg/cis501/blob/master/lab2-alu/lab2-cla.md#extra-credit
 If you are not doing the extra credit, you should leave this module empty.
 */
module gpn
  #(parameter N = 4)
  (input wire [N-1:0] gin, pin,
   input wire  cin,
   output wire gout, pout,
   output wire [N-2:0] cout);
 
endmodule
