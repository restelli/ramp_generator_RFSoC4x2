`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2023 11:50:47 AM
// Design Name: 
// Module Name: rampgen
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


module rampgen
  ( frequency,//input 32 bit
    amplitude, //input 32 bit)
    M_AXIS_ACLK, //input
    M_AXIS_ARESETN, //input
    M_AXIS_TREADY, 
    M_AXIS_TDATA,
    M_AXIS_TSTRB,
    M_AXIS_TLAST,
    M_AXIS_TVALID 
  );
   parameter C_S_AXIS_TDATA_WIDTH = 256;
   integer i;
   
   input  [31:0] frequency;
   input  [31:0] amplitude;
   // AXI4Stream source: Clock
		input wire  M_AXIS_ACLK;
		// AXI4Stream sink: Reset
		input wire  M_AXIS_ARESETN;
		// Ready to accept data in
		input wire  M_AXIS_TREADY;
		// Data out
  output reg [C_S_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA;
		// Byte qualifier
  output reg [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB;
		// Indicates boundary of last packet
		output wire  M_AXIS_TLAST;
		// Data is in valid
		output reg  M_AXIS_TVALID;
  reg [31:0] accumulator = 32'h0;
  reg [31:0] pre_accumulator = 32'h0;
  reg [31:0] increment = 32'h0;
  wire [31:0] offset [0:15];
  reg  [31:0] offset_r [0:15];
  reg [31:0] value [0:15];
  reg [47:0] value_scaled [0:15];
  reg [15:0] value_shifted [0:15];
  reg [C_S_AXIS_TDATA_WIDTH-1 : 0] axis_data_r;
  integer n;
  

  assign  offset[0] = 32'h0 * frequency;
  assign  offset[1] = 32'h1 * frequency;
  assign  offset[2] = 32'h2 * frequency;
  assign  offset[3] = 32'h3 * frequency;
  assign  offset[4] = 32'h4 * frequency;
  assign  offset[5] = 32'h5 * frequency;
  assign  offset[6] = 32'h6 * frequency;
  assign  offset[7] = 32'h7 * frequency;
  assign  offset[8] = 32'h8 * frequency;
  assign  offset[9] = 32'h9 * frequency;
  assign  offset[10] = 32'hA * frequency;
  assign  offset[11] = 32'hB * frequency;
  assign  offset[12] = 32'hC * frequency;
  assign  offset[13] = 32'hD * frequency;
  assign  offset[14] = 32'hE * frequency;
  assign  offset[15] = 32'hE * frequency;  
  
  
  
  
  
  initial
  begin
    for (n = 0; n < C_S_AXIS_TDATA_WIDTH/8 ; n = n+1) M_AXIS_TSTRB = 32'h0;
  end
                              
                                                 
// M_AXIS_TLAST is not used so I'm setting it to 0  
assign M_AXIS_TLAST = 1'b0;

 
 always @(posedge M_AXIS_ACLK)
 begin
   
    M_AXIS_TDATA <= axis_data_r;


   if (M_AXIS_ARESETN == 1'b1)
      begin
            
            if (M_AXIS_TREADY)
            begin
                pre_accumulator <= pre_accumulator + increment;
                accumulator <= pre_accumulator;
                M_AXIS_TVALID <= 1'b1;
                increment <= 32'h10 * frequency;

                for (i=0; i < C_S_AXIS_TDATA_WIDTH/16 ; i = i + 1)
                begin            
                  offset_r[i] <= offset[i];
                  value[i] <= accumulator + offset_r[i];
                  value_scaled[i]<= value[i] * {amplitude[15:0]};
                  value_shifted[i]<= value_scaled[i][47:32] + 16'h8000; 
                  axis_data_r [i*16 +:16] <= {value_shifted[i] [15:2], 1'b0, 1'b0};
                end
            end
            else
            begin
                for (i=0; i < C_S_AXIS_TDATA_WIDTH/16 ; i = i + 1)
                begin            
                  value[i] <= value[i];
                end
                M_AXIS_TVALID <= 1'b0;
              
            end
            
          end
      else
      begin
          
              accumulator <= 0;
              M_AXIS_TVALID <= 1'b0;
      end
 end

    
 endmodule
