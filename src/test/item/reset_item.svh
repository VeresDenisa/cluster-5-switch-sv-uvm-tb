class reset_item extends uvm_sequence_item;
  `uvm_object_utils(reset_item);
  
  bit reset;
  
  function new(string name = "reset_item");
    super.new(name);
  endfunction : new
    
  extern function string convert2string();
  extern function bit compare(reset_item item);
endclass : reset_item

    
function bit reset_item::compare(reset_item item);
  if(this.reset !== item.reset) return 1'b0;
  return 1'b1;
endfunction
    
function string reset_item::convert2string();
  return $sformatf("reset: %0h", reset);
endfunction : convert2string
