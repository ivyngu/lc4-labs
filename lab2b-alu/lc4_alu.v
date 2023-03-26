`timescale 1ns / 1ps
`default_nettype none

module lc4_alu(input  wire [15:0] i_insn,
               input wire [15:0]  i_pc,
               input wire [15:0]  i_r1data,
               input wire [15:0]  i_r2data,
               output wire [15:0] o_result);

wire [15:0] o_full_arith;
wire [15:0] o_shifter;
wire [15:0] o_const;
wire [15:0] o_hiconst;
wire [15:0] o_logical;
wire [15:0] o_trap;
wire [15:0] o_rti;
wire [15:0] o_jsr;
wire [15:0] o_cmp;
wire [15:0] o_jmpr;

full_arith f_arith(.i_insn(i_insn), .i_pc(i_pc), .i_r1data(i_r1data), .i_r2data(i_r2data), .o_result(o_full_arith));
shifter shft(.i_insn(i_insn), .i_r1data(i_r1data), .o_result(o_shifter));
const cnst(.i_insn(i_insn), .o_result(o_const));
hiconst hicnst(.i_insn(i_insn), .i_r1data(i_r1data), .o_result(o_hiconst));
logical lgc(.i_insn(i_insn), .i_r1data(i_r1data), .i_r2data(i_r2data), .o_result(o_logical));
trap trp(.i_insn(i_insn), .o_result(o_trap));
rti rt(.i_r1data(i_r1data), .o_result(o_rti));
jump_subroutine jsr(.i_insn(i_insn), .i_pc(i_pc), .i_r1data(i_r1data), .o_result(o_jsr));
compare cmp(.i_insn(i_insn), .i_r1data(i_r1data), .i_r2data(i_r2data), .o_result(o_cmp));
jmpr jmpr_1(.i_r1data(i_r1data), .o_result(o_jmpr));


assign o_result = i_insn[15:12] == 4 ? o_jsr : (i_insn[15:12] == 12 && i_insn[11] == 1) ? o_full_arith : (i_insn[15:12] == 12 && i_insn[11] == 0) ? o_jmpr : (i_insn[15:12] == 8 ? o_rti : (i_insn[15:12] == 15 ? o_trap : (i_insn[15:12] == 5 ? o_logical : (i_insn[15:12] == 13 ? o_hiconst : (i_insn[15:12] == 9 ? o_const : (i_insn[15:12] == 10 && i_insn[5:4] == 3) ? o_full_arith : (i_insn[15:12] == 10 ? o_shifter : (i_insn[15:12] == 2 ? o_cmp : o_full_arith)))))));


endmodule

module jmpr(input wire [15:0] i_r1data,
		output wire [15:0] o_result);

assign o_result = i_r1data;

endmodule



module compare(input wire  [15:0] i_insn,
		input wire [15:0] i_r1data,
		input wire [15:0] i_r2data,
		output wire [15:0] o_result);

wire [15:0] reg_signed;
wire [15:0] reg_unsigned;
wire [15:0] imm_signed;
wire [15:0] imm_unsigned;
wire [15:0] imm_7;

assign imm_7 = {{9{i_insn[6]}}, i_insn[6:0]};

assign imm_signed = ($signed(i_r1data) > $signed(imm_7)) ? 1 : i_r1data == $signed(imm_7) ? 0 : -1;
assign imm_unsigned = (i_r1data > i_insn[6:0]) ? 1 : (i_r1data == i_insn[6:0] ? 0 : -1);
assign reg_signed = ($signed(i_r1data) > $signed(i_r2data)) ? 1 : (i_r1data == i_r2data ? 0 : -1);
assign reg_unsigned = (i_r1data > i_r2data) ? 1 : (i_r1data == i_r2data ? 0 : -1);

assign o_result = i_insn[8:7] == 0 ? reg_signed : (i_insn[8:7] == 1 ? reg_unsigned : ((i_insn[8:7] == 2) ? imm_signed : imm_unsigned));

endmodule


module full_arith(input wire [15:0] i_insn,
		  input wire [15:0] i_pc,
		  input wire [15:0] i_r1data,
		  input wire [15:0] i_r2data,
 		  output wire [15:0] o_result);

