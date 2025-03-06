
module pmod_1414 (
		input CLK,      //-- 12 Mhz
		output LEDG_N,  
		output LEDR_N,
		// Data lines 
		output HPDL_D0,
		output HPDL_D1,
		output HPDL_D2,
		output HPDL_D3,
		output HPDL_D4,
		output HPDL_D5,
		output HPDL_D6,
		// Place address line 
		output HPDL_A0,
		output HPDL_A1,
		// Write enable lines 
		output HPDL_WR1,
		output HPDL_WR2,
		output HPDL_WR3,
		output HPDL_WR4,
		// Serial connections 
		output FTDI_TX,
		input FTDI_RX, 
		input BTN_N

);

	// Turn off green LED
	assign LEDG_N = 1'b1; 
	assign LEDR_N = 1'b1;

	assign reset = ~BTN_N;
	
	assign HPDL_D6 = w_data[6];
	assign HPDL_D5 = w_data[5];
	assign HPDL_D4 = w_data[4];
	assign HPDL_D3 = w_data[3];
	assign HPDL_D2 = w_data[2];
	assign HPDL_D1 = w_data[1];
	assign HPDL_D0 = w_data[0];

	// Clear code from serial 
	localparam BKSP = 8'h08;
	localparam DISPLAY_LENGTH = 15;
	
	reg [23:0] r_counter = 0;
	reg [3:0] r_address_counter = 0;
	reg [3:0] r_uart_rx_counter = 0;
	wire [7:0] w_data; 
	wire w_hpdl_clk; 
	wire w_caret_strobe; 
	wire reset;


	// Generate slower clock signals  
	always @(posedge CLK) 
	r_counter <= r_counter + 1;
	
	// Generate slower clock in r_counter and assign and use it for hdpl display 
	assign w_hpdl_clk = r_counter[10];

	// Generate strobe to blink the caret position 
	assign w_caret_strobe = r_counter[22];

	// Count 0 to 15 for 16 display places
	always @(posedge w_hpdl_clk, posedge reset) 
		if (reset == 0)
			r_address_counter <= r_address_counter + 1;
		else 
			r_address_counter <= 0;

	// Character memory, bytes stored from  uart and taken by hpdl module 
	memory mem_strorage(
				.i_clk(CLK),
				.i_write_enable(mem_wen),
				.i_read_enable(1'b1),
				.i_write_address(r_uart_rx_counter),
				.i_write_data(GPout),
				.i_read_address(r_address_counter),
				.i_w_caret_strobe(w_caret_strobe),
				.o_read_data(w_data)
			);
		
	// Set address lines 
	assign HPDL_A0 = !r_address_counter[0];
	assign HPDL_A1 = !r_address_counter[1];
		
	// Generate write signal for each w_data and address combination 
	assign  HPDL_WR1 = (r_address_counter[3] == 0 && r_address_counter[2] == 0 ) ? w_hpdl_clk : 1'b1; 
	assign  HPDL_WR2 = (r_address_counter[3] == 0 && r_address_counter[2] == 1 ) ? w_hpdl_clk : 1'b1;
	assign  HPDL_WR3 = (r_address_counter[3] == 1 && r_address_counter[2] == 0 ) ? w_hpdl_clk : 1'b1;
	assign  HPDL_WR4 = (r_address_counter[3] == 1 && r_address_counter[2] == 1 ) ? w_hpdl_clk : 1'b1;

	// Uart signals and bus 
	wire tx_busy;
	wire RxD_data_ready;
	wire [7:0] RxD_data;
	reg [7:0] GPout;
	
	// Disable memory write when backsp char received
	wire mem_wen;
	assign mem_wen = (RxD_data_ready == 1'b1 && GPout != BKSP) ? 1'b1 : 1'b0;

	// Save a copy of received w_data from uart 
	always @(posedge RxD_data_ready)  GPout <= RxD_data;

	// Receive w_data from uart 
	uart_receiver RX(.clk(CLK), .RxD(FTDI_RX), .RxD_data_ready(RxD_data_ready), .RxD_data(RxD_data));


		
	// Use negative edge to increment address r_counter only after byte is received 
	always @(negedge RxD_data_ready or posedge reset) begin
		// if backspace move cursor back 
		if(reset == 0) begin

		if (GPout == BKSP ) begin
				// Check if first position 
				if (r_uart_rx_counter > 0 )
				r_uart_rx_counter <= r_uart_rx_counter - 1;
		end 	 

		if ((r_uart_rx_counter < DISPLAY_LENGTH) && (GPout != BKSP)) begin 	
			r_uart_rx_counter <= r_uart_rx_counter + 1;
			end
		end else
		r_uart_rx_counter <= 0;
	end
	
	uart_transmitter TX(.clk(CLK), .TxD(FTDI_TX), .TxD_start(RxD_data_ready), .TxD_data(RxD_data), .TxD_busy(tx_busy));

endmodule
