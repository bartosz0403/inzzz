/////////////////////////////////////////////////////////////////////
////                                                             
////  USB Protocol Layer
////
/////////////////////////////////////////////////////////////////////
`include "usb_defines.v"
module usb_pl(	clk, rst,

		// UTMI Interface
		rx_data, rx_valid, rx_active, rx_err,
		tx_data, tx_valid, tx_valid_last, tx_ready,
		tx_first, tx_valid_out,



		// Register File Interface
		function_addr, //adress przypisany urzadzeniu 
		ep_sel,  // endpoit dla ktorego  jest transakcja
		x_busy, //flaga wskazujaca na zajetosc rx i tx
		int_crc16_set, 


		// Misc
		frm_nat,  // symer ramki z pakietu SOF

		ctrl_setup, //flaga dla usb_ctrl transakcja setup 
		ctrl_in, //flaga dla usb_ctrl transakcja odczytu z urzadzenia
		 ctrl_out,//flaga dla usb_ctrl transakcja zapisu do urzadzenia


		// EP Interface
		csr,
		tx_data_st, //tx

		rx_ctrl_data_d, 

		idma_re, idma_we,
		ep_empty, ep_full, send_stall

		);

// UTMI Interface
input		clk, rst;
input	[7:0]	rx_data;
input		rx_valid, rx_active, rx_err;
output	[7:0]	tx_data;
output		tx_valid;
output		tx_valid_last;
input		tx_ready;
output		tx_first;
input		tx_valid_out;



// Register File interface
input	[6:0]	function_addr;		// Function Address (as set by the controller)
output	[3:0]	ep_sel;		// Endpoint Number Input
output		x_busy;		// Indicates USB is busy

output		int_crc16_set;	// Set CRC16 error interrupt

output	[31:0]	frm_nat;

output		ctrl_setup;
output		ctrl_in;
output		ctrl_out;

// Endpoint Interfaces
input	[13:0]	csr;	
input	[7:0]	tx_data_st;

output	[7:0]	rx_ctrl_data_d;

output		idma_re, idma_we;
input		ep_empty;
input		ep_full;

input		send_stall;

///////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//

// Packet Disassembler Interface
wire		clk, rst;
wire	[7:0]	rx_data;
wire		pid_OUT, pid_IN, pid_SOF, pid_SETUP;
wire		pid_DATA0, pid_DATA1, pid_DATA2, pid_MDATA;
wire		pid_ACK, pid_NACK, pid_STALL, pid_NYET;
wire		pid_PRE, pid_ERR, pid_SPLIT, pid_PING;
wire	[6:0]	token_fadr;
wire		token_valid;
wire		crc5_err;
wire	[10:0]	frame_no;
wire	[7:0]	rx_ctrl_data;
reg	[7:0]	rx_ctrl_data_d;
wire		rx_ctrl_dvalid;
wire		rx_ctrl_ddone;
wire		crc16_err;
//wire		rx_seq_err;

// Packet Assembler Interface
wire		send_token;
wire	[1:0]	token_pid_sel;
wire		send_data;
wire	[1:0]	data_pid_sel;
wire	[7:0]	tx_data_st;
wire	[7:0]	tx_data_st_o;
wire		rd_next;

// IDMA Interface
wire		rx_dma_en;	// Allows the data to be stored
wire		tx_dma_en;	// Allows for data to be retrieved
wire		abort;		// Abort Transfer (time_out, crc_err or rx_error)
wire		idma_done;	// DMA is done

// Memory Arbiter Interface
wire		idma_we;
wire		idma_re;

// Local signals
wire		pid_bad;

reg		hms_clk;	// 0.5 Micro Second Clock
reg	[4:0]	hms_cnt;
reg	[10:0]	frame_no_r;	// Current Frame Number register
wire		frame_no_we;
reg	[11:0]	sof_time;	// Time since last sof
reg		clr_sof_time;
wire		fsel;		// This Function is selected
wire		match_o;

reg		frame_no_we_r;
reg		ctrl_setup;
reg		ctrl_in;
reg		ctrl_out;

wire		idma_we_d;
wire		ep_empty_int;
wire		rx_busy;
wire		tx_busy;

///////////////////////////////////////////////////////////////////
//
// Misc Logic
//

assign x_busy = tx_busy | rx_busy;

// PIDs we should never receive
assign pid_bad = pid_ACK | pid_NACK | pid_STALL | pid_NYET | pid_PRE |
			pid_ERR | pid_SPLIT |  pid_PING;

assign match_o = !pid_bad & token_valid & !crc5_err;

// Receiving Setup
always @(posedge clk)
	ctrl_setup <= #1 token_valid & pid_SETUP & (ep_sel==4'h0);

always @(posedge clk)
	ctrl_in <= #1 token_valid & pid_IN ;//&(ep_sel==4'h0);

always @(posedge clk)
	ctrl_out <=  token_valid & pid_OUT ;//& (ep_sel==4'h0);

// Frame Number (from SOF token)
assign frame_no_we = token_valid & !crc5_err & pid_SOF;

always @(posedge clk)
	frame_no_we_r <= #1 frame_no_we;

always @(posedge clk or negedge rst)
	if(!rst)		frame_no_r <= #1 11'h0;
	else
	if(frame_no_we_r)	frame_no_r <= #1 frame_no;

//SOF delay counter
always @(posedge clk)
	clr_sof_time <= #1 frame_no_we;

always @(posedge clk)
	if(clr_sof_time)	sof_time <= #1 12'h0;
	else
	if(hms_clk)		sof_time <= #1 sof_time + 12'h1;

assign frm_nat = {4'h0, 1'b0, frame_no_r, 4'h0, sof_time};

// 0.5 Micro Seconds Clock Generator
always @(posedge clk or negedge rst)
	if(!rst)				hms_cnt <= #1 5'h0;
	else
	if(hms_clk | frame_no_we_r)		hms_cnt <= #1 5'h0;
	else					hms_cnt <= #1 hms_cnt + 5'h1;

always @(posedge clk)
	hms_clk <= #1 (hms_cnt == `USBF_HMS_DEL);

