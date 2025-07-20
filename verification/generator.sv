class generator;

  bit random_mode = 1;
  transaction tr;
  mailbox #(transaction) gen2drv;

  int num_transaction = 20;

  function new(mailbox #(transaction) gen2drv);
    this.gen2drv = gen2drv;
    this.random_mode = 1;
  endfunction

  task run();
    if (random_mode) begin
      $display("[GEN] Running in RANDOM mode");
      repeat (num_transaction) begin
        tr = new();
        assert(tr.randomize() with { (wr_en || rd_en); }) else
          $error("[GEN] Randomization failed");
        tr.display("GEN");
        gen2drv.put(tr);
        #10;  // Delay between transactions
      end
    end else begin
      $display("[GEN] Running in USER-DEFINED mode");
      repeat (num_transaction) begin
        tr = new();
        tr.wr_en = 1;
        tr.rd_en = 0;
        tr.data  = $urandom_range(0, 255);
        tr.display("GEN");
        gen2drv.put(tr);
        #10;
      end
    end
  endtask
endclass
