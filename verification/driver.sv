class driver;
  transaction tr;
  mailbox#(transaction) gen2drv;
  virtual fifo_if vif;
  
  function new(virtual fifo_if vif, mailbox#(transaction) gen2drv);
    this.vif = vif;
    this.gen2drv = gen2drv;
  endfunction

  task reset();
    $display("[DRV] Applying Reset at %0t", $time);
    vif.wr_en   <= 0;
    vif.rd_en   <= 0;
    vif.data_in <= 0;
    vif.wr_rst  <= 1;
    vif.rd_rst  <= 1;
    repeat(1) @(posedge vif.wr_clk);
    repeat(1) @(posedge vif.rd_clk);
    vif.wr_rst  <= 0;
    vif.rd_rst  <= 0;
    $display("[DRV] Deasserted Reset at %0t", $time);
  endtask

  task run();
    tr = new();
    forever begin
      gen2drv.get(tr);

      //====== Write operation =======//
      if (tr.wr_en) begin
        @(posedge vif.wr_clk);
        if (!vif.full && !vif.wr_rst) begin
          vif.wr_en   <= 1;
          vif.data_in <= tr.data;
          @(posedge vif.wr_clk);
          vif.wr_en   <= 0;
          $display("[DRV] Write : data = %0d @ %0t", tr.data, $time);
        end else begin
          $display("[DRV] Write skipped: FULL or RESET @ %0t", $time);
        end
      end

      //======== Read Operation ========//
      if (tr.rd_en) begin
        repeat(3) @(posedge vif.rd_clk);
        if (!vif.empty && !vif.rd_rst) begin
          vif.rd_en <= 1;
          @(posedge vif.rd_clk);
          vif.rd_en <= 0;
          $display("[DRV] Read triggered @ %0t", $time);
        end else begin
          $display("[DRV] Read skipped: EMPTY or RESET @ %0t", $time);
        end
      end
    end
    
  endtask

endclass

