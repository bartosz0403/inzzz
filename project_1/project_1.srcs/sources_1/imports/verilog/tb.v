
`timescale 1ns/10ps

`include "usb_defines.v"
module tb;


wire  usb_txoe,usb_txdp,usb_txdn;

reg [31:0]  SetupDataLen;
reg [15:0]  Crc16ErrMask; 
       	
wire    [7:0]   DataOut;
wire      TxValid;
reg     TxReady;
reg     [7:0]   DataIn;
reg         RxValid;
reg        RxActive;
reg        RxError;
wire     [1:0]   LineState;

reg [7:0]   rx_buffer            [0 : 10];
reg [7:0]   rx_buffer_tmp            [0 : 10];
        ;
parameter M16 = 16'h8005; //mask value to calculate 16 bit crc
parameter M05 = 8'h05;    //mask value to calculate 5 bit crc


reg [11:0]  buf_pointer;

parameter OUT_TOKEN           = 4'b0001,
          IN_TOKEN            = 4'b1001,
          SOF_TOKEN           = 4'b0101,
          SETUP_TOKEN         = 4'b1101,
          DATA0               = 4'b0011,
          DATA1               = 4'b1011,
          ACK                 = 4'b0010,
          NAK                 = 4'b1010,
          STALL               = 4'b1110,
          PREAMBLE            = 4'b1100;






wire        clk;
wire        rst;
wire        phy_tx_mode;
wire        usb_rst;
reg   [7:0]   ep1_din_d;


integer tmpCounter;

wire PSEL;
wire PENABLE;
wire[`USB_APB_ADDRESS_WIDTH-1:0] PADDR;
wire PWRITE;
wire [`USB_APB_DATA_REGISTER_WIDTH - 1 : 0] PWDATA;
wire PREADY;
wire [`USB_APB_DATA_REGISTER_WIDTH - 1 : 0] PRDATA;
/*
//AMBA signals
reg PSEL;
reg PENABLE;
reg[`USB_APB_ADDRESS_WIDTH-1:0] PADDR;
reg PWRITE;
reg [`USB_APB_DATA_REGISTER_WIDTH - 1 : 0] PWDATA;
wire PREADY;
wire [`USB_APB_DATA_REGISTER_WIDTH - 1 : 0] PRDATA;
*/
parameter  SYS_BP_PER = 2.5;       
parameter  USB_BP_PER = 10.4167;       
reg sys_clk,resetn;
reg usb_48mhz_clk;
wire  [3:0]   ep_sel;



    

always begin
     #SYS_BP_PER     sys_clk <= 1'b0;
     #SYS_BP_PER     sys_clk <= 1'b1;
end

always begin
     #USB_BP_PER     usb_48mhz_clk <= 1'b0;
     #USB_BP_PER   usb_48mhz_clk <= 1'b1;
end

	

task sendRxActive ;
input [31:0] i;
begin
#250
RxActive <= 1'b1;
 #(i*40*USB_BP_PER)	  RxActive <= 1'b0;
 
end

endtask

task delay;
input [16:0] i;
begin

 #(i*2*USB_BP_PER);
 
end
endtask

