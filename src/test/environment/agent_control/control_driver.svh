class control_driver extends base_driver #(.name("control_driver"), .ss_item(data_packet));
  `uvm_component_utils(control_driver);
  
  virtual control_interface ctrl_i;
  
  data_packet item;
  
  function new (string name = name, uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  extern function void build_phase (uvm_phase phase);  
  extern task reset_phase(uvm_phase phase);
  extern task main_phase(uvm_phase phase);
endclass : control_driver
  


function void control_driver::build_phase (uvm_phase phase);
  super.build_phase(phase);
  
  `uvm_info(this.get_name(), $sformatf("---> ENTER PHASE: --> BUILD <--"), UVM_DEBUG);

  if(!uvm_config_db#(virtual control_interface)::get(this, "", "control_interface", ctrl_i))
    `uvm_fatal(this.get_name(), "Failed to get control interface");

  `uvm_info(this.get_name(), $sformatf("<--- EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
endfunction : build_phase

task control_driver::reset_phase(uvm_phase phase);
  super.reset_phase(phase);

  `uvm_info(this.get_name(), $sformatf("---> ENTER PHASE: --> RESET <--"), UVM_DEBUG);
  
  phase.raise_objection(this);
  ctrl_i.data_in      <= 8'h00;
  ctrl_i.sw_enable_in <= 1'b0;
  phase.drop_objection(this);

  `uvm_info(this.get_name(), $sformatf("<--- EXIT PHASE: --> RESET <--"), UVM_DEBUG);
endtask : reset_phase

task control_driver::main_phase(uvm_phase phase);
  super.main_phase(phase);

  `uvm_info(this.get_name(), $sformatf("---> ENTER PHASE: --> MAIN <--"), UVM_DEBUG);

  forever begin : driver_loop
    seq_item_port.get_next_item(item);
    
    `uvm_info(this.get_name(), $sformatf("Start to drive item: %s", item.convert2string), UVM_HIGH);
    ctrl_i.send(item);
    `uvm_info(this.get_name(), $sformatf("Finish to drive item: %s", item.convert2string), UVM_HIGH);
    
    seq_item_port.item_done();
  end : driver_loop
  
  `uvm_info(this.get_name(), $sformatf("<--- EXIT PHASE: --> MAIN <--"), UVM_DEBUG);
endtask : main_phase 