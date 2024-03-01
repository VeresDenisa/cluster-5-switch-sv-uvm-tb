class port_sequence extends uvm_sequence #(port_item);
  `uvm_object_utils(port_sequence);
  
  port_item item;
  bit is_ready = 1'b0;
  
  function new (string name = "port_sequence");
    super.new(name);
  endfunction : new
  
  extern function void set_is_ready(bit ready = 1'b0);
  extern task body();  
endclass : port_sequence

                
function void port_sequence::set_is_ready(bit ready = 1'b0);
  this.is_ready = ready;
endfunction : set_is_ready

task port_sequence::body();
  item = port_item::type_id::create("item");
  start_item(item);
  item.read = is_ready;
  finish_item(item);
endtask : body
