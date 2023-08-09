`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2023 12:25:28 PM
// Design Name: 
// Module Name: rampgen_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rampgen_tb;

reg [31:0] frequency;
reg [31:0] amplitude;
reg M_AXIS_ACLK;
reg M_AXIS_ARESETN;
  wire [255:0] M_AXIS_TDATA;
  wire [31:0]M_AXIS_TSTRB;
wire M_AXIS_TLAST;
wire M_AXIS_TVALID;

reg M_AXIS_TREADY;

initial
begin
    #1 frequency = 32'd00040000;
       amplitude = 32'hFFFFFFFF;
       M_AXIS_ACLK = 1'b0;
       M_AXIS_TREADY = 1'b1;
  	M_AXIS_ARESETN = 1'b0;
  	#40 M_AXIS_ARESETN = 1'b1;
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(0,rampgen_tb);

  	#10000 $finish;
end

always
begin
    #10 M_AXIS_ACLK <= ~M_AXIS_ACLK;
end


rampgen dut
  ( .frequency(frequency),//input 32 bit
    .amplitude(amplitude), //input 32 bit)
    .M_AXIS_ACLK(M_AXIS_ACLK), //input
    .M_AXIS_ARESETN(M_AXIS_ARESETN), //input
    .M_AXIS_TREADY(M_AXIS_TREADY), 
    .M_AXIS_TDATA(M_AXIS_TDATA),
    .M_AXIS_TSTRB(M_AXIS_TSTRB),
    .M_AXIS_TLAST(M_AXIS_TLAST),
    .M_AXIS_TVALID(M_AXIS_TVALID) 
  );







endmodule
