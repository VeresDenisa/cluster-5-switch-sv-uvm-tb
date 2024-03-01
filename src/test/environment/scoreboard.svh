`uvm_analysis_imp_decl(_control)
`uvm_analysis_imp_decl(_memory)
`uvm_analysis_imp_decl(_reset)
`uvm_analysis_imp_decl(_port_0)
`uvm_analysis_imp_decl(_port_1)
`uvm_analysis_imp_decl(_port_2)
`uvm_analysis_imp_decl(_port_3)

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard);
  
  uvm_analysis_imp_control #(control_item, scoreboard) an_port_control;
  uvm_analysis_imp_reset   #(reset_item,   scoreboard) an_port_reset;
  uvm_analysis_imp_memory  #(memory_item,  scoreboard) an_port_memory;
  
  uvm_analysis_imp_port_0#(port_item, scoreboard) an_port_port_0; 
  uvm_analysis_imp_port_1#(port_item, scoreboard) an_port_port_1; 
  uvm_analysis_imp_port_2#(port_item, scoreboard) an_port_port_2; 
  uvm_analysis_imp_port_3#(port_item, scoreboard) an_port_port_3; 
  
  function new (string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  extern function void build_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);
    
  extern function void write_control(control_item t);
  extern function void write_reset(reset_item t);
  extern function void write_memory(memory_item t);
    
  extern function void write_port_0(port_item t);
  extern function void write_port_1(port_item t);
  extern function void write_port_2(port_item t);
  extern function void write_port_3(port_item t);    
endclass : scoreboard


function void scoreboard::build_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("<--- ENTER PHASE: --> BUILD <--"), UVM_DEBUG);
    super.build_phase(phase);
    
    an_port_control = new("an_port_control", this);
    an_port_reset   = new("an_port_reset",   this);
    an_port_memory  = new("an_port_memory",  this);
    
    an_port_port_0 = new("an_port_port_0", this);
    an_port_port_1 = new("an_port_port_1", this);
    an_port_port_2 = new("an_port_port_2", this);
    an_port_port_3 = new("an_port_port_3", this);

    `uvm_info(get_name(), $sformatf("---> EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
  endfunction : build_phase
    
      
  function void scoreboard::write_control(control_item t);
    `uvm_info(get_name(), $sformatf("Received item : %s ", t.convert2string()), UVM_FULL);
  endfunction : write_memory
  
  function void scoreboard::write_reset(reset_item t);
    `uvm_info(get_name(), $sformatf("Received reset : %s ", t.convert2string()), UVM_FULL);
  endfunction : write_reset
     
  function void scoreboard::write_port_0(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 0 : %s ", t.convert2string()), UVM_FULL);
  endfunction : write_port_0
  
  function void scoreboard::write_port_1(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 1 : %s ", t.convert2string()), UVM_FULL);
  endfunction : write_port_1
  
  function void scoreboard::write_port_2(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 2 : %s ", t.convert2string()), UVM_FULL);
  endfunction : write_port_2
  
  function void scoreboard::write_port_3(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 3 : %s ", t.convert2string()), UVM_FULL);
  endfunction : write_port_3
  
    
  function void scoreboard::report_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("---> EXIT PHASE: --> REPORT <--"), UVM_MEDIUM);
    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> REPORT <--"), UVM_MEDIUM);
  endfunction : report_phase
