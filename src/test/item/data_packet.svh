typedef enum bit { PREDEFINED  = 1'b1, RANDOM  = 1'b0 } random_predefined_enum;

class data_packet extends uvm_sequence_item;
  `uvm_object_utils(data_packet);
  
       bit [7:0]   SOF = 8'hFF;
  rand bit [7:0]   da;
  rand bit [7:0]   sa;
  rand bit [7:0]   length;
       bit [7:0]   payload[$];
       bit [7:0]   parity;
       bit [7:0]   EOF = 8'h55;
       bit         sw_enable_in[$];
  
  int delay = 9;
  int max_length = 255, min_length = 0;
  random_predefined_enum random_DA;
  bit [7:0] memory_data[4];
  
  
  constraint SA_diff_EOF           { sa != 8'h55; }
  constraint DA_diff_EOF           { da != 8'h55; }
  constraint length_diff_EOF       { length != 8'h55; }
  constraint SA_diff_SOF           { sa != 8'hFF; }
  constraint DA_diff_SOF           { da != 8'hFF; }
  constraint length_diff_SOF       { length != 8'hFF; }
  constraint DA_memory_data_value  { (random_DA == PREDEFINED) -> da dist { memory_data[0]:/20, memory_data[1]:/20, memory_data[2]:/20, memory_data[3]:/20}; }
  constraint length_pseudo_random  { length dist {'h05:/10,'h10:/10,'h15:/10,['h01:'h54]:/10,['h56:'hA9]:/10,['hA9:'hFE]:/10}; }
  constraint length_min_max_value  { length inside {[min_length:max_length]}; }

  function new(string name = "data_packet");
    super.new(name);
  endfunction : new

  extern function void set_parameters(int min_length = 1, int max_length = 254, bit [7:0] memory_data[4] = {1, 86, 170, 254}, random_predefined_enum random_DA = PREDEFINED);
  extern function void set_status_low(int position);
  extern function void set_all(bit[7:0] da, bit[7:0] sa, bit[7:0] length, bit[7:0] pay);
  
  extern function bit compare(data_packet item);
  extern function bit check();
  extern function void post_randomize();
  extern function void copy(data_packet item);
  extern function void reset_all();
  extern function string convert2string();  
endclass : data_packet


    
function void data_packet::copy(data_packet item);
  this.SOF     = item.SOF;
  this.EOF     = item.EOF;
  this.da      = item.da;
  this.sa      = item.sa;
  this.length  = item.length;
  this.parity  = item.parity;
  this.payload = item.payload;
endfunction

function void data_packet::set_all(bit[7:0] da, bit[7:0] sa, bit[7:0] length, bit[7:0] pay);
  bit [7:0] parity_temp = 8'h00;
  this.da = da;
  this.sa = sa;
  this.length = length;
  for(int i=0; i<length-1; i++) begin
    payload.push_front(pay);
    parity_temp = parity_temp ^ pay;
  end
  this.parity = parity_temp;
  for(int i=0; i<length+6; i++) begin
    sw_enable_in.push_front(1'b1);
  end
  sw_enable_in.push_back(1'b0);
endfunction : set_all
    
function bit data_packet::compare(data_packet item);
  `uvm_info(get_name(), $sformatf("Packet 1 to compare : %s ", this.convert2string()), UVM_DEBUG);
  `uvm_info(get_name(), $sformatf("Packet 2 to compare : %s ", item.convert2string()), UVM_DEBUG);
  if(this.SOF !== item.SOF) return 1'b0;
  if(this.EOF !== item.EOF) return 1'b0;
  if(this.da !== item.da) return 1'b0;
  if(this.sa !== item.sa) return 1'b0;
  if(this.length !== item.length) return 1'b0;
  for(int i = 0; i < this.length-1; i++) begin
    if(this.payload[i] !== item.payload[i]) return 1'b0;
  end
  if(this.parity !== item.parity) return 1'b0;
  return 1'b1;
endfunction
    
function bit data_packet::check();
  bit [7:0] parity_temp = 8'h00;
  `uvm_info(get_name(), $sformatf("Packet to check : %s ", this.convert2string()), UVM_DEBUG);
  if(this.SOF !== 8'hFF) return 1'b0;
  if(this.EOF !== 8'h55) return 1'b0;
  if(this.payload.size() != this.length-1) return 1'b0;
  for(int i = 0; i < this.length-1; i++) begin
    parity_temp = parity_temp ^ this.payload[i];
  end
  if(parity_temp !== this.parity) return 1'b0;
  return 1'b1;
endfunction

function void data_packet::set_status_low(int position);
  sw_enable_in[position] = 1'b0;
endfunction : set_status_low
    
function void data_packet::set_parameters(int min_length = 1, int max_length = 254, bit [7:0] memory_data[4] = {1, 86, 170, 254}, random_predefined_enum random_DA = PREDEFINED);
  this.max_length  = max_length;
  this.min_length = min_length;
  this.memory_data = memory_data;
  this.random_DA   = random_DA;
endfunction : set_parameters

function void data_packet::post_randomize();
  bit [7:0] temp, parity_temp = 8'h00;
  for(int i=0; i<length-1; i++) begin
    temp = $urandom_range(0,255);
    while(temp == 8'h55 || temp == 8'hFF) temp = $urandom_range(0,255);
    payload.push_front(temp);
    parity_temp = parity_temp ^ temp;
  end
  parity = parity_temp;
  for(int i=0; i<length+6; i++) begin
    sw_enable_in.push_front(1'b1);
  end
  sw_enable_in.push_back(1'b0);
endfunction : post_randomize

function string data_packet::convert2string();
  return $sformatf("SOF: 'h%0h DA: 'h%0h  SA: 'h%0h  LENGTH: 'h%0h PAYLOAD['h%0h]: %p PARITY: 'h%0h EOF: 'h%0h", SOF, da, sa, length, payload.size(), payload, parity, EOF);
endfunction : convert2string

function void data_packet::reset_all();
  this.SOF = 8'h00;
  this.da = 8'h00;
  this.sa = 8'h00;
  this.length = 8'h00;
  this.parity = 8'h00;
  this.EOF = 8'h00;
  this.payload.delete();
endfunction : reset_all