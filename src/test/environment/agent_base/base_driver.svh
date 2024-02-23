class base_driver#(string name = "base_driver", type ss_item = uvm_sequence_item) extends uvm_driver #(ss_item);
  `uvm_component_utils(base_driver)

  function new (string name = name, uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass : base_driver


