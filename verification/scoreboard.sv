class scoreboard;

  mailbox #(transaction) mon2scb;
  transaction ref_model[$];

  function new(mailbox #(transaction) mon2scb);
    this.mon2scb = mon2scb;
  endfunction

  task run();
    transaction tr;
    forever begin
      mon2scb.get(tr);

      // Process WRITE
      if (tr.wr_en) begin
        ref_model.push_back(tr.copy());  
        $display("[SCB] Stored WRITE  data = 0x%0h", tr.data);

      end else if (tr.rd_en) begin
        // Process READ and compare with reference
        if (ref_model.size() == 0) begin
          $error("[SCB] ERROR: Read occurred but ref_model is empty!");
        end else begin
          transaction exp = ref_model.pop_front();
          if (tr.data === exp.data) begin
            $display("[SCB] READ PASS: data = 0x%0h", tr.data);
          end else begin
            $error("[SCB] READ FAIL: Expected = 0x%0h, Got = 0x%0h", exp.data, tr.data);
          end
        end
      end
    end
  endtask

endclass
