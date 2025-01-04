
module pmod_1414 (
	input CLK,      //-- 12 Mhz
	output LEDG_N,  
	output LEDR_N,
	output LED1,
	output LED2,
	output LED3,
	output LED4,
	output LED5,


	output HPDL_D0,
	output HPDL_D1,
	output HPDL_D2,
	output HPDL_D3,
	output HPDL_D4,
	output HPDL_D5,
	output HPDL_D6,

	output HPDL_A0,
	output HPDL_A1,

	output HPDL_WR1,
	output HPDL_WR2,
	output HPDL_WR3,
	output HPDL_WR4

);

  //-- Toggle the green LED
//   assign LEDG_N = counter[23];
  assign LEDG_N = 1'b1; 
 //-- Turn off the other LEDs
  assign LEDR_N = 1'b1;
  assign {LED5, LED4, LED3, LED2, LED1} = 5'b0;
  
  assign HPDL_D6 = data[6];
  assign HPDL_D5 = data[5];
  assign HPDL_D4 = data[4];
  assign HPDL_D3 = data[3];
  assign HPDL_D2 = data[2];
  assign HPDL_D1 = data[1];
  assign HPDL_D0 = data[0];

  reg [23:0] counter = 0;
  reg [3:0] address_counter = 0;
  wire [7:0] data; 
  wire hpdl_clk; 

  // Generate slower clock for display modules 
  always @(posedge CLK) 
    counter <= counter + 1;

 assign hpdl_clk = counter[10];
//   assign hpdl_clk = CLK;

  // Count 0 to 15 for 16 display places
  always @(posedge hpdl_clk) 
	address_counter <= address_counter + 1;

  memory mem_strorage(
          .clk(CLK),
          .w_en(1'b0),
          .r_en(1'b1),
          .w_addr(4'h0),
          .w_data(8'h0),
          .r_addr(address_counter),
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

endmodule


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

      output reg [7:0] r_data
  );

      reg [7:0]  mem [0:15];

      always @(posedge clk) begin
          if (w_en == 1'b1) begin
              mem[w_addr] <= w_data;    
          end
          
          if (r_en == 1'b1) begin
              r_data <= mem[r_addr];
          end
      end

      initial if (INIT_FILE) begin
          $readmemh(INIT_FILE, mem);
      end
    
endmodule