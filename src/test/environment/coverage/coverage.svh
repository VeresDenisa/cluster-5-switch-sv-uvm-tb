class coverage extends uvm_component;
  `uvm_component_utils(coverage);
  
  uvm_analysis_imp_port_0 #(port_item, coverage) an_port_port_0;
  uvm_analysis_imp_port_1 #(port_item, coverage) an_port_port_1;
  uvm_analysis_imp_port_2 #(port_item, coverage) an_port_port_2;
  uvm_analysis_imp_port_3 #(port_item, coverage) an_port_port_3;
  
  uvm_analysis_imp_control #(control_item, coverage) an_port_control;
  uvm_analysis_imp_reset   #(reset_item,   coverage) an_port_reset;
  uvm_analysis_imp_memory  #(memory_item,  coverage) an_port_memory;
  
  port_item    port_itm[4];  
  memory_item  memory_itm;  
  reset_item   reset_itm;  
  control_item control_itm;
  
  data_packet  data_pck;
  int position;
  
  port_covergroup    port_cvg[4];
  memory_covergroup  memory_cvg;
  control_covergroup control_cvg;
  data_covergroup    data_cvg;
  
  event_covergroup   event_cvg;
  
  function new(string name = "coverage", uvm_component parent = null);
    super.new(name, parent);
    
    an_port_port_0 = new("an_port_port_0", this);
    an_port_port_1 = new("an_port_port_1", this);
    an_port_port_2 = new("an_port_port_2", this);
    an_port_port_3 = new("an_port_port_3", this);
    
    an_port_control = new("an_port_control", this);
    an_port_reset   = new("an_port_reset",   this);
    an_port_memory  = new("an_port_memory",  this);
    
    foreach(port_cvg[i]) begin
      port_itm[i] = new("port_itm");
      port_cvg[i] = new(port_itm[i]);
    end
    
    memory_itm = new("memory_itm");
    memory_cvg = new(memory_itm);
    
    control_itm = new("control_itm");
    control_cvg = new(control_itm);
    
    data_pck = new("data_pck");
    data_cvg = new(data_pck);
    position = 0;
    
    event_cvg = new(port_itm[0], port_itm[1], port_itm[2], port_itm[3], control_itm, memory_itm);
    
  endfunction : new
  
  
  extern function void write_port_0(port_item t); 
  extern function void write_port_1(port_item t); 
  extern function void write_port_2(port_item t); 
  extern function void write_port_3(port_item t);
    
  extern function void write_control(control_item t);      
  extern function void write_memory(memory_item t);      
  extern function void write_reset(reset_item t);  
    
  extern function void report_phase(uvm_phase phase);
endclass : coverage


function void coverage::write_port_0(port_item t);
  port_itm[0] = t;
  port_cvg[0].sample;
endfunction : write_port_0

function void coverage::write_port_1(port_item t);
  port_itm[1] = t;
  port_cvg[1].sample;
endfunction : write_port_1

function void coverage::write_port_2(port_item t);
  port_itm[2] = t;
  port_cvg[2].sample();
endfunction : write_port_2

function void coverage::write_port_3(port_item t);
  port_itm[3] = t;
  port_cvg[3].sample();
endfunction : write_port_3
    
    
function void coverage::write_control(control_item t);
  control_itm = t;
  control_cvg.sample();
  event_cvg.sample();
  
  if(t.sw_enable_in == 1'b1) begin : build_data_packet
    case(position)
      0: data_pck.da = t.data_in;
      1: data_pck.sa = t.data_in;
      2: data_pck.length = t.data_in;
      default: data_pck.payload.push_back(t.data_in);
    endcase
    position++;
    if(position >= 3 && data_pck.length == data_pck.payload.size()) begin : build_data_packet_done
      data_cvg.sample();
      data_pck.payload.delete();
    end : build_data_packet_done
  end : build_data_packet
  else begin : reset_data_packet
    position = 0;
    data_pck.payload.delete();
  end : reset_data_packet
endfunction : write_control
    
function void coverage::write_memory(memory_item t);
  memory_itm = t;  
  memory_cvg.sample();
  event_cvg.sample();
endfunction : write_memory
    
function void coverage::write_reset(reset_item t);
endfunction : write_reset


function void coverage::report_phase(uvm_phase phase);
  `uvm_info(get_name(), $sformatf("---> EXIT PHASE: --> REPORT <--"), UVM_DEBUG);
  `uvm_info(get_name(), $sformatf("Ports coverage   = %.2f%%", port_cvg[0].get_coverage()), UVM_LOW);
  `uvm_info(get_name(), $sformatf("Memory coverage  = %.2f%%", memory_cvg.get_coverage()),  UVM_LOW);
  `uvm_info(get_name(), $sformatf("Control coverage = %.2f%%", control_cvg.get_coverage()), UVM_LOW);
  `uvm_info(get_name(), $sformatf("Data coverage    = %.2f%%", data_cvg.get_coverage()),    UVM_LOW);
  `uvm_info(get_name(), $sformatf("Event coverage   = %.2f%%", event_cvg.get_coverage()),   UVM_LOW);
  `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> REPORT <--"), UVM_DEBUG);
endfunction : report_phase
