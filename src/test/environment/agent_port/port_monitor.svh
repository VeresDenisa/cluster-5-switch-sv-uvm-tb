class port_monitor extends base_monitor #(.name("port_monitor"));
  `uvm_component_utils(port_monitor)
  
  virtual port_interface port_i;
  
  uvm_analysis_port #(port_item) an_port;
  
  port_item item_previous, item_current;
  
  function new (string name = name, uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  extern function void build_phase (uvm_phase phase);  
  extern task run_phase(uvm_phase phase);  
endclass : port_monitor


  
function void port_monitor::build_phase (uvm_phase phase);
  super.build_phase(phase);
  
  `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> BUILD <--"), UVM_DEBUG);
  
  item_previous = new();
  item_current = new();
  
  an_port = new("mon_an_port", this);
  
  if(!uvm_config_db#(virtual port_interface)::get(this, "", "port_interface", port_i))
    `uvm_fatal(this.get_full_name(), "Failed to get port interface");    

  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> BUILD <--"), UVM_DEBUG); 
endfunction : build_phase   

task port_monitor::run_phase(uvm_phase phase);
  `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> RUN <--"), UVM_DEBUG);

  forever begin : forever_monitor
    @(port_i.monitor);
    port_i.receive(item_current);
    if(!item_current.compare(item_previous) || item_current.ready === 1'b1) begin
      `uvm_info(get_name(), $sformatf("Monitored PORT: %s", item_current.convert2string), UVM_HIGH);
      item_previous.copy(item_current);
      an_port.write(item_current);
    end
  end : forever_monitor
  
  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> RUN <--"), UVM_DEBUG);
endtask : run_phase
