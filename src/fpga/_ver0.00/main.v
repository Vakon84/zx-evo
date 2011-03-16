// PentEvo project (c) NedoPC 2008-2009
//
// top level module with physical pins and module interconnect, also some low-level functionality

module main(

	// clocks
	input fclk,
	output clkz_out,
	input clkz_in,

	// z80
	input iorq_n,
	input mreq_n,
	input rd_n,
	input wr_n,
	input m1_n,
	input rfsh_n,
	output int_n,
	output nmi_n,
	output wait_n,
	output res,

	inout [7:0] d,
	input [15:0] a,

	// zxbus and related
	output csrom,
	output romoe_n,
	output romwe_n,

	output rompg0_n,
	output dos_n, // aka rompg1
	output rompg2,
	output rompg3,
	output rompg4,

	input iorqge1,
	input iorqge2,
	output iorq1_n,
	output iorq2_n,

	// DRAM
	inout [15:0] rd,
	output [9:0] ra,
	output rwe_n,
	output rucas_n,
	output rlcas_n,
	output rras0_n,
	output rras1_n,

	// video
	output [1:0] vred,
	output [1:0] vgrn,
	output [1:0] vblu,

	output vhsync,
	output vvsync,
	output vcsync,

	// AY control and audio/tape
	output ay_clk,
	output ay_bdir,
	output ay_bc1,

	output beep,

	// IDE
	output [2:0] ide_a,
	inout [15:0] ide_d,

	output ide_dir,

	input ide_rdy,

	output ide_cs0_n,
	output ide_cs1_n,
	output ide_rs_n,
	output ide_rd_n,
	output ide_wr_n,

	// VG93 and diskdrive
	output vg_clk,

	output vg_cs_n,
	output vg_res_n,

	output vg_hrdy,
	output vg_rclk,
	output vg_rawr,
	output [1:0] vg_a, // disk drive selection
	output vg_wrd,
	output vg_side,

	input step,
	input vg_sl,
	input vg_sr,
	input vg_tr43,
	input rdat_b_n,
	input vg_wf_de,
	input vg_drq,
	input vg_irq,
	input vg_wd,

	// serial links (atmega-fpga, sdcard)
	output sdcs_n,
	output sddo,
	output sdclk,
	input sddi,

	input spics_n,
	input spick,
	input spido,
	output spidi,
	output spiint_n
);


	wire zclk; // z80 clock for short
	reg [2:0] zclk_gen; // make 3.5 mhz clock

	wire rst_n; // global reset

	wire rrdy;
	wire cbeg;
	wire [15:0] rddata;

	wire [4:0] rompg;

	wire [7:0] zports_dout;
	wire zports_dataout;
	wire porthit;

	wire [4:0] keys;
	wire tape_in;

	wire [15:0] ideout;
	wire [15:0] idein;


	wire [7:0] zmem_dout;
	wire zmem_dataout;


	wire [7:0] sd_dout_to_zports;
	wire start_from_zports;
	wire sd_inserted;
	wire sd_readonly;


	reg [3:0] ayclk_gen;


	wire [7:0] received;
	wire [7:0] tobesent;


	wire intrq,drq;
	wire vg_wrFF;





	// Z80 clock control
	assign zclk = clkz_in;
	always @(posedge fclk)
		zclk_gen <= zclk_gen + 3'd1;
	assign clkz_out = zclk_gen[2];


	// RESETTER
	resetter myrst( .clk(fclk),
	                .rst_in1_n(1'b1),
	                .rst_in2_n(1'b1),
	                .rst_out_n(rst_n) );
	defparam myrst.RST_CNT_SIZE = 6;
	assign res = ~rst_n;



	dram mydram( .clk(fclk),
	             .rst_n(rst_n),
	             .ra(ra),
	             .rd(rd),
	             .rwe_n(rwe_n),
	             .rras0_n(rras0_n),
	             .rras1_n(rras1_n),
	             .rucas_n(rucas_n),
	             .rlcas_n(rlcas_n),
	             .req(1'b1),
	             .rnw(wr_n),
	             .rrdy(rrdy),
	             .cbeg(cbeg),
	             .bsel({a[0],~a[0]}),
	             .wrdata({d,~d}),
	             .rddata(rddata),
	             .addr({a[5:0],a[15:1]}) );

	vdac myvdac( .clk(fclk),
	             .strobe(rrdy),
	             .din(rddata),
	             .vred(vred),
	             .vgrn(vgrn),
	             .vblu(vblu) );

	zports myzprt( .clk(zclk),
	               .rst_n(rst_n),

	               .a(a),
	               .din(d),
	               .dout(zports_dout),
	               .dataout(zports_dataout),
	               .porthit(porthit),

	               .iorq_n(iorq_n),
	               .rd_n(rd_n),
	               .wr_n(wr_n),

	               .keys(keys),
	               .tape_in(tape_in),
	               .beep(beep),

	               .ideout(ideout),
	               .idein(idein),
	               .idedataout(ide_dir),
	               .ide_a(ide_a),
	               .ide_cs0_n(ide_cs0_n),
	               /*.ide_cs1_n(ide_cs1_n),*/
	               .ide_rd_n(ide_rd_n),
	               .ide_wr_n(ide_wr_n),

	               .sd_dout(sd_dout_to_zports),
	               .sd_start(start_from_zports),
	               .sdcs_n(sdcs_n),
	               .sd_readonly(sd_readonly),
	               .sd_inserted(sd_inserted),

	               .ay_bdir(ay_bdir),
	               .ay_bc1(ay_bc1),

	               .vg_wrFF(vg_wrFF),
	               .vg_intrq(intrq),
	               .vg_drq(drq),
	               .vg_cs_n(vg_cs_n)
	               );

	vg93 myvg ( .zclk(zclk),
	            .fclk(fclk),
	            .rst_n(rst_n),
	            .vg_clk(vg_clk),
	            .vg_res_n(vg_res_n),
	            .din(d),
	            .intrq(intrq),
	            .drq(drq),
	            .vg_wrFF(vg_wrFF),
	            .vg_hrdy(vg_hrdy),
	            .vg_rclk(vg_rclk),
	            .vg_rawr(vg_rawr),
	            .vg_a(vg_a),
	            .vg_wrd(vg_wrd),
	            .vg_side(vg_side),
	            .step(step),
	            .vg_sl(vg_sl),
	            .vg_sr(vg_sr),
	            .vg_tr43(vg_tr43),
	            .rdat_n(rdat_b_n),
	            .vg_wf_de(vg_wf_de),
	            .vg_drq(vg_drq),
	            .vg_irq(vg_irq),
	            .vg_wd(vg_wd)
	            );




	zmem myzmem( .a(a),
	             .din(d),
	             .dout(zmem_dout),
	             .dataout(zmem_dataout),
	             .csrom(csrom),
	             .romoe_n(romoe_n),
	             .romwe_n(romwe_n),
	             .iorq_n(iorq_n),
	             .mreq_n(mreq_n),
	             .rd_n(rd_n),
	             .wr_n(wr_n),
	             .m1_n(m1_n),
	             .rfsh_n(rfsh_n),
	             .rompg(rompg) );


	spi2 mysd( .din(d),
	           .dout(sd_dout_to_zports),
	           .clock(zclk),
	           .sck(sdclk),
	           .sdi(sddi),
	           .sdo(sddo),
	           .start(start_from_zports),
	           .speed(2'b00) );

	slavespi myslave( .spick(spick),
	                  .spidi(spidi),
	                  .spido(spido),
	                  .spics_n(spics_n),

	                  .spiint_n(spiint_n),

	                  .received(received),
	                  .tobesent(tobesent) );

	shitsync myshit( .clk(fclk),
	                 .cbeg(cbeg),
	                 .vhsync(vhsync),
	                 .vvsync(vvsync),
	                 .vcsync(vcsync),
	                 .int_n(int_n) );




// IDE bus control

	assign ide_rs_n = rst_n;

	assign idein = ide_d;

	assign ide_d = ide_dir ? ideout : 16'hZZZZ;


// Z80 data bus control

	assign d = zmem_dataout ? zmem_dout : ( zports_dataout ? zports_dout : 8'hZZ );

// ZXBUS iorq1_n and iorq2_n generation

	assign iorq1_n = iorq_n | porthit;
	assign iorq2_n = iorq1_n | iorqge1;

//ROM addresses control
	assign rompg0_n = ~rompg[0];
	assign dos_n    =  rompg[1];
	assign {rompg4,rompg3,rompg2} = rompg[4:2];

//AY control
	always @(posedge fclk)
	begin
		ayclk_gen <= ayclk_gen + 4'd1;
	end

	assign ay_clk = ayclk_gen[3];


// all shit and stubs

	assign keys = received[4:0];
	assign tape_in = received[5];

	assign sd_readonly = received[6];
	assign sd_inserted = received[7];

	assign tobesent[7] = beep;
	assign tobesent[6:0] = d[7:1];

	assign wait_n = ide_rdy;

	assign nmi_n = m1_n ^ rfsh_n;
	assign ide_cs1_n = iorqge2 ^ vg_wf_de;

endmodule
