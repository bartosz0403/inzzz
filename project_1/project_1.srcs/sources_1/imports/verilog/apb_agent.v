`timescale  1ns/1ps
`include "usb_defines.v"

module apb_agent (

///-------AMBA signals APB ASSERT--------------//

	PSEL,
	PENABLE,
	PADDR,
	PWRITE, // write / read =====>  1/0
	PWDATA, /// ----- dane zapisywane
///________________AMBA signals APB ASSERT__________________//	
	
   

	///-----OUT SLAVE ASSIGN -------//
	PREADY,
	PRDATA,  /// ------- dane wyjsciowe read
	///_____________OUT SLAVE ASSIGN ___________//
PCLK
     );


//AMBA signals
output reg PSEL;
output reg PENABLE;
output reg [`USB_APB_ADDRESS_WIDTH-1:0] PADDR;
output reg PWRITE;
output reg [`USB_APB_DATA_REGISTER_WIDTH - 1 : 0] PWDATA;
input wire PREADY;
input wire [`USB_APB_DATA_REGISTER_WIDTH - 1 : 0] PRDATA;
input wire PCLK;

reg [`USB_APB_DATA_REGISTER_WIDTH-1:0] data_out;


initial 
begin

//PWDATA <= 0;
  PSEL  <= 1'b1;
    PENABLE <= 1'b1;
PWRITE <= 1'b1;

end

////////////////////////////////////////////////////////////////////////////////
task apb_init;
begin
  PSEL  <= 1'b1;
    PENABLE <= 1'b1;
PWRITE <= 1'b1;
end 
endtask 


////////////////////////////////////////////////////////////////////////////////
task read_char_chk;
input 	expected_data;


reg	[7:0] expected_data;
//reg 	[7:0] data;


begin
data_out <= PRDATA;
	PWRITE <= 1'b0;
   PADDR <= `USB_APB_CTRL_REG_ADDR_DF;
  
   PSEL  <= 1'b1;
    PENABLE <= 1'b1;


/*	fork begin
	

	if (expected_data != data)
	begin
		$display ("Error! Data return is %h, expecting %h", data, expected_data);
		-> error_detected;
	end
	else
		$display ("(%m) Data match  %h", expected_data);

	$display ("... Read Data from UART done cnt :%d...",rx_count +1);
   end
join
*/
end

endtask









////////////////////////////////////////////////////////////////////////////////
task write_char;
input [7:0] data;



begin
	PWRITE <= 1'b1;
   PADDR <= `USB_APB_PERIOD_REG_ADDR_DF;
  
   PSEL  <= 1'b1;
    PENABLE <= 1'b1;

	PWDATA <=   data;
end
endtask


////////////////////////////////////////////////////////////////////////////////
endmodule
