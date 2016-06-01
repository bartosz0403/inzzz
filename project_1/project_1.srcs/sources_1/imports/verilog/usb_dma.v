/////////////////////////////////////////////////////////////////////
////                                                             
////  USB Internal DMA 
////
/////////////////////////////////////////////////////////////////////   

`include "usb_defines.v"

module usb_dma(	clk, rst,

		// Packet Disassembler/Assembler interface
		rx_data_valid,
		rx_data_done, 
		send_data,
		rd_next,

		tx_valid,
		tx_data_st_i,// wejscie odtx_data st z enpoitu
		tx_data_st_o,//wyjscie z na packet assembler

		// Protocol Engine
		tx_dma_en, rx_dma_en, idma_done,
	


		size,
		rx_cnt, rx_done,
		tx_busy,

		mwe, mre, ep_empty, ep_empty_int, ep_full
		);


// Packet Disassembler/Assembler interface
input		clk, rst;
input		rx_data_valid;
input		rx_data_done;
output		send_data;
input		rd_next;

input		tx_valid;
input	[7:0]	tx_data_st_i;
output	[7:0]	tx_data_st_o;

// Protocol Engine
input		tx_dma_en;
input		rx_dma_en;
output		idma_done;	// DMA is done


// Register File Manager Interface
input	[8:0]	size;		// MAX PL Size in bytes
output	[7:0]	rx_cnt;
output		rx_done;
output		tx_busy;


// Memory Arb interface
output		mwe;
output		mre;
input		ep_empty;
output		ep_empty_int;
input		ep_full;


reg		tx_dma_en_r;
reg	[8:0]	sizd_c;			// Internal size counter
wire		adr_incw;
wire		adr_incb;
wire		siz_dec;
wire		mwe;			// Memory Write enable
wire		mre;			// Memory Read enable
reg		mwe_r;
reg		sizd_is_zero;		// Indicates when all bytes have been
					// transferred
wire		sizd_is_zero_d;
reg		idma_done;		// DMA transfer is done
wire		send_data;		// Enable UTMI Transmitter
reg		rx_data_done_r;
reg		rx_data_valid_r;
wire		ff_re, ff_full, ff_empty;
reg		ff_we, ff_we1;
reg		tx_dma_en_r1;
reg		tx_dma_en_r2;
reg		tx_dma_en_r3;
reg		send_data_r;
wire		ff_clr;
reg	[7:0]	rx_cnt;
reg	[7:0]	rx_cnt_r;
reg		ep_empty_r;
reg		ep_empty_latched;
wire		ep_empty_int;
reg	[6:0]	ec;
wire		ec_clr;
//reg		dropped_frame;
reg	[6:0]	rc_cnt;
wire		rc_clr;
reg		ep_full_latched;
wire		ep_full_int;
//reg		misaligned_frame;
reg		tx_valid_r;
wire		tx_valid_e;


assign ep_empty_int = ep_empty;

assign ep_full_int = ep_full;




always @(posedge clk)
	mwe_r <= #1 rx_data_valid;

assign mwe = mwe_r & !ep_full_int;






always @(posedge clk)
	rx_data_valid_r <= #1 rx_data_valid;

always @(posedge clk)
	rx_data_done_r <= #1 rx_data_done;

// Generate one cycle pulses for tx and rx dma enable
always @(posedge clk)
	tx_dma_en_r <= #1 tx_dma_en;

always @(posedge clk)
	tx_dma_en_r1 <= tx_dma_en_r;

always @(posedge clk)
	tx_dma_en_r2 <= tx_dma_en_r1;

always @(posedge clk)
	tx_dma_en_r3 <= tx_dma_en_r2;

// DMA Done Indicator
always @(posedge clk)
	idma_done <= #1 (rx_data_done_r | sizd_is_zero_d | ep_empty_int);

///////////////////////////////////////////////////////////////////
//
// RX Size Counter
//

always @(posedge clk or negedge rst)
	if(!rst)			rx_cnt_r <= #1 8'h00;
	else
	if(rx_data_done_r)		rx_cnt_r <= #1 8'h00;
	else
	if(rx_data_valid)		rx_cnt_r <= #1 rx_cnt_r + 8'h01;

always @(posedge clk or negedge rst)
	if(!rst)		rx_cnt <= #1 8'h00;
	else
	if(rx_data_done_r)	rx_cnt <= #1 rx_cnt_r;

assign rx_done = rx_data_done_r;

///////////////////////////////////////////////////////////////////
//
// Transmit Size Counter (counting backward from input size)
// For MAX packet size
//

always @(posedge clk or negedge rst)
	if(!rst)			sizd_c <= #1 9'h1ff;
	else
	if(tx_dma_en)			sizd_c <= #1 size;
	else
	if(siz_dec)			sizd_c <= #1 sizd_c - 9'h1;

assign siz_dec = (tx_dma_en_r | tx_dma_en_r1 | rd_next) & !sizd_is_zero_d;

assign sizd_is_zero_d = sizd_c == 9'h0;

always @(posedge clk)
	sizd_is_zero <= #1 sizd_is_zero_d;

///////////////////////////////////////////////////////////////////
//
// TX Logic
//

assign tx_busy = send_data | tx_dma_en_r | tx_dma_en;

always @(posedge clk)
	tx_valid_r <= #1 tx_valid;

assign tx_valid_e = tx_valid_r & !tx_valid;

// Since we are prefetching two entries in to our fast fifo, we
// need to know when exactly ep_empty was asserted, as we might
// only need 1 or 2 bytes. This is for ep_empty_r

always @(posedge clk or negedge rst)
	if(!rst)				ep_empty_r <= #1 1'b0;
	else
	if(!tx_valid)				ep_empty_r <= #1 1'b0;
	else
	if(tx_dma_en_r2)			ep_empty_r <= #1 ep_empty_int;

always @(posedge clk or negedge rst)
	if(!rst)				send_data_r <= #1 1'b0;
	else
	if((tx_dma_en_r & !ep_empty_int))		send_data_r <= #1 1'b1;
	else
	if(rd_next & (sizd_is_zero_d | (ep_empty_int & !sizd_is_zero_d)) )
						send_data_r <= #1 1'b0;

assign send_data = (send_data_r & !ep_empty_r & 
		!(sizd_is_zero & size==9'h01)) | tx_dma_en_r1;

assign mre = (tx_dma_en_r1 | tx_dma_en_r | rd_next) &
		!sizd_is_zero_d & !ep_empty_int & (send_data | tx_dma_en_r1 | tx_dma_en_r);

always @(posedge clk)
	ff_we1 <= mre;

always @(posedge clk)
	ff_we <= ff_we1;

assign ff_re = rd_next;

assign ff_clr = !tx_valid;

///////////////////////////////////////////////////////////////////
//
// IDMA fast prefetch fifo
//

// tx fifo
usb_fifo ff(
	.clk(		clk		),
	.rst(		rst		),
	.clr(		ff_clr		),
	.din(		tx_data_st_i	),
	.we(		ff_we		),
	.dout(		tx_data_st_o	),
	.re(		ff_re		)
	);

endmodule


