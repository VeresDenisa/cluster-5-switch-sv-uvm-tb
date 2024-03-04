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

  extern function void write_port(port_item t, int port_index);

  bit [7:0]port_queue[4][$];
  bit transaction_started;
  
  bit port_known;
  int port_current;
  
  bit [7:0]mem_data[4];
  int port_indexes[$];

  control_item control_item_prev;
  memory_item memory_item_prev;

  port_item port_item_prev_prev[4];
  port_item port_item_prev[4];
  port_item port_item_temp[4];
endclass : scoreboard


function void scoreboard::build_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("<--- ENTER PHASE: --> BUILD <--"), UVM_DEBUG);
    super.build_phase(phase);

    for(int i = 0; i < 4; i++) begin
      mem_data[i] = 8'h00;
      port_item_prev_prev[i] = new("port_item_prev_prev");
      port_item_prev[i] = new("port_item_prev");
      port_item_temp[i] = new("port_item_temp");
    end

    control_item_prev = new("control_item_prev");
    memory_item_prev = new("memory_item_prev");

    transaction_started = 1'b0;
    port_known = 1'b0;
    
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
    if(control_item_prev.sw_enable_in === 1'b1) begin : receiving_transaction
      case(t.data_in)
        8'hFF : begin : begining_of_transaction
          `uvm_info(get_name(), $sformatf("Transaction started (SOF received)."), UVM_DEBUG);
          transaction_started = 1'b1;
        end : begining_of_transaction
        8'h55 : begin : end_of_transaction
          `uvm_info(get_name(), $sformatf("Transaction finished (EOF received)."), UVM_DEBUG);
          port_queue[port_current].push_back(t.data_in);
          transaction_started = 1'b0;
          port_known = 1'b0;
        end : end_of_transaction
        default : begin : middle_of_transaction
          if(transaction_started === 1'b1 && port_known === 1'b0) begin : choose_port
            `uvm_info(get_name(), $sformatf("Add item to input packet at the beginning of transaction."), UVM_DEBUG);
            port_indexes = mem_data.find_index with (item == t.data_in);
            if(port_indexes.size() > 0) begin : DA_is_mem
              port_known = 1'b1; 
              port_current = port_indexes.pop_front();
              `uvm_info(get_name(), $sformatf("Memory data and received DA match."), UVM_DEBUG);
              port_queue[port_current].push_back(8'hFF);
              port_queue[port_current].push_back(t.data_in);
            end : DA_is_mem
            else begin : DA_is_not_mem
              `uvm_info(get_name(), $sformatf("Memory data and received DA don't match."), UVM_DEBUG);
            end : DA_is_not_mem
          end : choose_port
          else if(transaction_started === 1'b1) begin : middle_of_packet
            `uvm_info(get_name(), $sformatf("Add item to input packet in middle of transaction."), UVM_DEBUG);
            port_queue[port_current].push_back(t.data_in);
          end : middle_of_packet
        end : middle_of_transaction
      endcase
    end : receiving_transaction
    control_item_prev.copy(t);
  endfunction : write_control    

  function void scoreboard::write_port(port_item t, int port_index);
    if(port_item_prev_prev[port_index].read === 1'b1 && port_item_prev_prev[port_index].ready === 1'b1) begin : port_read_activated
      port_item_temp[port_index].port = port_queue[port_index].pop_front();
      if(t.port === port_item_temp[port_index].port) begin : correct_port_read
        `uvm_info(get_name(), $sformatf("MATCH port read from port %0h : %0h.", port_index, t.port), UVM_DEBUG);
      end : correct_port_read
      else begin : incorrect_port_read
        `uvm_info(get_name(), $sformatf("MISS port read from port %0h : expected %0h; received %0h.", port_index, port_item_temp[port_index].port, t.port), UVM_LOW);
        port_queue[port_index].push_front(port_item_temp[port_index].port);
      end : incorrect_port_read
    end : port_read_activated
    port_item_prev_prev[port_index].copy(port_item_prev[port_index]);
    port_item_prev[port_index].copy(t);
  endfunction : write_port
           
  function void scoreboard::write_port_0(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 0 : %s ", t.convert2string()), UVM_FULL);
    write_port(t, 0);
  endfunction : write_port_0
  
  function void scoreboard::write_port_1(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 1 : %s ", t.convert2string()), UVM_FULL);
    write_port(t, 1);
  endfunction : write_port_1
  
  function void scoreboard::write_port_2(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 2 : %s ", t.convert2string()), UVM_FULL);
    write_port(t, 2);
  endfunction : write_port_2
  
  function void scoreboard::write_port_3(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 3 : %s ", t.convert2string()), UVM_FULL);
    write_port(t, 3);
  endfunction : write_port_3  
  
  function void scoreboard::write_memory(memory_item t);
    `uvm_info(get_name(), $sformatf("Received item : %s ", t.convert2string()), UVM_FULL);
    if(memory_item_prev.mem_sel_en === 1'b1) begin : memory_activated
      `uvm_info(get_name(), $sformatf("Memory access activated."), UVM_DEBUG);
      if(memory_item_prev.mem_addr >= 4) begin : incorrect_memory_address
        `uvm_info(get_name(), $sformatf("Incorrect memory port number %0h.", memory_item_prev.mem_addr), UVM_DEBUG);
      end : incorrect_memory_address
      else 
        if(memory_item_prev.mem_wr_rd_s === 1'b1) begin : memory_write
          `uvm_info(get_name(), $sformatf("Correct port %0h address changed from %0h to %0h.", memory_item_prev.mem_addr, mem_data[memory_item_prev.mem_addr], t.mem_wr_data), UVM_DEBUG);
          mem_data[memory_item_prev.mem_addr] = t.mem_wr_data;
        end : memory_write
        else begin : memory_read
          if(mem_data[memory_item_prev.mem_addr] === t.mem_rd_data>>(8*memory_item_prev.mem_addr)) begin : correct_memory_read
            `uvm_info(get_name(), $sformatf("Correct memory read from port %0h : %0h.", memory_item_prev.mem_addr, t.mem_rd_data>>(8*memory_item_prev.mem_addr)), UVM_DEBUG);
          end : correct_memory_read
          else begin : incorrect_memory_read
            `uvm_info(get_name(), $sformatf("Incorrect memory read from port %0h : %0h.", memory_item_prev.mem_addr, t.mem_rd_data>>(8*memory_item_prev.mem_addr)), UVM_LOW);
          end : incorrect_memory_read
        end : memory_read
    end : memory_activated
    else begin : memory_deactivated
      `uvm_info(get_name(), $sformatf("Memory access deactivated."), UVM_DEBUG);
    end : memory_deactivated
    memory_item_prev.copy(t);
  endfunction : write_memory
  
  function void scoreboard::write_reset(reset_item t);
    `uvm_info(get_name(), $sformatf("Received reset : %s ", t.convert2string()), UVM_FULL);
    if(t.reset == 1'b0) begin : reset_all
      `uvm_info(get_name(), $sformatf("Reset acivated : %s ", t.convert2string()), UVM_FULL);
      port_known = 1'b0;
      transaction_started = 1'b0;
      for(int i = 0; i < 4; i++) begin
        mem_data[i] = 8'h00;
        port_item_prev_prev[i].read = 1'b0;
        port_item_prev[i].read = 1'b0;
        port_item_temp[i].read = 1'b0;
        port_item_prev_prev[i].ready = 1'b0;
        port_item_prev[i].ready = 1'b0;
        port_item_temp[i].ready = 1'b0;
      end
    end: reset_all    
  endfunction : write_reset
  
    
  function void scoreboard::report_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("---> EXIT PHASE: --> REPORT <--"), UVM_MEDIUM);
    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> REPORT <--"), UVM_MEDIUM);
  endfunction : report_phase