wire [15:0] arith_out;
wire [15:0] mult_out;
wire [15:0] quotient_out;
wire [15:0] remainder_out;

arith_insn arith(.i_insn(i_insn), .i_pc(i_pc), .i_r1data(i_r1data), 
.i_r2data(i_r2data), .o_result(arith_out));

assign mult_out = i_r1data * i_r2data;

lc4_divider div(.i_dividend(i_r1data), .i_divisor(i_r2data), .o_remainder(remainder_out), .o_quotient(quotient_out));

//a bit different from design, the extra part is that here we check for BRANCH first and if opcode == 0 we immediately proceed with arith_out despite the opcode.
assign o_result = i_insn[15:12] == 0 ? arith_out : ((i_insn[15:12] == 12 && i_insn[11] == 1) ? arith_out : (i_insn[15:12] == 1 && (i_insn[5] == 1 || i_insn[5:3] == 2)) ? arith_out : (i_insn[15:12] == 6 || i_insn[15:12] == 7) ? arith_out : ((i_insn[15:12] == 1 && i_insn[5:3] == 3) ? quotient_out : (i_insn[15:12] == 10 && i_insn[5:4] == 3) ? remainder_out : (i_insn[5:3] == 1 ? mult_out : arith_out)));

endmodule

module arith_insn(input wire [15:0] i_insn,
		input wire [15:0] i_pc,
		input wire [15:0] i_r1data,
		input wire [15:0] i_r2data,
		output wire [15:0] o_result);
wire o_cin;
cla_cin cin(.i_insn(i_insn), .i_pc(i_pc), .i_r1data(i_r1data), .o_cin(o_cin));

wire [15:0] o_cla_ain;
cla_ain a(.i_insn(i_insn), .i_pc(i_pc), .i_r1data(i_r1data), .o_ain(o_cla_ain));
 
wire [15:0] o_cla_bin;
cla_bin b(.i_insn(i_insn), .i_r2data(i_r2data), .o_bin(o_cla_bin));

cla16 c(.a(o_cla_ain), .b(o_cla_bin), .cin(o_cin), .sum(o_result));

endmodule

module cla_cin(input wire [15:0] i_insn,
		input wire [15:0] i_pc,
		input wire [15:0] i_r1data,
		output wire o_cin);

assign o_cin = (i_insn[15:12] == 1 && i_insn[5:3] == 2) ? 1 : ((i_insn[15:12] == 2) ? 1 : ((i_insn[15:12] == 0 || i_insn[15:12] == 12)) ? 1 : 0);

endmodule

module cla_ain(input wire [15:0] i_insn,
		input wire [15:0] i_pc,
		input wire [15:0] i_r1data,
		output wire [15:0] o_ain);

assign o_ain = (i_insn[15:12] == 0 || i_insn[15:12] == 12) ? i_pc : i_r1data;

endmodule

module cla_bin(input wire [15:0] i_insn, 
		input wire [15:0] i_r2data,
		output wire [15:0] o_bin);

wire [15:0] imm_9;
wire [15:0] imm_6;
wire [15:0] imm_11;
wire [15:0] arith_out;
wire [15:0] cmp_out;

assign imm_9 = {{7{i_insn[8]}}, i_insn[8:0]};
assign imm_6 = {{10{i_insn[5]}}, i_insn[5:0]};
assign imm_11 = {{5{i_insn[10]}}, i_insn[10:0]};

arith_bin arith(.i_insn(i_insn), .i_r2data(i_r2data), .o_result(arith_out));
cmp_bin cmp(.i_insn(i_insn), .i_r2data(i_r2data), .o_result(cmp_out));

assign o_bin = i_insn[15:12] == 0 ? imm_9 : (i_insn[15:12] == 1 ? arith_out : (i_insn[15:12] == 2 ? cmp_out : ((i_insn[15:12] == 12) ? imm_11 : imm_6))); 

endmodule

module arith_bin(input wire [15:0] i_insn,
		input wire [15:0] i_r2data,
		output wire [15:0] o_result);

