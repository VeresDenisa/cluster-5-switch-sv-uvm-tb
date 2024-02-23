class reset_driver extends base_driver #(.name("reset_driver"), .ss_item(reset_item));
  `uvm_component_utils(reset_driver);
  
  virtual reset_interface rst_i;
  
  reset_item item;
  
  function new (string name = name, uvm_component parent = null);
    super.new(name, parent);
  endfunction : new 
  
  extern function void build_phase (uvm_phase phase);
  extern task reset_phase(uvm_phase phase);
  extern task main_phase(uvm_phase phase);
endclass : reset_driver



function void reset_driver::build_phase (uvm_phase phase);
  super.build_phase(phase);
  
  `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> BUILD <--"), UVM_DEBUG);

  if(!uvm_config_db#(virtual reset_interface)::get(this, "", "reset_interface", rst_i))
    `uvm_fatal(this.get_name(), "Failed to get reset interface");

  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
endfunction : build_phase

task reset_driver::reset_phase(uvm_phase phase);
  `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> RESET <--"), UVM_DEBUG);

  super.reset_phase(phase);
  
  phase.raise_objection(this);
  rst_i.reset <= 1'b1;
  @(rst_i.driver) rst_i.reset <= 1'b0;
  @(rst_i.driver) rst_i.reset <= 1'b1;
  phase.drop_objection(this);

  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> RESET <--"), UVM_DEBUG);
endtask : reset_phase

task reset_driver::main_phase(uvm_phase phase);
  super.main_phase(phase);
  
  `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> MAIN <--"), UVM_DEBUG);

  forever begin : command_loop
    seq_item_port.get_next_item(item);
    
    rst_i.send(item);
    `uvm_info(get_name(), $sformatf("Drive reset: %s", item.convert2string), UVM_LOW);
    
    seq_item_port.item_done();
  end : command_loop
  
  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> MAIN <--"), UVM_DEBUG);
endtask : main_phase