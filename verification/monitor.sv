class monitor #(parameter data_width = 8);

  virtual fifo_if vif;
  mailbox #(transaction) mon2scb;

  function new(virtual fifo_if vif, mailbox #(transaction) mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
  endfunction

  task run();
    fork
      monitor_write();
      monitor_read();
    join
  endtask

  // Task for capturing write transactions
  task monitor_write();
    transaction tr;
    forever begin
      @(posedge vif.wr_clk);
      if (vif.wr_en && !vif.full && !vif.wr_rst) begin
        tr = new();
        tr.wr_en = 1;
        tr.rd_en = 0;
        tr.data  = vif.data_in;
        mon2scb.put(tr.copy());
        $display("[MON] Captured WRITE : data = 0x%0h @ %0t", tr.data, $time);
      end
    end
  endtask

  // Task for capturing read transactions
  task monitor_read();
    transaction tr;
    forever begin
      @(posedge vif.rd_clk);
      if (vif.rd_en && !vif.empty && !vif.rd_rst) begin
        @(posedge vif.rd_clk);  // Delay one more cycle for data_out to be valid
        tr = new();
        tr.rd_en = 1;
        tr.wr_en = 0;
        tr.data  = vif.data_out;
        mon2scb.put(tr.copy());
        $display("[MON] Captured READ  : data = 0x%0h @ %0t", tr.data, $time);
      end
    end
  endtask

endclass
