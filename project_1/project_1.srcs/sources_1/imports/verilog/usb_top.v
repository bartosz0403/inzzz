
`include "usb_defines.v"
/////////////////////////////////////////////////////////////////////
////                                                             
////  USB DEVICE TOP
////
/////////////////////////////////////////////////////////////////////   
module usb_top(
        clk_i, 
        rst_i,

      


        usb_rst,



        // 
        usb_busy, 
        ep_sel,

        // 
      ep1_cfg,
    //    ep1_din,  
        ep1_we, 
        ep1_full,
        ep1_dout, 
        ep1_re, 
        ep1_empty,
        ep1_bf_en, 
        ep1_bf_size,

        ep2_cfg,
        ep2_din,  
        ep2_we, 
        ep2_full,
        ep2_dout, 
        ep2_re, 
        ep2_empty,
        ep2_bf_en, 
        ep2_bf_size,

        ep3_cfg,
        ep3_din,  
        ep3_we, 
        ep3_full,
        ep3_dout, 
        ep3_re, 
        ep3_empty,
        ep3_bf_en, 
        ep3_bf_size,

        ep4_cfg,
        ep4_din,  
        ep4_we, 
        ep4_full,
        ep4_dout, 
        ep4_re, 
        ep4_empty,
        ep4_bf_en, 
        ep4_bf_size,

        ep5_cfg,
        ep5_din,  
        ep5_we, 
        ep5_full,
        ep5_dout, 
        ep5_re, 
        ep5_empty,
        ep5_bf_en, 
        ep5_bf_size,

        ep6_cfg,
        ep6_din,  
        ep6_we, ep6_full,
        ep6_dout, ep6_re, ep6_empty,
        ep6_bf_en, ep6_bf_size,

        ep7_cfg,
        ep7_din,  ep7_we, ep7_full,
        ep7_dout, ep7_re, ep7_empty,
        ep7_bf_en, ep7_bf_size,
      
   

//AMBA

//	PCLK,
//	PRESETn,
///-------AMBA signals APB ASSERT--------------//
	PSEL,
	PENABLE,
	PADDR,
	PWRITE, // write / read =====>  1/0
	PWDATA, /// ----- dane zapisywane
///________________AMBA signals APB ASSERT__________________//	



	///-----OUT SLAVE ASSIGN -------//
	PREADY,
	PRDATA,



		// UTMI Interface
		DataOut, TxValid, TxReady, RxValid,
		RxActive, RxError, DataIn, LineState,

        );      
//-----------------//
 //AMBA       
//-----------------//


//AMBA signals
input wire PSEL;
input wire PENABLE;
input wire [`USB_APB_ADDRESS_WIDTH-1:0] PADDR;
input wire PWRITE;
input wire [`USB_APB_DATA_REGISTER_WIDTH - 1 : 0] PWDATA;
output wire PREADY;
output reg [`USB_APB_DATA_REGISTER_WIDTH - 1 : 0] PRDATA;

        
        
        

input       clk_i;
input       rst_i;



output      usb_rst;
/*
output          v_set_int;
output          v_set_feature;
output  [15:0]  wValue;
output  [15:0]  wIndex;
input   [15:0]  vendor_data;
*/
output      usb_busy;
output  [3:0]   ep_sel;

// Endpoint Interfaces
input   [13:0]  ep1_cfg;
//input   [7:0]   ep1_din;
output  [7:0]   ep1_dout;
output      ep1_we, ep1_re;
input       ep1_empty, ep1_full;
input       ep1_bf_en;
input   [6:0]   ep1_bf_size;

input   [13:0]  ep2_cfg;
input   [7:0]   ep2_din;
output  [7:0]   ep2_dout;
output      ep2_we, ep2_re;
input       ep2_empty, ep2_full;
input       ep2_bf_en;
input   [6:0]   ep2_bf_size;

input   [13:0]  ep3_cfg;
input   [7:0]   ep3_din;
output  [7:0]   ep3_dout;
output      ep3_we, ep3_re;
input       ep3_empty, ep3_full;
input       ep3_bf_en;
input   [6:0]   ep3_bf_size;

input   [13:0]  ep4_cfg;
input   [7:0]   ep4_din;
output  [7:0]   ep4_dout;
output      ep4_we, ep4_re;
input       ep4_empty, ep4_full;
input       ep4_bf_en;
input   [6:0]   ep4_bf_size;

input   [13:0]  ep5_cfg;
input   [7:0]   ep5_din;
output  [7:0]   ep5_dout;
output      ep5_we, ep5_re;
input       ep5_empty, ep5_full;
input       ep5_bf_en;
input   [6:0]   ep5_bf_size;

input   [13:0]  ep6_cfg;
input   [7:0]   ep6_din;
output  [7:0]   ep6_dout;
output      ep6_we, ep6_re;
input       ep6_empty, ep6_full;
input       ep6_bf_en;
input   [6:0]   ep6_bf_size;

input   [13:0]  ep7_cfg;
input   [7:0]   ep7_din;
output  [7:0]   ep7_dout;
output      ep7_we, ep7_re;
input       ep7_empty, ep7_full;
input       ep7_bf_en;
input   [6:0]   ep7_bf_size;
//-----------------------
//-AMBA APB
//----------------------

wire   [13:0]  ep1_cfg;
wire    [7:0]   ep1_din;
wire   [7:0]   ep1_dout;
wire       ep1_we, ep1_re;
wire        ep1_empty, ep1_full;
wire        ep1_bf_en;
wire    [6:0]   ep1_bf_size;










//------------------------------------
// UTMI Interface
// -----------------------------------

