class control_item extends uvm_sequence_item;
  `uvm_object_utils(control_item);
  
  rand bit [7:0] data_in;
  rand bit       sw_enable_in;
       bit       read_out;
       
  constraint non_random_data_in { data_in  dist {'h00:/10,'h55:/10,'hAA:/10,'hFF:/10,['h01:'h54]:/0,['h56:'hA9]:/0,['hA9:'hFE]:/0}; }
  
  function new(string name = "control_item");
    super.new(name);
  endfunction : new

  extern function string convert2string();
  extern function bit compare(control_item item);
  extern function void copy(control_item item);
endclass : control_item



function string control_item::convert2string();
  return $sformatf("data_in: 'h%0h  sw_enable_in: 'b%0h  read_out: 'b%0h", data_in, sw_enable_in, read_out);
endfunction : convert2string

function bit control_item::compare(control_item item);
  if(this.data_in      !== item.data_in)      return 1'b0;
  if(this.sw_enable_in !== item.sw_enable_in) return 1'b0;
  if(this.read_out     !== item.read_out)     return 1'b0;
  return 1'b1;
endfunction

function void control_item::copy(control_item item);
  this.data_in      = item.data_in;
  this.sw_enable_in = item.sw_enable_in;
  this.read_out     = item.read_out;
endfunction
