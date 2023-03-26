/* TODO: Names of all group members
 * TODO: PennKeys of all group members
 *
 * lc4_regfile.v
 * Implements an 8-register register file parameterized on word size.
 *
 */

`timescale 1ns / 1ps

// Prevent implicit wire declaration
`default_nettype none

module lc4_regfile #(parameter n = 16)
   (input  wire         clk,
    input  wire         gwe,
    input  wire         rst,
    input  wire [  2:0] i_rs,      // rs selector
    output wire [n-1:0] o_rs_data, // rs contents
    input  wire [  2:0] i_rt,      // rt selector
    output wire [n-1:0] o_rt_data, // rt contents
    input  wire [  2:0] i_rd,      // rd selector
    input  wire [n-1:0] i_wdata,   // data to write
    input  wire         i_rd_we    // write enable
    );

   /***********************
    * TODO YOUR CODE HERE *
    ***********************/

wire i_r0_we;
wire i_r1_we;
wire i_r2_we;
wire i_r3_we;
wire i_r4_we;
wire i_r5_we;
wire i_r6_we;
wire i_r7_we;

wire [15:0] o_r0;
wire [15:0] o_r1;
wire [15:0] o_r2;
wire [15:0] o_r3;
wire [15:0] o_r4;
wire [15:0] o_r5;
wire [15:0] o_r6;
wire [15:0] o_r7;

//Nbit_reg #(n) r0();

wire [7:0] decoder_out;

one_to_eight_decoder d(.i_r(i_rd), .onehot_out(decoder_out));

assign i_r0_we = i_rd_we & (decoder_out[0]);
assign i_r1_we = i_rd_we & (decoder_out[1]);
assign i_r2_we = i_rd_we & (decoder_out[2]);
assign i_r3_we = i_rd_we & (decoder_out[3]);
assign i_r4_we = i_rd_we & (decoder_out[4]);
assign i_r5_we = i_rd_we & (decoder_out[5]);
assign i_r6_we = i_rd_we & (decoder_out[6]);
assign i_r7_we = i_rd_we & (decoder_out[7]);


Nbit_reg #(n) r0(.in(i_wdata), .out(o_r0), .clk(clk), .we(i_r0_we), .gwe(gwe), .rst(rst));
Nbit_reg #(n) r1(.in(i_wdata), .out(o_r1), .clk(clk), .we(i_r1_we), .gwe(gwe), .rst(rst));
Nbit_reg #(n) r2(.in(i_wdata), .out(o_r2), .clk(clk), .we(i_r2_we), .gwe(gwe), .rst(rst));
Nbit_reg #(n) r3(.in(i_wdata), .out(o_r3), .clk(clk), .we(i_r3_we), .gwe(gwe), .rst(rst));
Nbit_reg #(n) r4(.in(i_wdata), .out(o_r4), .clk(clk), .we(i_r4_we), .gwe(gwe), .rst(rst));
Nbit_reg #(n) r5(.in(i_wdata), .out(o_r5), .clk(clk), .we(i_r5_we), .gwe(gwe), .rst(rst));
Nbit_reg #(n) r6(.in(i_wdata), .out(o_r6), .clk(clk), .we(i_r6_we), .gwe(gwe), .rst(rst));
Nbit_reg #(n) r7(.in(i_wdata), .out(o_r7), .clk(clk), .we(i_r7_we), .gwe(gwe), .rst(rst));

assign o_rs_data = i_rs == 0 ? o_r0 : (i_rs == 1 ? o_r1 : (i_rs == 2 ? o_r2 : (i_rs == 3 ? o_r3 : (i_rs == 4 ? o_r4 : (i_rs == 5 ? o_r5 : (i_rs == 6 ? o_r6 : o_r7))))));

assign o_rt_data = i_rt == 0 ? o_r0 : (i_rt == 1 ? o_r1 : (i_rt == 2 ? o_r2 : (i_rt == 3 ? o_r3 : (i_rt == 4 ? o_r4 : (i_rt == 5 ? o_r5 : (i_rt == 6 ? o_r6 : o_r7))))));

endmodule

module one_to_eight_decoder 
	(input wire [2:0] i_r,
	 output wire [7:0] onehot_out);

assign onehot_out[0] = (i_r == 3'd0);
assign onehot_out[1] = (i_r == 3'd1);
assign onehot_out[2] = (i_r == 3'd2);
assign onehot_out[3] = (i_r == 3'd3);
assign onehot_out[4] = (i_r == 3'd4);
assign onehot_out[5] = (i_r == 3'd5);
assign onehot_out[6] = (i_r == 3'd6);
assign onehot_out[7] = (i_r == 3'd7);

endmodule
