class port_agent extends uvm_agent;
  `uvm_component_utils(port_agent);
  
  port_sequencer seqr; 
  port_driver    drv;
  port_monitor   mon;
  
  port_agent_config agent_config_h;
  
  virtual port_interface port_i;
    
  function new (string name = "port_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
endclass : port_agent



function void port_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> BUILD <--"), UVM_DEBUG);

  if(!uvm_config_db#(port_agent_config)::get(this, "", "config", agent_config_h))
    `uvm_fatal(this.get_name(), "Failed to get config object");
  
  if(!uvm_config_db#(virtual port_interface)::get(this, "", "port_interface", port_i))
    `uvm_fatal(this.get_name(), "Failed to get port interface");
  
  if(agent_config_h.get_is_active() == UVM_ACTIVE) begin
    seqr = port_sequencer::type_id::create($sformatf("port_%0d_seqr", agent_config_h.get_port_number()), this);
    drv  = port_driver::type_id::create($sformatf("port_%0d_driver", agent_config_h.get_port_number()),  this); 
    uvm_config_db#(virtual port_interface)::set(this, $sformatf("port_%0d_driver*", agent_config_h.get_port_number()), "port_interface", port_i);
  end
  
  // DEFAULT PASSIVE
  mon = port_monitor:: type_id::create($sformatf("port_%0d_monitor", agent_config_h.get_port_number()),  this);
  uvm_config_db#(virtual port_interface)::set(this, $sformatf("port_%0d_monitor*", agent_config_h.get_port_number()), "port_interface", port_i);
  
  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
endfunction : build_phase

function void port_agent::connect_phase(uvm_phase phase);
  `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> CONNECT <--"), UVM_DEBUG);

  if(agent_config_h.get_is_active() == UVM_ACTIVE) begin
    drv.seq_item_port.connect(seqr.seq_item_export);
    mon.an_port.connect(seqr.export_port);
  end 

  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> CONNECT <--"), UVM_DEBUG);
endfunction : connect_phase