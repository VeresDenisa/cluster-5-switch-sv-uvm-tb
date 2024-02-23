class reset_sequence extends uvm_sequence #(reset_item);
  `uvm_object_utils(reset_sequence)
  
  reset_item item;
  int nr_items = 1, reset_max_duration, reset_max_delay;
  
  function new (string name = "reset_sequence");
    super.new(name);
  endfunction : new
  
  extern function void set_parameters(int nr_items = 1, int reset_max_duration = 1, int reset_max_delay = 0);
    
  extern task body();  
endclass : reset_sequence


    
function void reset_sequence::set_parameters(int nr_items = 1, int reset_max_duration = 1, int reset_max_delay = 0);
  this.nr_items = nr_items;
  this.reset_max_duration = reset_max_duration;
  this.reset_max_delay = reset_max_delay;
endfunction : set_parameters

task reset_sequence::body();
  repeat (nr_items) begin : random_loop
    item = reset_item::type_id::create("item");
    start_item(item);
    item.reset = 0;
    finish_item(item);
    
    item = reset_item::type_id::create("item_default");
    start_item(item);
    item.reset = 1;
    finish_item(item);
  end : random_loop
endtask : body
