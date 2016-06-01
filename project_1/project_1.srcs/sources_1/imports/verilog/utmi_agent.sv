`timescale  1ns/1ps

module utmi_agent (
utmi_interface UTMI

)
	;

endmodule

module TestRAM;
  utmi_interface UTMI();                   // Instance the interface
  
  utmi_agent AGENT (.UTMI(UTMI));   // Connect it


endmodule


interface utmi_interface;
logic	[7:0]	DataOut;
logic		TxValid;
logic		TxReady;
logic	[7:0]	DataIn;
logic		RxValid;
logic		RxActive;
logic		RxError;
logic	[1:0]	LineState;
endinterface
