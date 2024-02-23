class reset_monitor extends base_monitor #(.name("reset_monitor"));
  `uvm_component_utils(reset_monitor)
  
  virtual reset_interface rst_i;
  
  uvm_analysis_port #(reset_item) an_port;
  
  reset_item item_previous, item_current;
  
  function new (string name = name, uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  extern function void build_phase (uvm_phase phase);
  extern task run_phase(uvm_phase phase);
endclass : reset_monitor



function void reset_monitor::build_phase (uvm_phase phase);
  super.build_phase(phase);
  
  `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> BUILD <--"), UVM_DEBUG);
  
  item_previous = new();
  item_current = new();
  an_port = new("mon_an_port", this);
  
  if(!uvm_config_db#(virtual reset_interface)::get(this, "", "reset_interface", rst_i))
    `uvm_fatal(this.get_name(), "Failed to get reset interface");   

  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> BUILD <--"), UVM_DEBUG); 
endfunction : build_phase

task reset_monitor::run_phase(uvm_phase phase);
  `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> RUN <--"), UVM_DEBUG);

  forever begin : forever_monitor
    @(rst_i.monitor);
    rst_i.receive(item_current);
    if(!item_current.compare(item_previous)) begin
      `uvm_info(get_name(), item_current.reset?$sformatf("Reset inactive!"):$sformatf("Reset active!"), UVM_LOW);
      item_previous.reset = item_current.reset;
      an_port.write(item_current);
    end
  end : forever_monitor
  
  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> RUN <--"), UVM_DEBUG);
endtask : run_phase
