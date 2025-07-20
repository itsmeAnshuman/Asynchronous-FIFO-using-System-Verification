`include "test.sv"
`timescale 1ns/1ps

module tb;
  test t;

  logic wr_clk, rd_clk;

  initial begin
    wr_clk = 0;
    forever #4 wr_clk = ~wr_clk; 
  end

  initial begin
    rd_clk = 0;
    forever #3 rd_clk = ~rd_clk; 
  end

  fifo_if #(8) fifo_if_inst(wr_clk, rd_clk);

  async_fifo #(
    .data_width(8),
    .addr_width(4)
  ) dut (
    .data_in (fifo_if_inst.data_in),
    .wr_en   (fifo_if_inst.wr_en),
    .wr_clk  (fifo_if_inst.wr_clk),
    .wr_rst  (fifo_if_inst.wr_rst),
    .full    (fifo_if_inst.full),
    .data_out(fifo_if_inst.data_out),
    .rd_en   (fifo_if_inst.rd_en),
    .rd_clk  (fifo_if_inst.rd_clk),
    .rd_rst  (fifo_if_inst.rd_rst),
    .empty   (fifo_if_inst.empty)
  );

  initial begin
    t= new(fifo_if_inst);
    t.run();
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
  end

endmodule
