import item_pack::*;

interface port_interface(input bit clock);
  bit [7:0] port;
  bit       read;
  bit       ready;  
  
  clocking driver@(posedge clock);
   output read;
  endclocking 
  
  clocking monitor@(posedge clock);
    input port;
    input read;
    input ready;
  endclocking
  
  task send(port_item item);
    @(driver);
    driver.read <= item.read;
  endtask : send
  
  function automatic void receive(ref port_item item);
    item.port  = monitor.port;
    item.read  = monitor.read;
    item.ready = monitor.ready;
  endfunction : receive
  
endinterface : port_interface