usb_top dut(
	.clk_i      (usb_48mhz_clk), 
	.rst_i      (resetn),


        .usb_rst(),

	// USB Status
	.usb_busy(), 
	.ep_sel(ep_sel),

	// End point 1 configuration
	.ep1_cfg(	`ISO  | `IN  | 14'd0256		),
	// End point 1 'OUT' FIFO i/f
	.ep1_dout(					),
	.ep1_we(					),
	.ep1_full(		1'b0			),
	// End point 1 'IN' FIFO i/f
	//.ep1_din(		8'h0		        ),
	.ep1_re(		   		        ),
	.ep1_empty(		1'b0     		),
	.ep1_bf_en(		1'b0			),
	.ep1_bf_size(		7'h0			),
	// End point 2 configuration
	.ep2_cfg(	`ISO  | `OUT | 14'd0256		),
	// End point 2 'OUT' FIFO i/f
	.ep2_dout(				        ),
	.ep2_we(				        ),
	.ep2_full(		1'b0     		),
	// End point 2 'IN' FIFO i/f
	.ep2_din(		8'h0			),
	.ep2_re(					),
	.ep2_empty(		1'b0			),
	.ep2_bf_en(		1'b0			),
	.ep2_bf_size(		7'h0			),

	// End point 3 configuration
	.ep3_cfg(	`BULK | `IN  | 14'd064		),
	// End point 3 'OUT' FIFO i/f
	.ep3_dout(					),
	.ep3_we(					),
	.ep3_full(		1'b0			),
	// End point 3 'IN' FIFO i/f
	.ep3_din(		8'h0      		),
	.ep3_re(		        		),
	.ep3_empty(		1'b0    		),
	.ep3_bf_en(		1'b0			),
	.ep3_bf_size(		7'h0			),

	// End point 4 configuration
	.ep4_cfg(	`BULK | `OUT | 14'd064		),
	// End point 4 'OUT' FIFO i/f
	.ep4_dout(		        		),
	.ep4_we(		        		),
	.ep4_full(		1'b0     		),
	// End point 4 'IN' FIFO i/f
	.ep4_din(		8'h0			),
	.ep4_re(					),
	.ep4_empty(		1'b0			),
	.ep4_bf_en(		1'b0			),
	.ep4_bf_size(		7'h0			),

	// End point 5 configuration
	.ep5_cfg(	`INT  | `IN  | 14'd064		),
	// End point 5 'OUT' FIFO i/f
	.ep5_dout(					),
	.ep5_we(					),
	.ep5_full(		1'b0			),
	// End point 5 'IN' FIFO i/f
	.ep5_din(		8'h0     		),
	.ep5_re(				        ),
	.ep5_empty(		1'b0     		),
	.ep5_bf_en(		1'b0			),
	.ep5_bf_size(		7'h0			),

	// End point 6 configuration
	.ep6_cfg(		14'h00			),
	// End point 6 'OUT' FIFO i/f
	.ep6_dout(					),
	.ep6_we(					),
	.ep6_full(		1'b0			),
	// End point 6 'IN' FIFO i/f
	.ep6_din(		8'h0			),
	.ep6_re(					),
	.ep6_empty(		1'b0			),
	.ep6_bf_en(		1'b0			),
	.ep6_bf_size(		7'h0			),

	// End point 7 configuration
	.ep7_cfg(		14'h00			),
	// End point 7 'OUT' FIFO i/f
	.ep7_dout(					),
	.ep7_we(					),
	.ep7_full(		1'b0			),
	// End point 7 'IN' FIFO i/f
	.ep7_din(		8'h0			),
	.ep7_re(					),
	.ep7_empty(		1'b0			),
	.ep7_bf_en(		1'b0			),
	.ep7_bf_size(		7'h0			),



	.PSEL(PSEL),
	.PWRITE(PWRITE),
	.PENABLE(PENABLE),
	.PADDR(PADDR),
	.PWDATA(PWDATA),// dane 
       	
    // slave assert   	
     .PREADY(PREADY),
	 .PRDATA(PRDATA), // dane


        // UTMI Interface
                    .DataIn           ( DataIn            ),
                    .RxValid          ( RxValid           ),
                    .RxActive         ( RxActive          ),
                    .RxError         ( RxError           ),
                    .DataOut          ( DataOut           ),
                    .TxValid          ( TxValid           ),
                    .TxReady          ( TxReady           ),
                    .LineState        ( LineState         )
       	

	); 		




     
     
 
 
apb_agent u_apb_agent(

///-------AMBA signals APB ASSERT--------------//
    .PSEL(PSEL),
	.PWRITE(PWRITE),
	.PENABLE(PENABLE),
	.PADDR(PADDR),
	.PWDATA(PWDATA),// dane 
       	
    // slave assert   	
     .PREADY(PREADY),
	 .PRDATA(PRDATA), // dane
	///_____________OUT SLAVE ASSIGN ___________//
.PCLK(usb_48mhz_clk)
     );







task SetTxReady;
input [31:0] i;
integer counter;
begin
#30;
   for(counter = 0; counter < i ; counter = counter + 1) begin
 	    #(36*USB_BP_PER) TxReady <= 1'b1;
		#(2*USB_BP_PER)  TxReady <= 1'b0;
    end
  
end
endtask



task SetRxValid;

begin
		RxValid <= 1'b1;
		#(2*USB_BP_PER)  RxValid <= 1'b0;
end
endtask

task sendRxValid ;
input [31:0] i;
integer counter;
begin
#30;
   for(counter = 0; counter < i ; counter = counter + 1) begin
  #(38*USB_BP_PER)   SetRxValid;
    end
  
end
endtask



task sendBuffor ;
input [31:0] i;
begin


   for(tmpCounter = 0; tmpCounter < i ; tmpCounter = tmpCounter + 1) begin
   #(38*USB_BP_PER)  DataIn <= rx_buffer[tmpCounter];
    end

end
endtask






task SendData;
input  [3:0]    token;
input [31:0] numbytes;
   
   integer      i;
   reg   [15:0] tmpcrc;
  
begin



   rx_buffer[0] = {~token, token};



   tmpcrc = 16'hffff;;
for (i = 1; i <= SetupDataLen; i = i + 1) begin 
        rx_buffer[i] = rx_buffer_tmp[i-1];
    tmpcrc = crc16(rx_buffer[i], tmpcrc);
end
   if(numbytes > 0) begin
      rx_buffer[numbytes+1] = ~swap8(tmpcrc[15:8]);
      rx_buffer[numbytes+2] = ~swap8(tmpcrc[7:0]);
   end
   else begin
      rx_buffer[numbytes+1] = 8'b0000_0000;
      rx_buffer[numbytes+2] = 8'b0000_0000;
   end
fork
begin
sendRxValid(numbytes+3);
  delay(5);
SetTxReady(1);
end
sendBuffor(numbytes+3);
sendRxActive(numbytes+3);


join

end
endtask





task SendAddress;
  input [6:0] address;
begin
    rx_buffer_tmp[0] = 8'b0000_0000;
    rx_buffer_tmp[1] = 8'b0000_0101; // SetAddress rozkaz SET_ADDRESS 05h
    rx_buffer_tmp[2] = {1'b0, address};
    rx_buffer_tmp[3] = 8'b0000_0000;
    rx_buffer_tmp[4] = 8'b0000_0000;
    rx_buffer_tmp[5] = 8'b0000_0000;
    rx_buffer_tmp[6] = 8'b0000_0000;
    rx_buffer_tmp[7] = 8'b0000_0000;
    
    SendData(DATA0,8);
end
endtask


function [7:0] swap8;
input    [7:0] SwapByte;
begin
swap8 = {SwapByte[0], SwapByte[1], SwapByte[2], SwapByte[3], SwapByte[4], SwapByte[5], SwapByte[6], SwapByte[7]};
end
endfunction



function [15:0] crc16;
input    [7:0]  DataByte;
input    [15:0] PrevCrc;

reg      [15:0] TempPrevCrc;
integer         i;

begin
    TempPrevCrc = PrevCrc;
    for (i = 0; i < 8; i = i + 1)
    begin
        if (DataByte[i] ^ TempPrevCrc[15] )
            TempPrevCrc = {TempPrevCrc[14:0],1'b0} ^ M16;
        else
            TempPrevCrc = {TempPrevCrc[14:0], 1'b0};
    end
    crc16 = TempPrevCrc;
end
      
endfunction


function [15:0] FillCrc5;
input  [10:0] InVal;
reg    [15:0] tmpReg;
begin
tmpReg[10:0] =  InVal;     // put address and EndPt into consecutive bits
tmpReg[15:11] = crc5(InVal, 5'b11111); // calculate crc5 for the first 8 bits

tmpReg[15:11] ={tmpReg[11], tmpReg[12], tmpReg[13], tmpReg[14], tmpReg[15]};
tmpReg[6:0] = InVal[6:0];   // address
tmpReg[10:7] = InVal[10:7]; // End Point
tmpReg[15:11] = ~tmpReg[15:11];
                                               

FillCrc5 = tmpReg;
end
endfunction






function [4:0] crc5;
input    [10:0] DataByte;
input    [4:0] PrevCrc;

reg      [4:0] TempPrevCrc;
integer        i;
begin
    TempPrevCrc = PrevCrc;
    for (i = 0; i < 11; i = i + 1)
    begin
        if (DataByte[i] ^ TempPrevCrc[4] )
            TempPrevCrc = {TempPrevCrc[3:0],1'b0} ^ M05;
        else
            TempPrevCrc = {TempPrevCrc[3:0], 1'b0};
    end
    crc5 = TempPrevCrc[4:0];
end
endfunction

task SendToken;
input  [3:0]    token;
input     [6:0]    address;
input     [3:0]    EndPt;
reg       [15:0]   tmpReg;
begin

    rx_buffer[0]  = {~token, token};
    tmpReg[15:0]   = FillCrc5({EndPt, address});
    rx_buffer[1]  = tmpReg[7:0];
   rx_buffer[2]  = tmpReg[15:8];
 
fork
sendRxValid(3);
sendBuffor(3);
sendRxActive(3);
join




end
endtask


task SendHandshake;
input  [3:0]    token;

begin

    rx_buffer[0]  = {~token, token};

fork
sendRxValid(1);
sendBuffor(1);
sendRxActive(1);
join




end
endtask

initial
begin
    Crc16ErrMask   = 16'hffff;
    
SetupDataLen = 8;
#100 
	resetn = 1;
	#100 resetn = 0;
	#200 resetn = 1;
	RxError <= 1'b0;
	TxReady <= 1'b0;
	#3000
	test_1;

#400
//	usb_test1;

	$finish;
end

task test_1;


begin


	SendToken(SETUP_TOKEN,7'h00, 4'h0);
	delay(100);
	SendAddress(7'b111_1111);
	delay(100);
	SendToken(IN_TOKEN,7'h00, 4'h0);
	SetTxReady(3);
   	delay(1000);

   	
   	SendToken(IN_TOKEN,7'b111_1111, 4'h1);
fork
  tb.u_apb_agent.write_char (8'b11000000);
 
	SetTxReady(4);
join	
	fork
  tb.u_apb_agent.write_char (8'b11000110);
 
	SetTxReady(4);
join	

 	delay(1000);

end
endtask

endmodule
