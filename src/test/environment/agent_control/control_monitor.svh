class control_monitor extends base_monitor #(.name("control_monitor"));
  `uvm_component_utils(control_monitor)
  
  virtual control_interface ctrl_i;
  
  uvm_analysis_port #(control_item) an_port;
  
  control_item item_current, item_previous;
  
  function new (string name = name, uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  extern function void build_phase (uvm_phase phase);
  extern task run_phase(uvm_phase phase);  
endclass : control_monitor



function void control_monitor::build_phase (uvm_phase phase);
  super.build_phase(phase);
  
  `uvm_info(this.get_name(), $sformatf("---> ENTER PHASE: --> BUILD <--"), UVM_DEBUG);

  item_current = new();
  item_previous = new();
  an_port = new("mon_an_port", this);
  
  if(!uvm_config_db#(virtual control_interface)::get(this, "", "control_interface", ctrl_i))
    `uvm_fatal(this.get_name(), "Failed to get control interface");  
  
  `uvm_info(this.get_name(), $sformatf("<--- EXIT PHASE: --> BUILD <--"), UVM_DEBUG); 
endfunction : build_phase

task control_monitor::run_phase(uvm_phase phase);
  `uvm_info(this.get_name(), $sformatf("---> ENTER PHASE: --> RUN <--"), UVM_DEBUG);

  forever begin : forever_monitor
    @(ctrl_i.monitor);
    ctrl_i.receive(item_current);
    if(!item_current.compare(item_previous) || item_current.sw_enable_in) begin
      `uvm_info(this.get_name(), $sformatf("%s", item_current.convert2string), UVM_FULL);
      item_previous.copy(item_current);
      an_port.write(item_current);
    end
  end : forever_monitor
  
  `uvm_info(this.get_name(), $sformatf("<--- EXIT PHASE: --> RUN <--"), UVM_DEBUG);
endtask : run_phase