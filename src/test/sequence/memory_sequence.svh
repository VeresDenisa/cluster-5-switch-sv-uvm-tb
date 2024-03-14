typedef enum bit { READ_TRANS = 1'b0, WRITE_TRANS = 1'b1 } memory_trans_enum;

class memory_sequence extends uvm_sequence #(memory_item);
  `uvm_object_utils(memory_sequence)
  
  memory_item item;
  
  int nr_items = 4, addr = 3, no_random = 0, data= 0;
  memory_trans_enum memory_trans = READ_TRANS;
  bit rotate = 1'b0;
  
  function new (string name = "memory_sequence");
    super.new(name);
  endfunction : new

  extern function void set_parameters(int nr_items = 4, int data = 0, int addr = 3, int no_random = 0, bit rotate = 1'b0, memory_trans_enum memory_trans = READ_TRANS);
    
  extern task body();
endclass : memory_sequence

    
    
function void memory_sequence::set_parameters(int nr_items = 4, int data = 0, int addr = 3, int no_random = 0, bit rotate = 1'b0, memory_trans_enum memory_trans = READ_TRANS);
  this.nr_items  = nr_items;
  this.addr      = addr;
  this.no_random = no_random;
  this.memory_trans = memory_trans;
  this.rotate = rotate;
  this.data = data;
endfunction : set_parameters

task memory_sequence::body();
  item = memory_item::type_id::create("item");
  start_item(item);
  if(no_random !== 0) begin
    assert(item.randomize());
    item.set_enable();
  end else begin
      if(memory_trans === WRITE_TRANS) data = $urandom_range(0,254);
      else data = 0;
      if(rotate) item.set_item(.mem_addr(0), .mem_sel_en(1'b1), .mem_wr_rd_s(memory_trans));
      else item.set_item(.mem_addr(addr), .mem_sel_en(1'b1), .mem_wr_rd_s(memory_trans));
    end
  finish_item(item);

  for(int i = 1; i <= nr_items; i++) begin : loop
    if(i === nr_items) begin
      start_item(item);
      item.set_item(.mem_wr_data(data), .mem_addr(0), .mem_sel_en(1'b0), .mem_wr_rd_s(1'b0));
      finish_item(item);
    end
    else begin
      start_item(item);
      if(no_random !== 0) begin
        assert(item.randomize());
        item.set_enable();
      end else begin
        if(rotate) item.set_item(.mem_wr_data(data), .mem_addr(i%4), .mem_sel_en(1'b1), .mem_wr_rd_s(memory_trans));
        else item.set_item(.mem_wr_data(data), .mem_addr(addr), .mem_sel_en(1'b1), .mem_wr_rd_s(memory_trans));
      end
      finish_item(item);
    end
  end : loop
endtask : body
