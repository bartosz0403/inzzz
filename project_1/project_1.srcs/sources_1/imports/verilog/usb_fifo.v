

`include "timescale.v"

/////////////////////////////////////////////////////////////////////
////                                                             
////  USB FIFO
////
/////////////////////////////////////////////////////////////////////   



module usb_fifo(clk, rst, clr,  din, we, dout, re);

input		clk, rst;
input		clr;
input   [7:0]	din;
input		we;
output  [7:0]	dout;
input		re;



reg     [7:0]	mem[0:1];
reg		wp;
reg		rp;



always @(posedge clk or negedge rst)
        if(!rst)	wp <= #1 1'h0;
        else
        if(clr)		wp <= #1 1'h0;
        else
        if(we)		wp <= #1 ~wp;

always @(posedge clk or negedge rst)
        if(!rst)	rp <= #1 1'h0;
        else
        if(clr)		rp <= #1 1'h0;
        else
        if(re)		rp <= #1 ~rp;

// Fifo Output
assign  dout = mem[ rp ];

// Fifo Input 
always @(posedge clk)
        if(we)     mem[ wp ] <= #1 din;

endmodule

