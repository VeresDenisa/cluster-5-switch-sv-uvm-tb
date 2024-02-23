class reset_agent extends base_agent 
  #(
  .name("reset_agent"), 
  .ss_monitor(reset_monitor), 
  .ss_driver(reset_driver), 
  .ss_agent_config(reset_agent_config), 
  .ss_item_seqr(reset_item),
  .ss_item_mon(reset_item)
  );

  `uvm_component_utils(reset_agent);
  
  virtual reset_interface rst_i;
  
  function new (string name = name, uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass : reset_agent



function void reset_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  if(!uvm_config_db#(virtual reset_interface)::get(this, "", "reset_interface", rst_i))
    `uvm_fatal(this.get_name(), "Failed to get reset interface");
  
  if(agent_config_h.get_is_active() == UVM_ACTIVE) begin
    uvm_config_db#(virtual reset_interface)::set(this, "reset_agent_driver*", "reset_interface", rst_i);
  end
  
  // DEFAULT PASSIVE
  uvm_config_db#(virtual reset_interface)::set(this, "reset_agent_monitor*", "reset_interface", rst_i);
  
  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
endfunction : build_phase

function void reset_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction : connect_phase