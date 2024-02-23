class control_agent extends base_agent 
  #(
  .name("control_agent"), 
  .ss_monitor(control_monitor), 
  .ss_driver(control_driver), 
  .ss_agent_config(control_agent_config), 
  .ss_item_seqr(data_packet),
  .ss_item_mon(control_item)
  );

  `uvm_component_utils(control_agent);
  
  virtual control_interface ctrl_i;
  
  function new (string name = name, uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass : control_agent



function void control_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  if(!uvm_config_db#(virtual control_interface)::get(this, "", "control_interface", ctrl_i))
    `uvm_fatal(this.get_name(), "Failed to get control interface");
  
  if(agent_config_h.get_is_active() == UVM_ACTIVE) begin
    uvm_config_db#(virtual control_interface)::set(this, "control_agent_driver*", "control_interface", ctrl_i);
  end
  
  // DEFAULT PASSIVE
  uvm_config_db#(virtual control_interface)::set(this, "control_agent_monitor*", "control_interface", ctrl_i);
 
  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
endfunction : build_phase

function void control_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction : connect_phase