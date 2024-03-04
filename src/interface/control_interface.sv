import item_pack::*;

interface control_interface(input bit clock);
  bit [7:0] data_in;
  bit       sw_enable_in;  
  bit       read_out;  
  
  clocking driver@(posedge clock);
    output data_in;
    output sw_enable_in;
  endclocking
  
  clocking monitor@(posedge clock);
    input data_in;
    input sw_enable_in;
    input read_out;
  endclocking
  
  task send(data_packet packet);
    @(driver);
    driver.sw_enable_in <= packet.sw_enable_in[0];

    @(driver);
    driver.sw_enable_in <= packet.sw_enable_in[1];
    driver.data_in      <= packet.SOF;

    @(driver);
    driver.data_in      <= packet.da;
    driver.sw_enable_in <= packet.sw_enable_in[2];
    
    @(driver);
    driver.data_in      <= packet.sa;
    driver.sw_enable_in <= packet.sw_enable_in[3];
    
    @(driver);
    driver.data_in      <= packet.length;
    driver.sw_enable_in <= packet.sw_enable_in[4];
    
    foreach(packet.payload[i]) begin
      @(driver);
      driver.data_in      <= packet.payload[i];
      driver.sw_enable_in <= packet.sw_enable_in[i+5];
    end

    @(driver);
    driver.data_in      <= packet.parity;
    driver.sw_enable_in <= packet.sw_enable_in[packet.length + 5];

    @(driver);
    driver.data_in      <= packet.EOF;
    driver.sw_enable_in <= packet.sw_enable_in[packet.length + 6];
    
    //repeat(packet.delay) @(driver);
  endtask : send
  
  function automatic void receive(ref control_item item);
    item.data_in      = monitor.data_in;
    item.sw_enable_in = monitor.sw_enable_in;
    item.read_out     = monitor.read_out;
  endfunction : receive
endinterface : control_interface