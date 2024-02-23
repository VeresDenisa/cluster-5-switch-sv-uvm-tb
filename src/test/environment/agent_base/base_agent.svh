class base_agent 
  #(
    string name = "base_agent",
    type ss_agent_config = base_agent_config,
    type ss_item_seqr = uvm_sequence_item, 
    type ss_item_mon = uvm_sequence_item, 
    type ss_driver = base_driver, 
    type ss_monitor = base_monitor
  ) 
extends uvm_agent;

  `uvm_component_utils(base_agent);
  
  uvm_sequencer #(ss_item_seqr) seqr; 
  ss_driver                drv;
  ss_monitor               mon;
  
  ss_agent_config agent_config_h;
  
  function new (string name = name, uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
endclass : base_agent


      
function void base_agent::build_phase(uvm_phase phase);  
  `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> BUILD <--"), UVM_DEBUG);
  super.build_phase(phase);
  
  if(!uvm_config_db#(ss_agent_config)::get(this, "", "config", agent_config_h))
    `uvm_fatal(this.get_name(), "Failed to get config object");
      
  if(agent_config_h.get_is_active() == UVM_ACTIVE) begin
    seqr = uvm_sequencer#(ss_item_seqr)::type_id::create($sformatf("%s_seqr", name), this);
    drv  = ss_driver::type_id::create($sformatf("%s_driver", name),  this); 
  end
  
  // DEFAULT PASSIVE
  mon = ss_monitor:: type_id::create($sformatf("%s_monitor", name),  this);
endfunction : build_phase
    
    
function void base_agent::connect_phase(uvm_phase phase);
  `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> CONNECT <--"), UVM_DEBUG);

  if(agent_config_h.get_is_active() == UVM_ACTIVE) begin
    drv.seq_item_port.connect(seqr.seq_item_export);
  end

  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> CONNECT <--"), UVM_DEBUG);
endfunction : connect_phase