wire [15:0] rt_or_neg_rt;
wire [15:0] imm_5;

assign imm_5 = {{11{i_insn[4]}}, i_insn[4:0]};
assign rt_or_neg_rt = i_insn[5:3] == 0 ? i_r2data : ~(i_r2data);

assign o_result = i_insn[5] == 0 ? rt_or_neg_rt : imm_5;

endmodule

module cmp_bin(input wire [15:0] i_insn,
		input wire [15:0] i_r2data,
		output wire [15:0] o_result);

wire [15:0] cmp_imm;
wire [15:0] cmp_imm_unsigned; 
//TODO: how to incorporate unsigned?
assign cmp_imm = ~({{8{i_insn[6]}}, i_insn[6:0]}); 
assign cmp_imm_unsigned = ~({{8{i_insn[6]}}, i_insn[6:0]});

//there may be an issue with the sign here

assign o_result = i_insn[8:7] == 0 ? ~(i_r2data) : (i_insn[8:7] == 1 ? ~(i_r2data) : (i_insn[8:7] == 2 ? cmp_imm : cmp_imm_unsigned));

endmodule

//TODO: how to make it unsigned?
module shifter(input wire [15:0] i_insn,
               input wire [15:0] i_r1data,
               output wire [15:0] o_result);

wire [15:0] sll;
wire [15:0] srl;
wire [15:0] sra;

assign sll = i_r1data << (i_insn[3:0]);
assign srl = i_r1data >> (i_insn[3:0]);
assign sra = $signed(i_r1data) >>> (i_insn[3:0]);

assign o_result = i_insn[5:4] == 0 ? sll : (i_insn[5:4] == 1 ? sra : srl);

endmodule

module const(input wire [15:0] i_insn,
	     output wire [15:0] o_result);


assign o_result = {{7{i_insn[8]}}, i_insn[8:0]}; 

endmodule

//TODO: how to make unsigned?
module hiconst(input wire [15:0] i_insn,
	       input wire [15:0] i_r1data,
               output wire [15:0] o_result);

wire [15:0] r1_and_ff;
wire [15:0] shifted_imm;

assign r1_and_ff = i_r1data & 'hFF;
assign shifted_imm = (i_insn[7:0] << 8);

assign o_result = (r1_and_ff | shifted_imm);

endmodule

module logical(input wire [15:0] i_insn, 
		input wire [15:0] i_r1data,
		input wire [15:0] i_r2data,
		output wire [15:0] o_result);

wire [15:0] and_op;
wire [15:0] or_op;
wire [15:0] xor_op;
wire [15:0] not_op;
wire [15:0] andi_op;
wire [15:0] no_imm_ops;
wire [15:0] imm_5;

assign imm_5 = {{11{i_insn[4]}}, i_insn[4:0]};

assign and_op = i_r1data & i_r2data;
assign or_op = i_r1data | i_r2data;
assign xor_op = i_r1data ^ i_r2data;
assign not_op = ~i_r1data;
assign andi_op = i_r1data & imm_5;

assign no_imm_ops = i_insn[5:3] == 0 ? and_op :
	(i_insn[5:3] == 1 ? not_op : (i_insn[5:3] == 2 ? or_op : xor_op));

assign o_result = i_insn[5] == 0 ? no_imm_ops : andi_op;  

endmodule

//TODO: how to unsigned?
module trap(input wire [15:0] i_insn, 
		output wire [15:0] o_result);

assign o_result = 'h8000 | i_insn[7:0];

endmodule

module rti(input wire [15:0] i_r1data,
		output wire [15:0] o_result);

assign o_result = i_r1data;

endmodule

module jump_subroutine(input wire [15:0] i_insn,
			input wire [15:0] i_pc,
			input wire [15:0] i_r1data,
			output wire [15:0] o_result);

wire [15:0] shifted_imm;
wire [15:0] pc_trapped;
wire [15:0] jsr_out;

assign shifted_imm = (i_insn[10:0] << 4);
assign pc_trapped = (i_pc & 'h8000);

assign jsr_out = pc_trapped | shifted_imm;

assign o_result = i_insn[11] ? jsr_out : i_r1data;

endmodule

