import item_pack::*;

interface reset_interface(input bit clock);
  bit reset;
  
  clocking driver@(posedge clock);
    output reset;
  endclocking
  
  clocking monitor@(posedge clock);
    input reset;
  endclocking
  
  task send(reset_item rst_item);
    @(driver) driver.reset <= rst_item.reset;
  endtask : send
  
  function automatic void receive(ref reset_item item);
    item.reset = monitor.reset;
  endfunction : receive
endinterface : reset_interface