output	[7:0]	DataOut;
output		TxValid;
input		TxReady;
input	[7:0]	DataIn;
input		RxValid;
input		RxActive;
input		RxError;
input	[1:0]	LineState;

wire    [7:0]   DataOut;
wire        TxValid;
wire        TxReady;
wire    [7:0]   DataIn;
wire        RxValid;
wire        RxActive;
wire        RxError;
wire    [1:0]   LineState;
wire        clk;
wire        rst;

wire        usb_rst;
reg   [7:0]   ep1_din_d;



usb_core  u_usb_core(
                    .clk_i              ( clk_i             ), 
                    .rst_i              ( rst_i             ),


              
                   
                    .usb_rst            ( usb_rst           ), 

                                        // UTMI 
                    .DataIn             ( DataIn            ),
                    .RxValid            ( RxValid           ),
                    .RxActive           ( RxActive          ),
                    .RxError            ( RxError           ),
                    .DataOut            ( DataOut           ),
                    .TxValid            ( TxValid           ),
                    .TxReady            ( TxReady           ),
                    .LineState          ( LineState         ),

                    .usb_busy           ( usb_busy          ), 
                    .ep_sel             ( ep_sel            ),

        // Endpoint
                    .ep1_cfg            ( ep1_cfg           ),
                    .ep1_din            ( ep1_din           ),  
                    .ep1_we             ( ep1_we            ), 
                    .ep1_full           ( ep1_full          ),
                    .ep1_dout           ( ep1_dout          ), 
                    .ep1_re             ( ep1_re            ), 
                    .ep1_empty          ( ep1_empty         ),
                    .ep1_bf_en          ( ep1_bf_en         ), 
                    .ep1_bf_size        ( ep1_bf_size       ),

                    .ep2_cfg            ( ep2_cfg           ),
                    .ep2_din            ( ep2_din           ),  
                    .ep2_we             ( ep2_we            ), 
                    .ep2_full           ( ep2_full          ),
                    .ep2_dout           ( ep2_dout          ), 
                    .ep2_re             ( ep2_re            ), 
                    .ep2_empty          ( ep2_empty         ),
                    .ep2_bf_en          ( ep2_bf_en         ), 
                    .ep2_bf_size        ( ep2_bf_size       ),

                    .ep3_cfg            ( ep3_cfg           ),
                    .ep3_din            ( ep3_din           ),  
                    .ep3_we             ( ep3_we            ), 
                    .ep3_full           ( ep3_full          ),
                    .ep3_dout           ( ep3_dout          ), 
                    .ep3_re             ( ep3_re            ), 
                    .ep3_empty          ( ep3_empty         ),
                    .ep3_bf_en          ( ep3_bf_en         ), 
                    .ep3_bf_size        ( ep3_bf_size       ),

                    .ep4_cfg            ( ep4_cfg           ),
                    .ep4_din            ( ep4_din           ),  
                    .ep4_we             ( ep4_we            ), 
                    .ep4_full           ( ep4_full          ),
                    .ep4_dout           ( ep4_dout          ), 
                    .ep4_re             ( ep4_re            ), 
                    .ep4_empty          ( ep4_empty         ),
                    .ep4_bf_en          ( ep4_bf_en         ), 
                    .ep4_bf_size        ( ep4_bf_size       ),

                    .ep5_cfg            ( ep5_cfg           ),
                    .ep5_din            ( ep5_din           ),  
                    .ep5_we             ( ep5_we            ), 
                    .ep5_full           ( ep5_full          ),
                    .ep5_dout           ( ep5_dout          ), 
                    .ep5_re             ( ep5_re            ), 
                    .ep5_empty          ( ep5_empty         ),
                    .ep5_bf_en          ( ep5_bf_en         ), 
                    .ep5_bf_size        ( ep5_bf_size       ),

                    .ep6_cfg            ( ep6_cfg           ),
                    .ep6_din            ( ep6_din           ),  
                    .ep6_we             ( ep6_we            ), 
                    .ep6_full           ( ep6_full          ),
                    .ep6_dout           ( ep6_dout          ), 
                    .ep6_re             ( ep6_re            ), 
                    .ep6_empty          ( ep6_empty         ),
                    .ep6_bf_en          ( ep6_bf_en         ), 
                    .ep6_bf_size        ( ep6_bf_size       ),

                    .ep7_cfg            ( ep7_cfg           ),
                    .ep7_din            ( ep7_din           ),  
                    .ep7_we             ( ep7_we            ), 
                    .ep7_full           ( ep7_full          ),
                    .ep7_dout           ( ep7_dout          ), 
                    .ep7_re             ( ep7_re            ), 
                    .ep7_empty          ( ep7_empty         ),
                    .ep7_bf_en          ( ep7_bf_en         ), 
                    .ep7_bf_size        ( ep7_bf_size       )


        );      


usb_apb u_usb_apb

     (  			
                    .ep1_din            ( ep1_din           ),  
                    .ep1_we             ( ep1_we            ), 
                    .ep1_full           ( ep1_full          ),
                    .ep1_dout           ( ep1_dout          ), 
                    .ep1_re             ( ep1_re            ), 
                    .ep1_empty          ( ep1_empty         ),






     
     
	  	.PCLK(clk_i),
			.PRESETn(rst_i),
			.PSEL(PSEL),
			.PWRITE(PWRITE),
			.PENABLE(PENABLE),
			.PADDR(PADDR),
			.PREADY(PREADY),
	//	.PSLVERR(),
       // Line Interface
       	.PWDATA(PWDATA)


      	
      	
      	
    
     );




endmodule
