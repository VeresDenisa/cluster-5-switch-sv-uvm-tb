class control_sequence extends uvm_sequence #(data_packet);
  `uvm_object_utils(control_sequence)
  
  data_packet packet;
  
  bit [7:0]memory_data[4];
  
  int nr_items, max_length, min_length;
  int no_delay = 0, no_random = 0;
  int duration, position, enable_status_low = 0;
  random_predefined_enum random_DA;
  
  function new (string name = "control_sequence");
    super.new(name);
  endfunction : new

  extern function void set_parameters(int nr_items = 1, int min_length = 0, int max_length = 255, random_predefined_enum random_DA = PREDEFINED, int no_delay = 1'b0, int no_random = 1'b0);
  extern function void set_status_low(int duration = 1, int position = 1, int enable_status_low = 0);
  extern function void set_da_options(bit [7:0]memory_data[4]);
    
  extern task body();
endclass : control_sequence
  

    
function void control_sequence::set_parameters(int nr_items = 1, int min_length = 0, int max_length = 255, random_predefined_enum random_DA = PREDEFINED, int no_delay = 1'b0, int no_random = 1'b0);
  this.nr_items   = nr_items;
  this.min_length = min_length;
  this.max_length = max_length;
  this.random_DA  = random_DA;
  this.no_delay   = no_delay;
  this.no_random  = no_random;
endfunction : set_parameters
    
function void control_sequence::set_status_low(int duration = 1, int position = 1, int enable_status_low = 0);
  this.duration = duration;
  this.enable_status_low = enable_status_low;
  this.position = position;
endfunction : set_status_low
    
function void control_sequence::set_da_options(bit [7:0]memory_data[4]);
  this.memory_data = memory_data;
endfunction : set_da_options

task control_sequence::body();
  `uvm_info(get_name(), $sformatf("Started sequence"), UVM_MEDIUM);
  for(int i = 1; i <= nr_items; i++) begin : loop_packets
    packet = data_packet::type_id::create("packet");
    packet.set_parameters(.min_length(min_length), .max_length(max_length), .memory_data(memory_data), .random_DA(random_DA));
    if(no_random == 0) begin
    	if(!packet.randomize())
      		`uvm_error(this.get_name(), "Failed randomization");
    end
    else packet.set_all(memory_data[i%4], memory_data[i%4], memory_data[i%4], memory_data[i%4]);
    if(enable_status_low != 0)
      packet.set_status_low(.position(position));
    if(no_delay == 1'b1) packet.delay = 0;
    start_item(packet);
    `uvm_info(get_name(), $sformatf("Created packet 'd%0d: %s", i, packet.convert2string), UVM_HIGH);
    finish_item(packet);
  end : loop_packets
  `uvm_info(get_name(), $sformatf("Finished sequence"), UVM_MEDIUM);
endtask : body
