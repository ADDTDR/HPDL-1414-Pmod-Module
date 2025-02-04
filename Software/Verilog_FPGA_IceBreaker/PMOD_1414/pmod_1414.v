
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

);

	// Turn off green LED
	assign LEDG_N = 1'b1; 
	assign LEDR_N = 1'b1;
	
	assign HPDL_D6 = data[6];
	assign HPDL_D5 = data[5];
	assign HPDL_D4 = data[4];
	assign HPDL_D3 = data[3];
	assign HPDL_D2 = data[2];
	assign HPDL_D1 = data[1];
	assign HPDL_D0 = data[0];

	// Clear code from serial 
	parameter BKSP = 8'h08;
	
	reg [23:0] counter = 0;
	reg [3:0] address_counter = 0;
	reg [3:0] uart_rx_counter = 0;
	wire [7:0] data; 
	wire hpdl_clk; 
	wire caret_strobe; 

	// Generate slower clock signals  
	always @(posedge CLK) 
	counter <= counter + 1;
	
	// Generate slower clock in counter and assign and use it for hdpl display 
	assign hpdl_clk = counter[10];

	// Generate strobe to blink the caret position 
	assign caret_strobe = counter[22];

	// Count 0 to 15 for 16 display places
	always @(posedge hpdl_clk) 
		address_counter <= address_counter + 1;
	
	// Character memory, bytes stored from  uart and taken by hpdl module 
	memory mem_strorage(
				.clk(CLK),
				.w_en(mem_wen),
				.r_en(1'b1),
				.w_addr(uart_rx_counter),
				.w_data(GPout),
				.r_addr(address_counter),
				.caret_strobe(caret_strobe),
				.r_data(data)
			);
		
	// Set address lines 
	assign HPDL_A0 = !address_counter[0];
	assign HPDL_A1 = !address_counter[1];
		
	// Generate write signal for each data and address combination 
	assign  HPDL_WR1 = (address_counter[3] == 0 && address_counter[2] == 0 ) ? hpdl_clk : 1'b1; 
	assign  HPDL_WR2 = (address_counter[3] == 0 && address_counter[2] == 1 ) ? hpdl_clk : 1'b1;
	assign  HPDL_WR3 = (address_counter[3] == 1 && address_counter[2] == 0 ) ? hpdl_clk : 1'b1;
	assign  HPDL_WR4 = (address_counter[3] == 1 && address_counter[2] == 1 ) ? hpdl_clk : 1'b1;

	// Uart signals and bus 
	wire tx_busy;
	wire RxD_data_ready;
	wire [7:0] RxD_data;
	reg [7:0] GPout;
	
	// Disable memory write when backsp char received
	wire mem_wen;
	assign mem_wen = (RxD_data_ready == 1'b1 && GPout != BKSP) ? 1'b1 : 1'b0;

	// Save a copy of received data from uart 
	always @(posedge RxD_data_ready)  GPout <= RxD_data;

	// Receive data from uart 
	uart_receiver RX(.clk(CLK), .RxD(FTDI_RX), .RxD_data_ready(RxD_data_ready), .RxD_data(RxD_data));
		
	// Use negative edge to increment address counter only after byte is received 
	always @(negedge RxD_data_ready)begin
		// if backspace move cursor back 
		if (GPout == BKSP ) begin
				// Check if first position 
				if (uart_rx_counter > 0 )
				uart_rx_counter <= uart_rx_counter - 1;
		end 	 

		if ((uart_rx_counter < 15) && (GPout != BKSP)) begin 	
			uart_rx_counter <= uart_rx_counter + 1;
			end
	end
	
	uart_transmitter TX(.clk(CLK), .TxD(FTDI_TX), .TxD_start(RxD_data_ready), .TxD_data(RxD_data), .TxD_busy(tx_busy));

endmodule

////////////////////////////////////////////////////////
//  Memory block for display buffer 
module memory #(
      parameter INIT_FILE = "mem_init.txt"
  )(
      input clk,
      input w_en,
      input r_en,
      input [3:0] w_addr,
      input [3:0] r_addr,
      input [7:0] w_data, 
	  input caret_strobe, 
      output reg [7:0] r_data
  );
	  
	  parameter CARETCHR = 8'h5f;
	  reg [7:0]  mem [0:15];
	  integer i;

      always @(posedge clk) begin
          if (w_en == 1'b1) begin
			if(w_addr >= 15)begin
			  for(i = 15; i > 0; i = i -1 )begin
				mem[i - 1] <= mem[i];	
			  end
			end
            mem[w_addr] <= w_data;   
			// 15 address is used fill data from the right side   
			// mem[15] <= w_data;
          end
          
          if (r_en == 1'b1) begin
			  // Blink recent character position 
			  if (r_addr == w_addr) 
			  	// Replace data with caret using caret strobe signal 
			  	r_data <= (caret_strobe == 1'b1 ) ? mem[r_addr] : CARETCHR;
			  else
              	r_data <= mem[r_addr];
          end
      end

      initial if (INIT_FILE) begin
          $readmemh(INIT_FILE, mem);
      end
    
endmodule


////////////////////////////////////////////////////////
module uart_transmitter (
    input clk, 
    input TxD_start,
    input [7:0] TxD_data,
    output TxD,
    output TxD_busy
);

	parameter ClkFrequency = 12000000;	// 12MHz
	parameter Baud = 115200;

	generate
		if(ClkFrequency<Baud*8 && (ClkFrequency % Baud!=0)) ASSERTION_ERROR PARAMETER_OUT_OF_RANGE("Frequency incompatible with requested Baud rate");
	endgenerate

	////////////////////////////////
	`ifdef SIMULATION
	wire BitTick = 1'b1;  // output one bit per clock cycle
	`else
	wire BitTick;
	BaudTickGen #(ClkFrequency, Baud) tickgen(.clk(clk), .enable(TxD_busy), .tick(BitTick));
	`endif
		
	reg [3:0] TxD_state = 0;
	wire TxD_ready = (TxD_state==0);
	assign TxD_busy = ~TxD_ready;

	reg [7:0] TxD_shift = 0;
	always @(posedge clk)
	begin
		if(TxD_ready & TxD_start)
			TxD_shift <= TxD_data;
		else
		if(TxD_state[3] & BitTick)
			TxD_shift <= (TxD_shift >> 1);

		case(TxD_state)
			4'b0000: if(TxD_start) TxD_state <= 4'b0100;
			4'b0100: if(BitTick) TxD_state <= 4'b1000;  // start bit
			4'b1000: if(BitTick) TxD_state <= 4'b1001;  // bit 0
			4'b1001: if(BitTick) TxD_state <= 4'b1010;  // bit 1
			4'b1010: if(BitTick) TxD_state <= 4'b1011;  // bit 2
			4'b1011: if(BitTick) TxD_state <= 4'b1100;  // bit 3
			4'b1100: if(BitTick) TxD_state <= 4'b1101;  // bit 4
			4'b1101: if(BitTick) TxD_state <= 4'b1110;  // bit 5
			4'b1110: if(BitTick) TxD_state <= 4'b1111;  // bit 6
			4'b1111: if(BitTick) TxD_state <= 4'b0010;  // bit 7
			4'b0010: if(BitTick) TxD_state <= 4'b0000;  // stop 1 
			default: if(BitTick) TxD_state <= 4'b0000;
		endcase
	end

	assign TxD = (TxD_state<4) | (TxD_state[3] & TxD_shift[0]);  // put together the start, data and stop bits

endmodule


////////////////////////////////////////////////////////
module uart_receiver(
	input clk,
	input RxD,
	output reg RxD_data_ready = 0,
	output reg [7:0] RxD_data = 0,  // data received, valid only (for one clock cycle) when RxD_data_ready is asserted

	// We also detect if a gap occurs in the received stream of characters
	// That can be useful if multiple characters are sent in burst
	//  so that multiple characters can be treated as a "packet"
	output RxD_idle,  // asserted when no data has been received for a while
	output reg RxD_endofpacket = 0  // asserted for one clock cycle when a packet has been detected (i.e. RxD_idle is going high)
);

	parameter ClkFrequency = 12000000; // 12MHz
	parameter Baud = 115200;

	parameter Oversampling = 8;  // needs to be a power of 2
	// we oversample the RxD line at a fixed rate to capture each RxD data bit at the "right" time
	// 8 times oversampling by default, use 16 for higher quality reception

	generate
		if(ClkFrequency<Baud*Oversampling) ASSERTION_ERROR PARAMETER_OUT_OF_RANGE("Frequency too low for current Baud rate and oversampling");
		if(Oversampling<8 || ((Oversampling & (Oversampling-1))!=0)) ASSERTION_ERROR PARAMETER_OUT_OF_RANGE("Invalid oversampling value");
	endgenerate

	////////////////////////////////
	reg [3:0] RxD_state = 0;

	`ifdef SIMULATION
	wire RxD_bit = RxD;
	wire sampleNow = 1'b1;  // receive one bit per clock cycle

	`else
	wire OversamplingTick;
	BaudTickGen #(ClkFrequency, Baud, Oversampling) tickgen(.clk(clk), .enable(1'b1), .tick(OversamplingTick));

	// synchronize RxD to our clk domain
	reg [1:0] RxD_sync = 2'b11;
	always @(posedge clk) if(OversamplingTick) RxD_sync <= {RxD_sync[0], RxD};

	// and filter it
	reg [1:0] Filter_cnt = 2'b11;
	reg RxD_bit = 1'b1;

	always @(posedge clk)
	if(OversamplingTick)
	begin
		if(RxD_sync[1]==1'b1 && Filter_cnt!=2'b11) Filter_cnt <= Filter_cnt + 1'd1;
		else 
		if(RxD_sync[1]==1'b0 && Filter_cnt!=2'b00) Filter_cnt <= Filter_cnt - 1'd1;

		if(Filter_cnt==2'b11) RxD_bit <= 1'b1;
		else
		if(Filter_cnt==2'b00) RxD_bit <= 1'b0;
	end

	// and decide when is the good time to sample the RxD line
	function integer log2(input integer v); begin log2=0; while(v>>log2) log2=log2+1; end endfunction
	localparam l2o = log2(Oversampling);
	reg [l2o-2:0] OversamplingCnt = 0;
	always @(posedge clk) if(OversamplingTick) OversamplingCnt <= (RxD_state==0) ? 1'd0 : OversamplingCnt + 1'd1;
	wire sampleNow = OversamplingTick && (OversamplingCnt==Oversampling/2-1);
	`endif

	// now we can accumulate the RxD bits in a shift-register
	always @(posedge clk)
	case(RxD_state)
		4'b0000: if(~RxD_bit) RxD_state <= `ifdef SIMULATION 4'b1000 `else 4'b0001 `endif;  // start bit found?
		4'b0001: if(sampleNow) RxD_state <= 4'b1000;  // sync start bit to sampleNow
		4'b1000: if(sampleNow) RxD_state <= 4'b1001;  // bit 0
		4'b1001: if(sampleNow) RxD_state <= 4'b1010;  // bit 1
		4'b1010: if(sampleNow) RxD_state <= 4'b1011;  // bit 2
		4'b1011: if(sampleNow) RxD_state <= 4'b1100;  // bit 3
		4'b1100: if(sampleNow) RxD_state <= 4'b1101;  // bit 4
		4'b1101: if(sampleNow) RxD_state <= 4'b1110;  // bit 5
		4'b1110: if(sampleNow) RxD_state <= 4'b1111;  // bit 6
		4'b1111: if(sampleNow) RxD_state <= 4'b0010;  // bit 7
		4'b0010: if(sampleNow) RxD_state <= 4'b0000;  // stop bit
		default: RxD_state <= 4'b0000;
	endcase

	always @(posedge clk)
	if(sampleNow && RxD_state[3]) RxD_data <= {RxD_bit, RxD_data[7:1]};

	//reg RxD_data_error = 0;
	always @(posedge clk)
	begin
		RxD_data_ready <= (sampleNow && RxD_state==4'b0010 && RxD_bit);  // make sure a stop bit is received
		//RxD_data_error <= (sampleNow && RxD_state==4'b0010 && ~RxD_bit);  // error if a stop bit is not received
	end

	`ifdef SIMULATION
	assign RxD_idle = 0;
	`else
	reg [l2o+1:0] GapCnt = 0;
	always @(posedge clk) if (RxD_state!=0) GapCnt<=0; else if(OversamplingTick & ~GapCnt[log2(Oversampling)+1]) GapCnt <= GapCnt + 1'h1;
	assign RxD_idle = GapCnt[l2o+1];
	always @(posedge clk) RxD_endofpacket <= OversamplingTick & ~GapCnt[l2o+1] & &GapCnt[l2o:0];
	`endif

endmodule

////////////////////////////////////////////////////////
module BaudTickGen(
	input clk, enable,
	output tick  // generate a tick at the specified baud rate * oversampling
);
parameter ClkFrequency = 12000000;
parameter Baud = 115200;
parameter Oversampling = 1;

function integer log2(input integer v); begin log2=0; while(v>>log2) log2=log2+1; end endfunction
localparam AccWidth = log2(ClkFrequency/Baud)+8;  // +/- 2% max timing error over a byte
reg [AccWidth:0] Acc = 0;
localparam ShiftLimiter = log2(Baud*Oversampling >> (31-AccWidth));  // this makes sure Inc calculation doesn't overflow
localparam Inc = ((Baud*Oversampling << (AccWidth-ShiftLimiter))+(ClkFrequency>>(ShiftLimiter+1)))/(ClkFrequency>>ShiftLimiter);
always @(posedge clk) if(enable) Acc <= Acc[AccWidth-1:0] + Inc[AccWidth:0]; else Acc <= Inc[AccWidth:0];
assign tick = Acc[AccWidth];
endmodule

////////////////////////////////////////////////////////
