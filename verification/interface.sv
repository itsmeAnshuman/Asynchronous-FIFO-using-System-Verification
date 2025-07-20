interface fifo_if#(parameter data_width=8)(
  input logic wr_clk,
  input logic rd_clk
);
  //DUT input
  logic [data_width-1:0] data_in;
  logic wr_rst,rd_rst;
  logic wr_en,rd_en;
  //DUT output
  logic [data_width-1:0] data_out;
  logic full,empty;
  
endinterface
