`timescale 1ns/1ps

module top_ssram(
	
	input				sys_clk_p,
	input				sys_clk_n,
	input				reset,
	
	output				ssram_clk,
	output				ssram_nwr,
	output				ssram_ce,
	output				ssram_adv,
	output				ssram_ncke,
	
	output				ssram_nft,
	output				ssram_nlbo,
	output				ssram_ng,
	
	output				ssram_baen,
	output				ssram_bben,
	output				ssram_bcen,
	output				ssram_bden,
	
	output	[1 : 0]		ssram_bar,
	output	[17 : 0]	ssram_a,
	
	inout	[8 : 0]		ssram_adq,
	inout	[8 : 0]		ssram_bdq,
	inout	[8 : 0]		ssram_cdq,
	inout	[8 : 0]		ssram_ddq
);
	
	wire				sys_clock;
	
	reg					ssram_dq_ctrl;
	reg		[8 : 0]		ssram_dq;
	reg		[19 : 0]	ssram_addr;
	
	reg					ssram_nwr_reg;
	reg					ssram_en_reg;
	reg					ssram_adv_reg;
	reg					ssram_ncke_reg;
	
	reg		[3 : 0]		ssram_ben_reg;
	
	assign {ssram_a, ssram_bar} = ssram_addr;
	assign {ssram_bden, ssram_bcen, ssram_bben, ssram_baen} = ssram_ben_reg;
	
	reg		[4 : 0]		state_cnt;
	
	assign ssram_nft	= 1'b1;
	assign ssram_nlbo	= 1'b0;
	assign ssram_ng		= 1'b0;
	
	assign ssram_nwr	= ssram_nwr_reg;
	assign ssram_ce		= ssram_en_reg;
	assign ssram_ncke	= ssram_ncke_reg;
	assign ssram_adv	= ssram_adv_reg;
	
	assign ssram_clk	= !sys_clock;
	
	wire	[8 : 0]		ssram_adq_in;
	wire	[8 : 0]		ssram_bdq_in;
	wire	[8 : 0]		ssram_cdq_in;
	wire	[8 : 0]		ssram_ddq_in;
	
	IBUFGDS #(
		.DIFF_TERM("FALSE"),
		.IBUF_LOW_PWR("FALSE"),
		.IOSTANDARD("DIFF_SSTL15")
	) IBUFDS_inst (
		.I		(sys_clk_p),
		.IB		(sys_clk_n),
		.O		(sys_clock)
	);
	
	generate
		
		genvar i;
		
		for(i = 0; i < 9; i = i + 1)begin : IO_tri_map_a
			IOBUF #(
				.DRIVE			(12),
				.IBUF_LOW_PWR	("FALSE"),
				.IOSTANDARD		("LVCMOS33"),
				.SLEW			("FAST")
			)IOBUF_DQA(
				.I	(ssram_dq[i]),
				.IO	(ssram_adq[i]),
				.O	(ssram_adq_in[i]),
				.T	(ssram_dq_ctrl)
			);
			
			IOBUF #(
				.DRIVE			(12),
				.IBUF_LOW_PWR	("FALSE"),
				.IOSTANDARD		("LVCMOS33"),
				.SLEW			("FAST")
			)IOBUF_DQB(
				.I	(ssram_dq[i]),
				.IO	(ssram_bdq[i]),
				.O	(ssram_bdq_in[i]),
				.T	(ssram_dq_ctrl)
			);
			
			IOBUF #(
				.DRIVE			(12),
				.IBUF_LOW_PWR	("FALSE"),
				.IOSTANDARD		("LVCMOS33"),
				.SLEW			("FAST")
			)IOBUF_DQC(
				.I	(ssram_dq[i]),
				.IO	(ssram_cdq[i]),
				.O	(ssram_cdq_in[i]),
				.T	(ssram_dq_ctrl)
			);
			
			IOBUF #(
				.DRIVE			(12),
				.IBUF_LOW_PWR	("FALSE"),
				.IOSTANDARD		("LVCMOS33"),
				.SLEW			("FAST")
			)IOBUF_DQD(
				.I	(ssram_dq[i]),
				.IO	(ssram_ddq[i]),
				.O	(ssram_ddq_in[i]),
				.T	(ssram_dq_ctrl)
			);
		end
		
	endgenerate
	
	
	
	ssram_ila ssram_ila_inst0(
		
		.clk		(sys_clock),
		
		.probe0		(ssram_addr),
		
		.probe1		(ssram_adq_in),
		.probe2		(ssram_bdq_in),
		.probe3		(ssram_cdq_in),
		.probe4		(ssram_ddq_in),
		
		.probe5		(ssram_ben_reg),
		
		.probe6		(ssram_nwr_reg),
		.probe7		(ssram_en_reg),
		.probe8		(ssram_ncke_reg),
		.probe9		(ssram_adv_reg),
		
		.probe10	(ssram_dq)
	);
	
	reg [15 : 0] delay_cnt;
	
	always@(posedge sys_clock)begin
		
		if(reset)begin
			
			ssram_addr <= 20'd0;
			ssram_nwr_reg <= 1'b1;
			ssram_dq_ctrl <= 1'b1;
			ssram_en_reg <= 1'b0;
			ssram_ncke_reg <= 1'b0;
			ssram_adv_reg <= 1'b1;
			ssram_ben_reg <= 4'b1111;
			ssram_dq <= 9'd0;
			
			state_cnt <= 5'd0;
			delay_cnt <= 16'd0;
			
		end else begin
			
			case(state_cnt)
				
				5'd0: begin
					ssram_addr <= 20'd0;
					ssram_nwr_reg <= 1'b1;
					ssram_dq_ctrl <= 1'b1;
					ssram_en_reg <= 1'b0;
					ssram_ncke_reg <= 1'b0;
					ssram_adv_reg <= 1'b1;
					ssram_ben_reg <= 4'b1111;
					ssram_dq <= 9'd0;
					
					delay_cnt <= delay_cnt + 1'b1;
					
					if(delay_cnt[15])begin
						state_cnt <= 5'd1;
						delay_cnt <= 16'd0;
					end
				end
				
				5'd1: begin
					ssram_addr <= 20'd0;
					ssram_ncke_reg <= 1'b0;
					ssram_en_reg <= 1'b1;
					ssram_adv_reg <= 1'b0;
					ssram_nwr_reg <= 1'b0;
					ssram_ben_reg <= 4'b1110;
					
					state_cnt <= 5'd2;
				end
				
				5'd2: begin
					ssram_addr <= 20'd0;
					ssram_ncke_reg <= 1'b0;
					ssram_en_reg <= 1'b1;
					ssram_adv_reg <= 1'b0;
					ssram_nwr_reg <= 1'b0;
					ssram_ben_reg <= 4'b1101;
					
					state_cnt <= 5'd3;
				end
				
				5'd3: begin
					ssram_addr <= 20'd0;
					ssram_ncke_reg <= 1'b0;
					ssram_en_reg <= 1'b1;
					ssram_adv_reg <= 1'b0;
					ssram_nwr_reg <= 1'b0;
					ssram_ben_reg <= 4'b1011;
					
					ssram_dq_ctrl <= 1'b0;
					ssram_dq <= 9'd237;
					
					state_cnt <= 5'd4;
				end
				
				5'd4: begin
					ssram_addr <= 20'd0;
					ssram_ncke_reg <= 1'b0;
					ssram_en_reg <= 1'b1;
					ssram_adv_reg <= 1'b0;
					ssram_nwr_reg <= 1'b0;
					ssram_ben_reg <= 4'b0111;
					
					ssram_dq_ctrl <= 1'b0;
					ssram_dq <= 9'd183;
					
					state_cnt <= 5'd5;
				end
				
				5'd5: begin
					ssram_addr <= 20'd0;
					ssram_ncke_reg <= 1'b0;
					ssram_en_reg <= 1'b1;
					ssram_adv_reg <= 1'b0;
					ssram_nwr_reg <= 1'b1;
					ssram_ben_reg <= 4'b1111;
					
					ssram_dq_ctrl <= 1'b0;
					ssram_dq <= 9'd477;
					
					state_cnt <= 5'd6;
				end
				
				5'd6: begin
					ssram_addr <= 20'd0;
					ssram_ncke_reg <= 1'b0;
					ssram_en_reg <= 1'b1;
					ssram_adv_reg <= 1'b0;
					ssram_nwr_reg <= 1'b1;
					
					ssram_dq_ctrl <= 1'b0;
					ssram_dq <= 9'd98;
					
					state_cnt <= 5'd7;
				end
				
				5'd7: begin
					ssram_addr <= 20'd0;
					ssram_ncke_reg <= 1'b0;
					ssram_en_reg <= 1'b1;
					ssram_adv_reg <= 1'b0;
					ssram_nwr_reg <= 1'b1;
					
					ssram_dq_ctrl <= 1'b1;
					ssram_dq <= 9'd0;
					
					state_cnt <= 5'd8;
				end
				
				5'd8: begin
					ssram_addr <= 20'd0;
					ssram_ncke_reg <= 1'b0;
					ssram_en_reg <= 1'b1;
					ssram_adv_reg <= 1'b0;
					ssram_nwr_reg <= 1'b1;
					ssram_dq_ctrl <= 1'b1;
					
					state_cnt <= 5'd9;
				end
				
				5'd9,5'd10,5'd11,5'd12,5'd13,5'd14,5'd15: begin
					ssram_addr <= 20'd0;
					ssram_ncke_reg <= 1'b0;
					ssram_en_reg <= 1'b1;
					ssram_adv_reg <= 1'b0;
					ssram_nwr_reg <= 1'b1;
					ssram_dq_ctrl <= 1'b1;
					
					state_cnt <= state_cnt + 1'b1;
				end
				
				5'd16: begin
					ssram_addr <= 20'd0;
					ssram_ncke_reg <= 1'b0;
					ssram_en_reg <= 1'b1;
					ssram_adv_reg <= 1'b1;
					ssram_nwr_reg <= 1'b1;
					ssram_dq_ctrl <= 1'b1;
				end
				
				default: begin
					state_cnt <= 5'd0;
				end
			endcase
		end
	end
	
endmodule
