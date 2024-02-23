class memory_sequence extends uvm_sequence #(memory_item);
  `uvm_object_utils(memory_sequence)
  
  memory_item item;
  
  int nr_items = 4, addr = 3, no_random = 0;
  bit sel = 1'b0, wr_rd = 1'b0;
  
  function new (string name = "memory_sequence");
    super.new(name);
  endfunction : new

  extern function void set_parameters(int nr_items = 4, int addr = 3, int no_random = 0, bit sel = 1'b0, bit wr_rd = 1'b0);
    
  extern task body();
endclass : memory_sequence

    
    
function void memory_sequence::set_parameters(int nr_items = 4, int addr = 3, int no_random = 0, bit sel = 1'b0, bit wr_rd = 1'b0);
  this.nr_items  = nr_items;
  this.addr      = addr;
  this.no_random = no_random;
  this.sel       = sel;
  this.wr_rd     = wr_rd;
endfunction : set_parameters

task memory_sequence::body();
  repeat(nr_items) begin : loop
    item = memory_item::type_id::create("item");
    start_item(item);
    if(no_random !== 0) assert(item.randomize());
    else item.set_item(.mem_addr(addr), .mem_sel_en(sel), .mem_wr_rd_s(wr_rd));
    finish_item(item);
  end : loop
endtask : body
