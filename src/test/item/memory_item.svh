typedef enum bit[1:0] { MEMORY_WRITE  = 2'b11, MEMORY_READ  = 2'b10, MEMORY_IDLE  = 2'b00 } memory_write_read_idle_enum;

class memory_item extends uvm_sequence_item;
  `uvm_object_utils(memory_item);
  
  rand logic [7:0] mem_wr_data;   // INPUT
       bit   [31:0] mem_rd_data;   // OUTPUT
  rand bit   [7:0] mem_addr;      // INPUT
       bit         mem_wr_rd_s;   // INPUT
       bit         mem_sel_en;    // INPUT
       bit         mem_ack;       // OUTPUT
  rand memory_write_read_idle_enum mem_sel_enum;
       
  constraint mostly_inactive_mem_sel_enum { mem_sel_enum dist { 2'b00 := 90, 2'b10 := 5, 2'b11 := 5 }; }
  constraint pseudo_random_data           { mem_wr_data dist {'h00:/10,'h55:/10,'hAA:/10,'hFF:/10,['h01:'h54]:/10,['h56:'hA9]:/10,['hA9:'hFE]:/10}; }
  
  function new(string name = "memory_item");
    super.new(name);
  endfunction : new
  
  extern function void set_data(logic [7:0] mem_wr_data);
  extern function void set_address(bit [1:0] mem_addr);
  extern function void set_enable(bit mem_sel_en = 1'b1, bit mem_wr_rd_s = 1'b1);
    
  extern function void set_item(logic [7:0] mem_wr_data = 8'h00, bit [1:0] mem_addr, bit mem_sel_en = 1'b1, bit mem_wr_rd_s = 1'b1);

  extern function string convert2string();
  extern function bit compare(memory_item item);
  extern function void copy(memory_item item); 
  extern function void post_randomize();  
endclass : memory_item



function void memory_item::post_randomize();
  {mem_sel_en, mem_wr_rd_s} = mem_sel_enum;
endfunction : post_randomize
    
function void memory_item::set_data(logic [7:0] mem_wr_data);
  this.mem_wr_data = mem_wr_data;
endfunction : set_data
    
function void memory_item::set_address(bit [1:0] mem_addr);
  this.mem_addr = mem_addr;
endfunction : set_address

function void memory_item::set_enable(bit mem_sel_en = 1'b1, bit mem_wr_rd_s = 1'b1);
  this.mem_sel_en  = mem_sel_en;
  this.mem_wr_rd_s = mem_wr_rd_s;
endfunction : set_enable

function void memory_item::set_item(logic [7:0] mem_wr_data = 8'h00, bit [1:0] mem_addr, bit mem_sel_en = 1'b1, bit mem_wr_rd_s = 1'b1);
  this.set_data(mem_wr_data);
  this.set_address(mem_addr);
  this.set_enable(mem_sel_en, mem_wr_rd_s);
endfunction : set_item

function string memory_item::convert2string();
  return $sformatf("mem_wr_rd_s: 'b%0h  mem_sel_en: 'b%0h  mem_ack: 'b%0h  mem_wr_data: 'h%0h  mem_rd_data: 'h%8h  mem_addr: 'h%0h", mem_wr_rd_s, mem_sel_en, mem_ack, mem_wr_data, mem_rd_data, mem_addr);
endfunction : convert2string

function bit memory_item::compare(memory_item item);
  if(this.mem_wr_data !== item.mem_wr_data) return 1'b0;
  if(this.mem_rd_data !== item.mem_rd_data) return 1'b0;
  if(this.mem_addr    !== item.mem_addr)    return 1'b0;
  if(this.mem_sel_en  !== item.mem_sel_en)  return 1'b0;
  if(this.mem_wr_rd_s !== item.mem_wr_rd_s) return 1'b0;
  if(this.mem_ack     !== item.mem_ack)     return 1'b0;
  return 1'b1;
endfunction

function void memory_item::copy(memory_item item);
  this.mem_wr_data = item.mem_wr_data;
  this.mem_rd_data = item.mem_rd_data;
  this.mem_addr    = item.mem_addr;
  this.mem_sel_en  = item.mem_sel_en;
  this.mem_wr_rd_s = item.mem_wr_rd_s;
  this.mem_ack     = item.mem_ack;
endfunction
