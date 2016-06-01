/////////////////////////////////////////////////////////////////////
////                                                             
////  USB  UTMI  
////
/////////////////////////////////////////////////////////////////////

`include "usb_defines.v"

module usb_utmi( // UTMI Interface (EXTERNAL)
		phy_clk, rst,
		DataOut, TxValid, TxReady,
		RxValid, RxActive, RxError, DataIn,

		// Internal Interface
		rx_data, rx_valid, rx_active, rx_err,
		tx_data, tx_valid, tx_valid_last, tx_ready,
		tx_first

		);

input		phy_clk;
input		rst;

output	[7:0]	DataOut;
output		TxValid;
input		TxReady;

input	[7:0]	DataIn;
input		RxValid;
input		RxActive;
input		RxError;


output	[7:0]	rx_data;
output		rx_valid, rx_active, rx_err;
input	[7:0]	tx_data;
input		tx_valid;
input		tx_valid_last;
output		tx_ready;
input		tx_first;

///////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//
reg	[7:0]	rx_data;
reg		rx_valid, rx_active, rx_err;
reg	[7:0]	DataOut;
reg		tx_ready;
reg		TxValid;

///////////////////////////////////////////////////////////////////
//
// Misc Logic
//


///////////////////////////////////////////////////////////////////
//
// RX Interface Input registers
//

always @(posedge phy_clk or negedge rst)
	if(!rst)	rx_valid <= #1 1'b0;
	else		rx_valid <= #1 RxValid;

always @(posedge phy_clk or negedge rst)
	if(!rst)	rx_active <= #1 1'b0;
	else		rx_active <= #1 RxActive;

always @(posedge phy_clk or negedge rst)
	if(!rst)	rx_err <= #1 1'b0;
	else		rx_err <= #1 RxError;

always @(posedge phy_clk)
		rx_data <= #1 DataIn;

///////////////////////////////////////////////////////////////////
//
// TX Interface Output/Input registers
//

always @(posedge phy_clk)
	if(TxReady | tx_first)	DataOut <= #1 tx_data;

always @(posedge phy_clk)
	tx_ready <= #1 TxReady;

always @(posedge phy_clk or negedge rst)
	if(!rst)	TxValid <= #1 1'b0;
	else
	TxValid <= #1 tx_valid | tx_valid_last | (TxValid & !TxReady);

endmodule