always @(posedge clk)
	rx_ctrl_data_d <= rx_ctrl_data;

///////////////////////////////////////////////////////////////////

// This function is addressed
assign fsel = (token_fadr == function_addr);

// Only write when we are addressed !!!
assign idma_we = idma_we_d & fsel; // moved full check to idma ...  & !ep_full;

///////////////////////////////////////////////////////////////////
//
// Module Instantiations
//

//Packet Decoder
usb_pd	u_pd(	.clk(		clk		),
		.rst(		rst		),

		.rx_data(	rx_data		),
		.rx_valid(	rx_valid	),
		.rx_active(	rx_active	),
		.rx_err(	rx_err		),
		.pid_OUT(	pid_OUT		),
		.pid_IN(	pid_IN		),
		.pid_SOF(	pid_SOF		),
		.pid_SETUP(	pid_SETUP	),
		.pid_DATA0(	pid_DATA0	),
		.pid_DATA1(	pid_DATA1	),
		.pid_DATA2(	pid_DATA2	),
		.pid_MDATA(	pid_MDATA	),
		.pid_ACK(	pid_ACK		),
		.pid_NACK(	pid_NACK	),
		.pid_STALL(	pid_STALL	),
		.pid_NYET(	pid_NYET	),
		.pid_PRE(	pid_PRE		),
		.pid_ERR(	pid_ERR		),
		.pid_SPLIT(	pid_SPLIT	),
		.pid_PING(	pid_PING	),
		.pid_cks_err(	pid_cs_err	),
		.token_fadr(	token_fadr	),
		.token_endp(	ep_sel		),
		.token_valid(	token_valid	),
		.crc5_err(	crc5_err	),
		.frame_no(	frame_no	),
		.rx_data_out(	rx_ctrl_data	),
		.rx_data_valid(	rx_ctrl_dvalid	),
		.rx_data_done(	rx_ctrl_ddone	),
		.crc16_err(	crc16_err	),

		.rx_busy(	rx_busy		)
		);

// Packet Assembler
usb_pa	U_pa(	.clk(		clk		),
		.rst(		rst		),
		.tx_data(	tx_data		),
		.tx_valid(	tx_valid	),
		.tx_valid_last(	tx_valid_last	),
		.tx_ready(	tx_ready	),
		.tx_first(	tx_first	),
		.send_token(	send_token	),
		.token_pid_sel(	token_pid_sel	),
		.send_data(	send_data	),
		.data_pid_sel(	data_pid_sel	),
		.tx_data_st(	tx_data_st_o	),
		.rd_next(	rd_next		),
		.ep_empty(	ep_empty_int)
		);

// Internal DMA / Memory Arbiter Interface
usb_dma
	u_dma(	.clk(		clk		),
		.rst(		rst		),

		.tx_valid(	tx_valid	),
		.rx_data_valid(	rx_ctrl_dvalid	),
		.rx_data_done(	rx_ctrl_ddone	),
		.send_data(	send_data	),
		.rd_next(	rd_next		),

		.tx_data_st_i(	tx_data_st	),
		.tx_data_st_o(	tx_data_st_o	),


		.tx_busy(	tx_busy		),

		.tx_dma_en(	tx_dma_en	),
		.rx_dma_en(	rx_dma_en	),
		.idma_done(	idma_done	),
		.size(		csr[8:0]	),
		.rx_cnt(	rx_size		),
		.rx_done(	rx_done		),
		.mwe(		idma_we_d	),
		.mre(		idma_re		),
		.ep_empty(	ep_empty	),
		.ep_empty_int(	ep_empty_int	),
		.ep_full(	ep_full		)
		);

// Protocol Engine
usb_pe	u_pe(	.clk(			clk			),
		.rst(			rst			),

		.tx_valid_i(		tx_valid_out		),
		.rx_active_i(		rx_active		),
		.pid_OUT(		pid_OUT			),
		.pid_IN(		pid_IN			),
		.pid_SOF(		pid_SOF			),
		.pid_SETUP(		pid_SETUP		),
		.pid_DATA0(		pid_DATA0		),
		.pid_DATA1(		pid_DATA1		),
		.pid_DATA2(		pid_DATA2		),
		.pid_MDATA(		pid_MDATA		),
		.pid_ACK(		pid_ACK			),
		.pid_PING(		pid_PING		),
		.token_valid_i(		token_valid		),
		.rx_data_done_i(		rx_ctrl_ddone		),

		.crc16_err_i(		crc16_err		),
		.send_token_o(		send_token		),
		.token_pid_sel_o(		token_pid_sel		),
		.data_pid_sel_o(		data_pid_sel		),
		.rx_dma_en_o(		rx_dma_en		),
		.tx_dma_en_o(		tx_dma_en		),

		.idma_done_o(		idma_done		),
		.fsel_i(			fsel			),
		.ep_sel_i(		ep_sel			),
		.ep_full_i(		ep_full			),
		.ep_empty_i(		ep_empty		),
		.match_i(			match_o			),
		.nse_err_o(		nse_err			),

		.int_crc16_set_o(		int_crc16_set		),
		.int_to_set_o(		int_to_set		),
		.int_seqerr_set_o(	int_seqerr_set		),
		.csr_i(			csr			),
		.send_stall_i(		send_stall		)
		);

endmodule

