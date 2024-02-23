class memory_agent extends base_agent 
  #(
  .name("memory_agent"), 
  .ss_monitor(memory_monitor), 
  .ss_driver(memory_driver), 
  .ss_agent_config(memory_agent_config), 
  .ss_item_seqr(memory_item),
  .ss_item_mon(memory_item)
  );

  `uvm_component_utils(memory_agent);
  
  virtual memory_interface mem_i;
  
  function new (string name = name, uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass : memory_agent



function void memory_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  if(!uvm_config_db#(virtual memory_interface)::get(this, "", "memory_interface", mem_i))
    `uvm_fatal(this.get_name(), "Failed to get memory interface");
  
  if(agent_config_h.get_is_active() == UVM_ACTIVE) begin
    uvm_config_db#(virtual memory_interface)::set(this, "memory_agent_driver*", "memory_interface", mem_i);
  end
  
  // DEFAULT PASSIVE
  uvm_config_db#(virtual memory_interface)::set(this, "memory_agent_monitor*", "memory_interface", mem_i);

  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
endfunction : build_phase

function void memory_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction : connect_phase