class port_item extends uvm_sequence_item;
  `uvm_object_utils(port_item);
  
  rand bit       read;
       bit [7:0] port;
       bit       ready;
  
  int bandwidth = 80;
  
  constraint mostly_active_read { read dist { 1 := bandwidth, 0 := (100-bandwidth) }; }
       
  function new(string name = "port_item");
    super.new(name);
  endfunction : new
  
  extern function string convert2string();
  extern function bit compare(port_item item);
  extern function void set_read(bit read = 1'b0);
  extern function void copy(port_item item);
endclass : port_item



function string port_item::convert2string();
  return $sformatf("PORT: 'h%0h  READ: 'b%0b  READY: 'b%0b", port, read, ready);
endfunction : convert2string

function bit port_item::compare(port_item item);
  if(this.read  !== item.read)  return 1'b0;
  if(this.ready !== item.ready) return 1'b0;
  if(this.port  !== item.port)  return 1'b0;
  return 1'b1;
endfunction
    
function void port_item::set_read(bit read = 1'b0);
  this.read = read;
endfunction : set_read

function void port_item::copy(port_item item);
  this.read  = item.read;
  this.ready = item.ready;
  this.port  = item.port;
endfunction
