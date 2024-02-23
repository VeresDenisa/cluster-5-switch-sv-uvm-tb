import item_pack::*;

interface memory_interface(input bit clock);
  logic [7:0] mem_wr_data;
  bit   [31:0] mem_rd_data;
  bit   [7:0] mem_addr;
  bit         mem_sel_en;
  bit         mem_wr_rd_s;
  bit         mem_ack;
  
  clocking driver@(posedge clock);
    output mem_wr_data;
    output mem_addr;
    output mem_sel_en;
    output mem_wr_rd_s;
  endclocking
  
  clocking monitor@(posedge clock);
    input mem_wr_data;
    input mem_rd_data;
    input mem_addr;
    input mem_sel_en;
    input mem_wr_rd_s;
    input mem_ack;
  endclocking
  
  task send(memory_item item);
    @(driver);
    driver.mem_wr_data <= item.mem_wr_data;
    driver.mem_addr    <= item.mem_addr;
    driver.mem_sel_en  <= item.mem_sel_en;
    driver.mem_wr_rd_s <= item.mem_wr_rd_s;
  endtask : send
  
  function automatic void receive(ref memory_item item);
    item.mem_wr_data = monitor.mem_wr_data;
    item.mem_rd_data = monitor.mem_rd_data;
    item.mem_addr    = monitor.mem_addr;
    item.mem_sel_en  = monitor.mem_sel_en;
    item.mem_wr_rd_s = monitor.mem_wr_rd_s;
    item.mem_ack     = monitor.mem_ack;
  endfunction : receive
endinterface : memory_interface