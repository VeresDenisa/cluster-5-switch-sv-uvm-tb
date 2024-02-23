/*-----------------------------------------------------------------------------------------

     --- SS Testing with UVM --- ENVIRONMENT ---
     
This is the test environment for the Simple Switch.

For unit testing it contains 7 agents:
	- 1 memory agent  - ACTIVE
	- 1 reset agent   - ACTIVE
	- 1 control agent - ACTIVE
	- 4 port agents   - REACTIVE
For cluster testing the control and port agents becomes PASSIVE.

It also contains the scoreboard and the coverage.

In the build phase all of these components are created and configured.

In the connect phase the agents monitors are connected to the scoreboard and coverage, and
the port's sequencers are connected to the virtual sequencer.

-----------------------------------------------------------------------------------------*/


class environment extends uvm_env;
  `uvm_component_utils(environment);
    
  reset_agent rst_agent;
  control_agent ctrl_agent;
  memory_agent  mem_agent;
  port_agent prt_agent[4];
  
  virtual_sequencer v_seqr;
  
  scoreboard scb;
  coverage   cov;
  
  environment_config   env_config;
  
  reset_agent_config   agent_config_reset;
  control_agent_config agent_config_control;
  memory_agent_config  agent_config_memory;
  
  port_agent_config agent_config_port[4];
  
  function new (string name = "environment", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
endclass : environment



function void environment::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> BUILD <--"), UVM_DEBUG);
  
  if(!uvm_config_db #(environment_config)::get(this, "", "config", env_config))
    `uvm_fatal(this.get_name(), "Failed to get environment config");
  
  agent_config_reset   = new(.is_active(UVM_ACTIVE));
  agent_config_control = new(.is_active(UVM_ACTIVE));
  agent_config_memory  = new(.is_active(UVM_ACTIVE));
  
  foreach(agent_config_port[i]) begin
    agent_config_port[i] = new(.is_active(UVM_ACTIVE), .port_number(i));
    uvm_config_db #(port_agent_config)::set(this, $sformatf("port_%0d_agent*", i), "config", agent_config_port[i]);
    prt_agent[i] = port_agent::type_id::create($sformatf("port_%0d_agent", agent_config_port[i].get_port_number()), this);
  end
      
  uvm_config_db #(reset_agent_config)  ::set(this, "rst_agent*",  "config", agent_config_reset);
  uvm_config_db #(control_agent_config)::set(this, "ctrl_agent*", "config", agent_config_control);
  uvm_config_db #(memory_agent_config) ::set(this, "mem_agent*",  "config", agent_config_memory);
  
  rst_agent  = reset_agent::type_id::create("rst_agent", this);
  ctrl_agent = control_agent::type_id::create("ctrl_agent", this);
  mem_agent  = memory_agent:: type_id::create("mem_agent",  this);
    
  v_seqr = virtual_sequencer::type_id::create("virtual_sequencer", this);
  
  //scb = scoreboard::type_id::create("scb", this);
  cov = coverage::  type_id::create("cov", this);  
  
  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
endfunction : build_phase

function void environment::connect_phase(uvm_phase phase);
  foreach(prt_agent[i]) begin
    v_seqr.port_seqr[i] = prt_agent[i].seqr;
  end

  /*
  ctrl_agent.mon.an_port.connect(scb.an_port_control);
  mem_agent.mon.an_port.connect(scb.an_port_memory);
  rst_agent.mon.an_port.connect(scb.an_port_reset);
  
  prt_agent[0].mon.an_port.connect(scb.an_port_port_0);
  prt_agent[1].mon.an_port.connect(scb.an_port_port_1);
  prt_agent[2].mon.an_port.connect(scb.an_port_port_2);
  prt_agent[3].mon.an_port.connect(scb.an_port_port_3);
  */
  
  prt_agent[0].mon.an_port.connect(cov.an_port_port_0);
  prt_agent[1].mon.an_port.connect(cov.an_port_port_1);
  prt_agent[2].mon.an_port.connect(cov.an_port_port_2);
  prt_agent[3].mon.an_port.connect(cov.an_port_port_3);  
  
  ctrl_agent.mon.an_port.connect(cov.an_port_control);
  mem_agent.mon.an_port.connect(cov.an_port_memory);
  rst_agent.mon.an_port.connect(cov.an_port_reset);
endfunction : connect_phase