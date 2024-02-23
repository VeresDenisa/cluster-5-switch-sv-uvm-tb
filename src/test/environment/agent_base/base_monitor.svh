class base_monitor 
  #(string name = "base_monitor", type ss_item = uvm_sequence_item) 
extends uvm_monitor;

  `uvm_component_utils(base_monitor)
  
  uvm_analysis_port #(ss_item) an_port;

  function new (string name = name, uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass : base_monitor