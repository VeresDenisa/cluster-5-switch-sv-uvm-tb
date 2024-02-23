class port_driver extends base_driver #(.name("port_driver"), .ss_item(port_item));
  `uvm_component_utils(port_driver);
  
  virtual port_interface port_i;
  
  port_item item;
  
  function new (string name = name, uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  extern function void build_phase (uvm_phase phase);
  extern task reset_phase(uvm_phase phase);
  extern task main_phase(uvm_phase phase);
endclass : port_driver



function void port_driver::build_phase (uvm_phase phase);
  super.build_phase(phase);
  
  `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> BUILD <--"), UVM_DEBUG);

  if(!uvm_config_db#(virtual port_interface)::get(this, "", "port_interface", port_i))
    `uvm_fatal(this.get_name(), "Failed to get port interface");

  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
endfunction : build_phase

task port_driver::reset_phase(uvm_phase phase);
  `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> RESET <--"), UVM_DEBUG);

  super.reset_phase(phase);
  
  phase.raise_objection(this);
  port_i.read <= 1'b0;
  phase.drop_objection(this);

  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> RESET <--"), UVM_DEBUG);
endtask : reset_phase

task port_driver::main_phase(uvm_phase phase);
  super.main_phase(phase);
  
  `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> MAIN <--"), UVM_DEBUG);

  forever begin : command_loop
    seq_item_port.get_next_item(item);
    
    port_i.send(item);
    
    seq_item_port.item_done();
  end : command_loop
  @(port_i.driver);
  
  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> MAIN <--"), UVM_DEBUG);
endtask : main_phase