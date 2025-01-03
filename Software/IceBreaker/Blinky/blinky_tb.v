`timescale 1ns/1ps
`define DUMPSTR(x) `"x.vcd`"
module blinky_tb();

parameter DURATION  = 10000;

reg CLK = 0;


always begin
    #41.667
    CLK =!CLK;
end

blink_test UUT(
    .CLK(CLK)

);

initial begin

  $dumpfile(`DUMPSTR(`VCD_OUTPUT));
  $dumpvars(0, blinky_tb);

   #(DURATION) 
  $display("End of simulation");
  $finish;
end

endmodule


