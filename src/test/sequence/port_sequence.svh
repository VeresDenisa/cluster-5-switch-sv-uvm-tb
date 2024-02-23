class port_sequence extends uvm_sequence #(port_item);
  `uvm_object_utils(port_sequence);
  
  port_item item;
  bit is_ready = 1'b0;
  int bandwidth = 100;
  
  function new (string name = "port_sequence");
    super.new(name);
  endfunction : new
  
  extern function void set_is_ready(bit ready = 1'b0);
  extern function void set_parameters(int bandwidth = 100);
  extern task body();  
endclass : port_sequence

    
    
    
function void port_sequence::set_parameters(int bandwidth = 100);
  this.bandwidth = bandwidth;
endfunction : set_parameters
    
function void port_sequence::set_is_ready(bit ready = 1'b0);
  this.is_ready = ready;
endfunction : set_is_ready

task port_sequence::body();
  item = port_item::type_id::create("item");
  start_item(item);
  item.bandwidth = this.bandwidth;
  if(this.is_ready !== 1'b1) begin
    item.read = 1'b0;
  end else begin
  	if(!item.randomize())
      		`uvm_error(this.get_name(), "Failed randomization");
  end
  finish_item(item);
endtask : body
