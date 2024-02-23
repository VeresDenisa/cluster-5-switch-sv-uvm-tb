class memory_driver extends base_driver #(.name("memory_driver"), .ss_item(memory_item));
  `uvm_component_utils(memory_driver);
  
  virtual memory_interface mem_i;
  
  memory_item item;
  
  function new (string name = name, uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  extern function void build_phase (uvm_phase phase);
  extern task reset_phase(uvm_phase phase);
  extern task configure_phase(uvm_phase phase);
  extern task main_phase(uvm_phase phase);
endclass : memory_driver



function void memory_driver::build_phase (uvm_phase phase);
  super.build_phase(phase);
  
  `uvm_info(this.get_name(), $sformatf("---> ENTER PHASE: --> BUILD <--"), UVM_DEBUG);

  item = new();
  
  if(!uvm_config_db#(virtual memory_interface)::get(this, "", "memory_interface", mem_i))
    `uvm_fatal(this.get_name(), "Failed to get memory interface");

  `uvm_info(this.get_name(), $sformatf("<--- EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
endfunction : build_phase

task memory_driver::reset_phase(uvm_phase phase);
  super.reset_phase(phase);
  
  `uvm_info(this.get_name(), $sformatf("---> ENTER PHASE: --> RESET <--"), UVM_DEBUG);

  phase.raise_objection(this);
  mem_i.mem_wr_data <= 8'h00;
  mem_i.mem_addr    <= 2'b00;
  mem_i.mem_sel_en  <= 1'b0;
  mem_i.mem_wr_rd_s <= 1'b0;
  phase.drop_objection(this);

  `uvm_info(this.get_name(), $sformatf("<--- EXIT PHASE: --> RESET <--"), UVM_DEBUG);
endtask : reset_phase

task memory_driver::configure_phase(uvm_phase phase);
  logic [7:0]first_n_memory_config_data[4];
  super.configure_phase(phase);
  
  `uvm_info(this.get_name(), $sformatf("---> ENTER PHASE: --> CONFIGURE <--"), UVM_DEBUG);

  phase.raise_objection(this);

  item.set_item(8'h00, 2'b00, 1'b1, 1'b1);
  mem_i.send(item);

  foreach(first_n_memory_config_data[i]) begin
    if(!uvm_config_db #(logic[7:0])::get(this, "", $sformatf("mem_data[%0d]", i), first_n_memory_config_data[i]))
      `uvm_fatal(this.get_name(), "Failed to get memory initial configuration data");
    if(i == 3) item.set_item(first_n_memory_config_data[i], 2'b00, 1'b0, 1'b0);
    else item.set_item(first_n_memory_config_data[i], i[1:0]+1, 1'b1, 1'b1);
    mem_i.send(item);
  end


  
  item.set_item(8'h00, 2'b00, 1'b0, 1'b0);
  mem_i.send(item);
  mem_i.send(item);
  
  phase.drop_objection(this);
  
  `uvm_info(this.get_name(), $sformatf("<--- EXIT PHASE: --> CONFIGURE <--"), UVM_DEBUG);
endtask : configure_phase  
    
    
task memory_driver::main_phase(uvm_phase phase);
  super.main_phase(phase);
  
  `uvm_info(this.get_name(), $sformatf("---> ENTER PHASE: --> MAIN <--"), UVM_DEBUG);

  forever begin : command_loop
    seq_item_port.get_next_item(item);
    mem_i.send(item);
    seq_item_port.item_done();
  end : command_loop
  
  `uvm_info(this.get_name(), $sformatf("<--- EXIT PHASE: --> MAIN <--"), UVM_DEBUG);
endtask : main_phase