`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.07.2025 12:37:00
// Design Name: 
// Module Name: async_fifo
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


module async_fifo #(
  parameter data_width=8,
  parameter addr_width=4
)
  (
    //write pointer
    input wire[data_width-1:0] data_in,
    input wire wr_en,
    input wire wr_clk,
    input wire wr_rst,
    output wire full,
    
    // Read pointer
    output reg[data_width-1:0] data_out,
    input wire rd_en,
    input wire rd_clk,
    input wire rd_rst,
    output wire empty
  );
  localparam depth =1<<addr_width; //depth -2^addr_width
  //fifo memory
  reg [data_width-1:0]mem[0:depth-1];
  
  //write pointer(binary and gray)
  reg [addr_width:0] wr_ptr_bin,wr_ptr_gray;
  
  //read_pointer(binary and gray)
  reg [addr_width:0] rd_ptr_bin, rd_ptr_gray;
  
  //synchrounized gray pointer
  reg[addr_width:0] rd_ptr_gray_sync_wr1, rd_ptr_gray_sync_wr2;
  reg[addr_width:0] wr_ptr_gray_sync_rd1 , wr_ptr_gray_sync_rd2;
  
  //write operation
 always@(posedge wr_clk or posedge wr_rst) begin
  if(wr_rst) begin
    wr_ptr_bin <= 0;
    wr_ptr_gray <= 0;
    rd_ptr_gray_sync_wr1 <= 0;
    rd_ptr_gray_sync_wr2 <= 0;
  end else begin
    if(wr_en && !full) begin
      mem[wr_ptr_bin[addr_width-1:0]] <= data_in;
      wr_ptr_bin <= wr_ptr_bin + 1;
      wr_ptr_gray <= (wr_ptr_bin + 1) ^ ((wr_ptr_bin + 1) >> 1); // Binary to Gray
    end

    // Synchronize read pointer (Gray code) into write clock domain
    rd_ptr_gray_sync_wr1 <= rd_ptr_gray;
    rd_ptr_gray_sync_wr2 <= rd_ptr_gray_sync_wr1;
  end
end

  // read operation
  always@(posedge rd_clk or posedge rd_rst) begin
    if(rd_rst) begin
      rd_ptr_bin<=0;
      rd_ptr_gray<=0;
      wr_ptr_gray_sync_rd1<=0;
      wr_ptr_gray_sync_rd2<=0;
    end else begin
      if(rd_en && !empty) begin
        data_out<=mem[rd_ptr_bin[addr_width-1:0]];
        rd_ptr_bin<=rd_ptr_bin+1;
        rd_ptr_gray<=(rd_ptr_bin+1)^((rd_ptr_bin+1) >>1); //binary to gray
      end
      
      //synchronize wire pointer (gray code) into read clock domain
       wr_ptr_gray_sync_rd1 <= wr_ptr_gray;
    wr_ptr_gray_sync_rd2 <= wr_ptr_gray_sync_rd1;
    end
  end
  
  //Gray to binary convertion
 function automatic [addr_width:0] gray_to_bin(input [addr_width:0] gray);
  integer i;
  begin
    gray_to_bin[addr_width] = gray[addr_width];
    for (i = addr_width-1; i >= 0; i = i - 1)
      gray_to_bin[i] = gray_to_bin[i+1] ^ gray[i];
  end
endfunction
//  convert gray pointer to binary
wire [addr_width:0] wr_ptr_gray_to_bin = gray_to_bin(wr_ptr_gray);
wire [addr_width:0] rd_ptr_gray_sync_wr2_to_bin = gray_to_bin(rd_ptr_gray_sync_wr2);
wire [addr_width:0] rd_ptr_gray_to_bin = gray_to_bin(rd_ptr_gray);
wire [addr_width:0] wr_ptr_gray_sync_rd2_to_bin = gray_to_bin(wr_ptr_gray_sync_rd2);

  //full : when next write pointer = read ptr with MSB inverted
  assign full = (
  wr_ptr_gray_to_bin[addr_width] != rd_ptr_gray_sync_wr2_to_bin[addr_width] &&
  wr_ptr_gray_to_bin[addr_width-1:0] == rd_ptr_gray_sync_wr2_to_bin[addr_width-1:0]
);

  //empty : when rd_ptr == wr_ptr 
  assign empty = (rd_ptr_gray_to_bin == wr_ptr_gray_sync_rd2_to_bin);
  
endmodule

  
  
        

  
  
