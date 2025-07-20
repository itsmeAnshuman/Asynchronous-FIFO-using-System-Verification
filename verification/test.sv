`include "environment.sv"

class test;

  environment env;

  // Constructor
  function new(virtual fifo_if vif);
    env = new(vif);
  endfunction

  //====================== Test1: One Write & One Read ======================//
  task automatic one_write_one_read();
    transaction t;
    $display("[Test2] Single write and read test");

    // Single write
    t = new(); t.data = 42; t.wr_en = 1; t.rd_en = 0;
    env.gen.gen2drv.put(t);
    #20;

    // Single read
    t = new(); t.wr_en = 0; t.rd_en = 1;
    env.gen.gen2drv.put(t);
  endtask

  //================== Test2: Multiple Write followed by Read ==============//
  task automatic multiple_write_read();
    transaction t;
    $display("[Test3] Multiple write followed by read");

    // Write 4 values
    for (int i = 0; i < 4; i++) begin
      t = new(); t.wr_en = 1; t.rd_en = 0; t.data = 8'hA0 + i;
      env.gen.gen2drv.put(t);
    end

    #50;

    // Read 4 times
    for (int i = 0; i < 4; i++) begin
      t = new(); t.wr_en = 0; t.rd_en = 1;
      env.gen.gen2drv.put(t);
    end
  endtask

  //======================== Test3: FIFO Overflow Condition =================//
  task automatic test_overflow();
    transaction t;
    $display("[Test4] FIFO overflow test");

    // Write more than FIFO depth (e.g., >16 for 4-bit addr width)
    for (int i = 0; i < 20; i++) begin
      t = new(); t.wr_en = 1; t.rd_en = 0; t.data = 8'hA0 + i;
      env.gen.gen2drv.put(t);
    end
  endtask

  //======================= Test4: FIFO Underflow Condition =================//
  task automatic test_underflow();
    transaction t;
    $display("[Test5] FIFO underflow test");

    // Single write
    t = new(); t.wr_en = 1; t.rd_en = 0; t.data = 42;
    env.gen.gen2drv.put(t);
    #20;

    // Attempt multiple reads (more than written)
    for (int i = 0; i < 5; i++) begin
      t = new(); t.wr_en = 0; t.rd_en = 1;
      env.gen.gen2drv.put(t);
    end
  endtask

  //===================== Test5: Randomized Write and Read ==================//
  task automatic test6_random_rw();
    transaction t;
    $display("[Test6] Random write-read test");

    // Generate 20 randomized transactions
    for (int i = 0; i < 20; i++) begin
      t = new();
      t.wr_en = $urandom_range(0, 1);
      t.rd_en = $urandom_range(0, 1);
      t.data  = (t.wr_en) ? $urandom_range(0, 255) : 8'h00;
      env.gen.gen2drv.put(t);
    end
  endtask

  //============================= Main Test Run =============================//
  task run();
    $display("[TEST] Starting Test...");
    env.drv.reset();

    fork
      env.gen.run();
      env.drv.run();
      env.mon.run();
      env.scb.run();
    join_none

    // Choose one test below to run
//     one_write_one_read();
//     multiple_write_read();
//     test_overflow();
    // test_underflow();
    // test6_random_rw();

    #500;
    $display("[TEST] Test completed.");
    $finish;
  endtask

endclass
