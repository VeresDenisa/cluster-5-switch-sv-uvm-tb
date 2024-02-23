class virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(virtual_sequencer);
  
  port_sequencer port_seqr[4];
  
  function new (string name = "virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
endclass : virtual_sequencer