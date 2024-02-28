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

  bit [7:0] port_queue[4][$];
  
  bit [7:0] mem_data[4];
  int port_indexes[$];

  port_item port_prev[4], port_prev_prev[4];
  port_item port_temp[4];

  bit status_prev, status_prev_prev;
  memory_item mem_prev;

  bit port_unknown;
  int port_current;

  int miss[4], match[4]; // all and any individual miss/matchs 
  
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
  
  extern function void check_packet(port_item t, int port_ind);      
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

    for(int i = 0; i < 4; i++) begin
      mem_data[i] = 8'h00;
      port_prev[i] = new("port_prev");
      port_prev[i].read = 1'b0;
      port_prev[i].ready = 1'b0;  
      port_prev_prev[i] = new("port_prev_prev");
      port_prev_prev[i].read = 1'b0;
      port_prev_prev[i].ready = 1'b0;  
      port_temp[i] = new("port_temp");
      miss[i] = 0;
      match[i] = 0;
    end
    
    mem_prev = new("mem_prev");
    port_unknown = 1'b0;
    port_current = 0;
    status_prev = 1'b0; 
    status_prev_prev = 1'b0; 
  
    `uvm_info(get_name(), $sformatf("---> EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
  endfunction : build_phase
    
    
  
  function void scoreboard::write_control(control_item t);
    `uvm_info(get_name(), $sformatf("Received item : %s ", t.convert2string()), UVM_FULL);
    
    if(status_prev === 1'b1 && status_prev_prev === 1'b1 && t.data_in !== 8'h00) begin : data_status_activated
      `uvm_info(get_name(), $sformatf("Data status active."), UVM_DEBUG);
      if(port_unknown !== 1'b0) begin : middle_of_transaction
        `uvm_info(get_name(), $sformatf("Add item to input packet in middle of transaction."), UVM_DEBUG);
        port_queue[port_current].push_back(t.data_in);
      end : middle_of_transaction
      else if(port_unknown === 1'b0) begin : choose_port
        `uvm_info(get_name(), $sformatf("Add item to input packet at the beginning of transaction."), UVM_DEBUG);
        port_indexes = mem_data.find_index with (item == t.data_in);
        if(port_indexes.size() > 0) begin : DA_is_mem
          port_unknown = 1'b1; 
          port_current = port_indexes.pop_front(); 
          port_queue[port_current].push_back(8'hFF);
          port_queue[port_current].push_back(t.data_in);
          `uvm_info(get_name(), $sformatf("Memory data and received item match at beginning of transaction."), UVM_DEBUG);
        end : DA_is_mem
        else begin
          `uvm_info(get_name(), $sformatf("Memory data and received item don't match at beginning of transaction."), UVM_DEBUG);
        end
      end : choose_port 
    end : data_status_activated
    else begin : data_status_deactivated
      `uvm_info(get_name(), $sformatf("Data status inactive."), UVM_DEBUG);
      `uvm_info(get_name(), $sformatf("End of input transaction. Finish packet."), UVM_DEBUG);
      port_unknown = 1'b0;
    end : data_status_deactivated
    status_prev_prev = status_prev;
    status_prev = t.sw_enable_in;
  endfunction : write_control
  
  function void scoreboard::write_memory(memory_item t);
    `uvm_info(get_name(), $sformatf("Received item : %s ", t.convert2string()), UVM_FULL);
    if(mem_prev.mem_sel_en && mem_prev.mem_wr_rd_s && mem_prev.mem_addr >= 0 && mem_prev.mem_addr <= 3) begin
      `uvm_info(get_name(), $sformatf("Memory data changed."), UVM_DEBUG);
      mem_data[mem_prev.mem_addr] = t.mem_wr_data;
    end
    mem_prev.copy(t);
  endfunction : write_memory
  
  function void scoreboard::write_reset(reset_item t);
    `uvm_info(get_name(), $sformatf("Received reset : %s ", t.convert2string()), UVM_FULL);
    if(t.reset == 1'b0) begin : reset_all
      `uvm_info(get_name(), $sformatf("Reset acivated : %s ", t.convert2string()), UVM_FULL);
      for(int i = 0; i < 4; i++) begin
        port_prev[i].read = 1'b0;
        port_prev[i].ready = 1'b0;
        port_prev_prev[i].read = 1'b0;
        port_prev_prev[i].ready = 1'b0;
        port_queue[i].delete();
      end 
      port_current = 0;
      port_unknown = 1'b0;
      status_prev = 1'b0;
      status_prev_prev = 1'b0;
      mem_prev.set_item(2'h00, 2'h00, 1'b0, 1'b0);
    end: reset_all    
  endfunction : write_reset
  
     
  function void scoreboard::check_packet(port_item t, int port_ind);
    if(t.port !== 8'h00 && port_prev[port_ind].read == 1'b1 && port_prev[port_ind].ready == 1'b1 && port_prev_prev[port_ind].read == 1'b1 && port_prev_prev[port_ind].ready == 1'b1 && t.ready == 1'b1) begin : read_port
      `uvm_info(get_name(), $sformatf("A valid read was made from port %0d.", port_ind), UVM_DEBUG);
      port_temp[port_ind].port = port_queue[port_ind].pop_front();
      
      if(t.port === port_temp[port_ind].port) begin
        match[port_ind]++;
        `uvm_info(get_name(), $sformatf("MATCH"), UVM_DEBUG);
      end else begin
        miss[port_ind]++;
        `uvm_info(get_name(), $sformatf("MISS"), UVM_LOW);
      end
    end : read_port
    port_prev_prev[port_ind].copy(port_prev[port_ind]);
    port_prev[port_ind].copy(t);
  endfunction : check_packet

   
  function void scoreboard::write_port_0(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 0 : %s ", t.convert2string()), UVM_FULL);
    check_packet(t, 0);  
  endfunction : write_port_0
  
  function void scoreboard::write_port_1(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 1 : %s ", t.convert2string()), UVM_FULL);
    check_packet(t, 1);   
  endfunction : write_port_1
  
  function void scoreboard::write_port_2(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 2 : %s ", t.convert2string()), UVM_FULL);
    check_packet(t, 2);   
  endfunction : write_port_2
  
  function void scoreboard::write_port_3(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 3 : %s ", t.convert2string()), UVM_FULL);
    check_packet(t, 3);   
  endfunction : write_port_3
  
    
  function void scoreboard::report_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("---> EXIT PHASE: --> REPORT <--"), UVM_MEDIUM);
    for(int i = 0; i < 4; i++) begin
      `uvm_info(get_name(), $sformatf("PORT %0d: Number of matched 8 bits: %0d", i, match[i]), UVM_LOW);
      `uvm_info(get_name(), $sformatf("PORT %0d: Number of missed 8 bits: %0d", i, miss[i]), UVM_LOW);
    end
    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> REPORT <--"), UVM_MEDIUM);
  endfunction : report_phase
