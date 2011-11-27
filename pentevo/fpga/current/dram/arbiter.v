`include "../include/tune.v"

// PentEvo project (c) NedoPC 2008-2011
//
// DRAM arbiter. Shares DRAM between processor and video data fetcher
//



// 20.11.2011:
// arbiter has been re-factored so it uses N_cycles out of 4/8


// 14.06.2011:
// removed cpu_stall and cpu_waitcyc.
// changed cpu_strobe behavior (only strobes read data arrival now).
// added cpu_next signal (shows whether next DRAM cycle CAN be grabbed by CPU)
//
// Now it is a REQUIREMENT for 'go' signal only starting and ending on
// beginning of DRAM cycle (i.e. right after 'c6' strobe).
//


// 13.06.2011:
// ������� �����������, ���� go �������������� ����� ����� c6 (� ���� [lvd] ��� ���).
// ��� ��� ����, ����� ��������� �� 14��� ��� ������� � � ����� ������ �����, ��
// ������� �����������. ������ cpu_ack ������ ������ ������, ������� � ������� �����
// ����-����� ����� ����������, ��� ����� ���� ��������� ���� - ���������� ��� ������
// �����. �� ���� ��� � ����� ����� cpu_ack, �� �������� � ������ cpu_req (�.�.
// � ������ c6) � �����.

// 12.06.2011:
// ��������: ���� ��� ������ ���� ������, � ��� ���� �� �����,
// �� �� ������ ������� cpu_req. ������, ����� �� ��� �����
// ������ �� cpu_strobe, ��� ���� ����� ���������� ��� ����
// ������ ������!!!
// �������: �������� ������ cpu_ack, �� �������� �������, ���
// ������ ������� ������ (������ ��� ������), ������� �����
// ��������� � �������� cpu_strobe �� ������ (c0), � �������
// cpu_strobe ������� ������ ��� ����� ������ �� ����������
// ������� �����.
// ���, ��������, �������� ������� ������ cpu_waitcyc...


// Arbitration is made on full 8-cycle access blocks. Each cycle is defined by dram.v and consists of 4 fpga clocks.
// During each access block, there can be either no videodata access, 1 videodata access, 2, 4 or full 8 accesses.
// All spare cycles can be used by processor. If nobody uses memory in the given cycle, refresh cycle is performed
//
// In each access block, videodata accesses are spreaded all over the block so that processor receives cycle
// as fast as possible, until there is absolute need to fetch remaining video data
//
// Examples:
//
// |                 access block                  | 4 video accesses during block, no processor accesses. video accesses are done
// | vid | vid | vid | vid | ref | ref | ref | ref | as soon as possible, spare cycles are refresh ones
//
// |                 access block                  | 4 video accesses during block, processor requests access every other cycle
// | vid | prc | vid | prc | vid | prc | vid | prc |
//
// |                 access block                  | 4 video accesses, processor begins requesting cycles continously from second one
// | vid | prc | prc | prc | prc | vid | vid | vid | so it is given cycles while there is such possibility. after that processor
//                                                   can't access mem until the end of access block and stalls
//
// |                 access block                  | 8 video accesses, processor stalls, if it is requesting cycles
// | vid | vid | vid | vid | vid | vid | vid | vid |
//
// |                 access block                  | 2 video accesses, single processor request, other cycles are refresh ones
// | vid | vid | ref | ref | cpu | ref | ref | ref |
//
// |                 access block                  | 4 video accesses, single processor request, other cycles are refresh ones
// | vid | vid | cpu | vid | vid | ref | ref | ref |
//
// access block begins at any dram cycle, then blocks go back-to-back
//
// key signals are go and cpu_req, sampled at the end of each dram cycle. Must be set to the module
// one clock cycle earlier the clock of the beginning current dram cycle

module arbiter(

	input clk, f0,
	input rst_n,

	// dram.v interface
	output     [20:0] dram_addr,   // address for dram access
	output reg        dram_req,    // dram request
	output reg        dram_rnw,    // Read-NotWrite
	input             dram_c0,   // cycle begin
	input             dram_rrdy,   // read data ready (coincides with c6)
	output      [1:0] dram_bsel,   // positive bytes select: bsel[1] for wrdata[15:8], bsel[0] for wrdata[7:0]
	input      [15:0] dram_rddata, // data just read
	output     [15:0] dram_wrdata, // data to be written


	input reg c6,      // regenerates this signal: end of DRAM cycle. c6 is one-cycle positive pulse just before c0 pulse
	input reg c4,  // one clock earlier c6
	input reg c2, // one more earlier


	input go, // start video access blocks

	// input [1:0] bw, // required bandwidth: 3'b00 - 1 video cycle per block
	input wire [3:0] video_bw,
								// 4'b0x00 - 4 video accesses of 4 (stall of CPU)
								// 4'b0x01 - 1 video access of 4
								// 4'b0x10 - 2 video accesses of 4
								
								// 4'b1000 - 8 video accesses of 8 (stall of CPU)
								// 4'b1001 - 1 video access of 8
								// 4'b1010 - 2 video accesses of 8
								// 4'b1100 - 4 video accesses of 8

	input  [20:0] video_addr,   // during access block, only when video_strobe==1
	output [15:0] video_data,   // read video data which is valid only during video_strobe==1 because video_data
	                            // is just wires to the dram.v's rddata signals
	output wire   video_strobe, // positive one-cycle strobe as soon as there is next video_data available.
	                            // if there is video_strobe, it coincides with c6 signal
	output wire    video_next,   // on this signal you can change video_addr; it is one clock leading the video_strobe

	input wire 		   ts_req,
	input wire  [20:0] ts_addr,
	output wire [15:0] ts_data,
	output wire        ts_next,
	output wire        ts_strobe,


	input wire        cpu_req,
	input wire        cpu_rnw,
	input wire [20:0] cpu_addr,
	input wire [ 7:0] cpu_wrdata,
	input wire        cpu_wrbsel,

	output wire [15:0] cpu_rddata,
	output reg         cpu_next,
    output reg         cpu_strobe
);

	wire c0;

	reg stall;
	reg cpu_rnw_r;

	reg [2:0] blk_rem;  // remaining accesses in a block (7..0)
	reg [2:0] blk_nrem; // remaining for the next dram cycle

	reg [2:0] vid_rem;  // remaining video accesses in block (4..0)
	reg [2:0] vid_nrem; // for rhe next cycle


	wire [2:0] vidmax; // max number of video cycles in a block, depends on bw input


	localparam CYC_CPU   = 2'b00;
	localparam CYC_VIDEO = 2'b01;
	localparam CYC_TS    = 2'b10;
	localparam CYC_FREE  = 2'b11;

	wire next_cpu = next_cycle == CYC_CPU;
	wire next_vid = next_cycle == CYC_VIDEO;
	wire next_ts  = next_cycle == CYC_TS;
	wire next_fre = next_cycle == CYC_FREE;
	
	wire curr_cpu = curr_cycle == CYC_CPU;
	wire curr_vid = curr_cycle == CYC_VIDEO;
	wire curr_ts  = curr_cycle == CYC_TS;
	wire curr_fre = curr_cycle == CYC_FREE;
	
	reg [1:0] curr_cycle; // type of the cycle in progress
	reg [1:0] next_cycle; // type of the next cycle





	initial // simulation only!
	begin
		curr_cycle = CYC_FREE;
		blk_rem = 0;
		vid_rem = 0;
	end




	assign c0 = dram_c0; // just alias

	wire bw_full = {video_bw[3] & video_bw[2], video_bw[1:0]} == 3'b0;

	// track blk_rem counter: how many cycles left to the end of block (7..0)
	always @(posedge clk) if( c6 )
	begin
		blk_rem <= blk_nrem;

		if( (blk_rem==3'd0) )
			stall <= bw_full & go;
	end

	always @*
	begin
		if( (blk_rem==3'd0) && go )
			blk_nrem = {video_bw[3], 2'b11};	// select 4/8 cycles per burst
			// blk_nrem = 7;	
		else
			blk_nrem = (blk_rem==0) ? 3'd0 : (blk_rem-3'd1);
	end



	// track vid_rem counter
	assign vidmax = {video_bw[3] & video_bw[2], video_bw[1:0]}; // number of cycles for video access
	// assign vidmax = (3'b001) << bw; // number of cycles to perform

	always @(posedge clk) if( c6 )
	begin
		vid_rem <= vid_nrem;
	end

	always @*
	begin
		if( go && (blk_rem==3'd0) )
			vid_nrem = cpu_req ? vidmax : (vidmax-3'd1);
		else
			if( next_vid )
				vid_nrem = (vid_rem==3'd0) ? 3'd0 : (vid_rem-3'd1);
			else
				vid_nrem = vid_rem;
	end




	// next cycle decision
	always @*
	begin
		if( blk_rem==3'd0 )
		begin
			if( go )
			begin
				if( bw_full )
				begin
					cpu_next = 1'b0;

					next_cycle = CYC_VIDEO;
				end
				else
				begin
					cpu_next = 1'b1;

					if( cpu_req )
						next_cycle = CYC_CPU;
					else
						next_cycle = CYC_VIDEO;
				end
			end
			else // !go
			begin
				cpu_next = 1'b1;

				if( cpu_req )
					next_cycle = CYC_CPU;
				else
				if( ts_req )
					next_cycle = CYC_TS;
				else
					next_cycle = CYC_FREE;
			end
		end
		else // blk_rem!=3'd0
		begin
			if( stall )
			begin
				cpu_next = 1'b0;

				next_cycle = CYC_VIDEO;
			end
			else
			begin
				if( vid_rem==blk_rem )
				begin
					cpu_next = 1'b0;
	
					next_cycle = CYC_VIDEO;
				end
				else
				begin
					cpu_next = 1'b1;
	
					if( cpu_req )
						next_cycle = CYC_CPU;
					else
					if( ts_req )
						next_cycle = CYC_TS;
					else
						if( vid_rem==3'd0 )
							next_cycle = CYC_FREE;
						else
							next_cycle = CYC_VIDEO;
				end
			end
		end
	end




	// just current cycle registering
	always @(posedge clk) if( c6 )
	begin
		curr_cycle <= next_cycle;
	end




	// route required data/etc. to and from the dram.v

	assign dram_wrdata[15:0] = { cpu_wrdata[7:0], cpu_wrdata[7:0] };
	assign dram_bsel[1:0] = { cpu_wrbsel, ~cpu_wrbsel };

	assign dram_addr = next_cpu ? cpu_addr : next_vid ? video_addr : ts_addr;

	assign cpu_rddata = dram_rddata;
	assign video_data = dram_rddata;
	assign ts_data = dram_rddata;

	always @*
	begin
		if( next_fre ) // CYC_FREE
		begin
			dram_req = 1'b0;
			dram_rnw = 1'b1;
		end
		else // CYC_CPU or CYC_VIDEO
		begin
			dram_req = 1'b1;
			if( next_cpu ) // CYC_CPU
				dram_rnw = cpu_rnw;
			else // CYC_VIDEO
				dram_rnw = 1'b1;
		end
	end



	// generation of read strobes: for video and cpu


	always @(posedge clk) if( c6 )
		cpu_rnw_r <= cpu_rnw;


	always @(posedge clk) if (f0)
	begin
		if( curr_cpu && cpu_rnw_r && c4 )
			cpu_strobe <= 1'b1;
		else
			cpu_strobe <= 1'b0;
	end


	assign video_next = curr_vid & c4;
	assign video_strobe = curr_vid & c6;

	assign ts_next = curr_ts & c4;
	assign ts_strobe = curr_ts & c6;

	
endmodule

