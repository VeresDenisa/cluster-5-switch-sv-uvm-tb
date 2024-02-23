class port_sequencer extends uvm_sequencer #(port_item);
  `uvm_component_utils(port_sequencer);
  
  uvm_analysis_export   #(port_item) export_port;
  uvm_tlm_analysis_fifo #(port_item) fifo;
  
  function new (string name = "port_sequencer", uvm_component parent = null);
    super.new(name, parent);
    
    export_port = new("export_port", this);    
    fifo        = new("fifo",        this);
  endfunction : new
  
  extern function void connect_phase(uvm_phase phase);
endclass : port_sequencer
    
    
function void port_sequencer::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  
  export_port.connect(fifo.analysis_export);
endfunction :connect_phase