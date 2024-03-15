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
  extern function void check_phase(uvm_phase phase);
    
  extern function void write_control(control_item t);
  extern function void write_reset(reset_item t);
  extern function void write_memory(memory_item t);
    
  extern function void write_port_0(port_item t);
  extern function void write_port_1(port_item t);
  extern function void write_port_2(port_item t);
  extern function void write_port_3(port_item t);  

  extern function void write_port(port_item t, int port_index);
  extern function void make_control_packet(control_item t);
  extern function void make_port_packet(port_item t, int port_index);

  bit [7:0]port_queue[4][$];
  bit transaction_started;
  
  bit port_known;
  int port_current;
  
  bit [7:0]mem_data[4];
  int port_indexes[$];

  control_item control_item_prev, control_item_prev_prev;
  memory_item memory_item_prev;

  port_item port_item_prev_prev[4];
  port_item port_item_prev[4];
  port_item port_item_temp[4];

  int control_packet_position, port_packet_position[4];
  int control_port_pecket_sent[$], control_port_pecket_sent_temp;
  data_packet control_packet_queue[$], port_packet_queue[4][$];
  data_packet control_packet_temp, port_packet_temp[4], port_packet_check_temp;

  int nr_of_packets_sent, nr_of_packets_received_per_port[4];
  int nr_of_packets_sent_incorrect;
  int nr_of_packets_received_per_port_missed[4];
  int nr_of_packets_received_dropped;
  int nr_of_packets_left_on_port[4];
  int byte_miss[4], byte_match[4];

  int nr_memory_write_correct, nr_memory_write_incorrect;
  int nr_memory_read_correct, nr_memory_read_incorrect;
endclass : scoreboard


function void scoreboard::build_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("<--- ENTER PHASE: --> BUILD <--"), UVM_DEBUG);
    super.build_phase(phase);

    for(int i = 0; i < 4; i++) begin
      mem_data[i] = 8'h00;
      port_item_prev_prev[i] = new("port_item_prev_prev");
      port_item_prev[i] = new("port_item_prev");
      port_item_temp[i] = new("port_item_temp");
      port_packet_temp[i] = new("port_packet_temp");
      port_packet_position[i] = 0;
      nr_of_packets_received_per_port[i] = 0;
      nr_of_packets_received_per_port_missed[i] = 0;
      nr_of_packets_left_on_port[i] = 0;
      byte_match[i] = 0;
      byte_miss[i] = 0;
    end

    nr_of_packets_received_dropped = 0;
    nr_of_packets_sent_incorrect = 0;
    nr_of_packets_sent = 0;
    
    nr_memory_write_correct = 0;
    nr_memory_write_incorrect = 0;
    nr_memory_read_correct = 0;
    nr_memory_read_incorrect = 0;

    control_item_prev = new("control_item_prev");
    control_item_prev_prev = new("control_item_prev_prev");
    memory_item_prev = new("memory_item_prev");
    control_packet_temp = new("control_packet_temp");
    port_packet_check_temp = new("port_packet_check_temp");

    transaction_started = 1'b0;
    port_known = 1'b0;
    control_packet_position = 0;
    control_port_pecket_sent_temp = 0;
    port_current = 0;
    
    an_port_control = new("an_port_control", this);
    an_port_reset   = new("an_port_reset",   this);
    an_port_memory  = new("an_port_memory",  this);
    
    an_port_port_0 = new("an_port_port_0", this);
    an_port_port_1 = new("an_port_port_1", this);
    an_port_port_2 = new("an_port_port_2", this);
    an_port_port_3 = new("an_port_port_3", this);

    `uvm_info(get_name(), $sformatf("---> EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
  endfunction : build_phase


  
  function void scoreboard::make_control_packet(control_item t);
    data_packet control_packet_temp_child = new("control_packet_temp_child");
    case(control_packet_position)
      0 : control_packet_temp.SOF = t.data_in;
      1 : control_packet_temp.da = t.data_in;
      2 : control_packet_temp.sa = t.data_in;
      3 : control_packet_temp.length = t.data_in;
      3 + control_packet_temp.length : control_packet_temp.parity = t.data_in;
      4 + control_packet_temp.length : control_packet_temp.EOF = t.data_in;
      default : control_packet_temp.payload.push_back(t.data_in);
    endcase
    control_packet_position++;
    if(t.data_in === 8'h55) begin : end_of_packet
      `uvm_info(get_name(), $sformatf("Control packet constructed : %s ", control_packet_temp.convert2string()), UVM_DEBUG);
      nr_of_packets_sent++;
      control_packet_temp_child.copy(control_packet_temp);
      control_packet_queue.push_back(control_packet_temp_child);
      control_packet_temp.reset_all();
      control_packet_position = 0;
    end : end_of_packet
  endfunction : make_control_packet
      
  function void scoreboard::write_control(control_item t);
    data_packet control_packet_temp_child = new("control_packet_temp_child");
    `uvm_info(get_name(), $sformatf("Received item : %s ", t.convert2string()), UVM_FULL);
    if(control_item_prev.sw_enable_in === 1'b1) begin : receiving_transaction
      case(t.data_in)
        8'hFF : begin : begining_of_transaction
          `uvm_info(get_name(), $sformatf("Transaction started (SOF received)."), UVM_DEBUG);
          if(transaction_started === 1'b1) port_queue[port_current].push_back(t.data_in);
          else transaction_started = 1'b1;
          make_control_packet(t);
        end : begining_of_transaction
        8'h55 : begin : end_of_transaction
          if(transaction_started === 1'b1) begin
            `uvm_info(get_name(), $sformatf("Transaction finished (EOF received)."), UVM_DEBUG);
            port_queue[port_current].push_back(t.data_in);
            make_control_packet(t);
            transaction_started = 1'b0;
            port_known = 1'b0;
          end
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
              make_control_packet(t);
              control_port_pecket_sent.push_back(port_current);
            end : DA_is_mem
            else begin : DA_is_not_mem
              `uvm_info(get_name(), $sformatf("Memory data and received DA don't match."), UVM_DEBUG);
              transaction_started = 1'b0;
              control_packet_temp.reset_all();
            end : DA_is_not_mem
          end : choose_port
          else if(transaction_started === 1'b1) begin : middle_of_packet
            `uvm_info(get_name(), $sformatf("Add item to input packet in middle of transaction."), UVM_DEBUG);
            port_queue[port_current].push_back(t.data_in);
            make_control_packet(t);
          end : middle_of_packet
        end : middle_of_transaction
      endcase
    end : receiving_transaction
    else if(control_item_prev_prev.sw_enable_in === 1'b1) begin : status_deactivated
      `uvm_info(get_name(), $sformatf("Control packet constructed : %s ", control_packet_temp.convert2string()), UVM_DEBUG);
      if(transaction_started === 1'b1) begin
        nr_of_packets_received_dropped++;
        control_packet_temp_child.copy(control_packet_temp);
        control_packet_queue.push_back(control_packet_temp_child);
        control_packet_temp.reset_all();
        control_packet_position = 0;
      end
    end : status_deactivated
    control_item_prev.copy(t);
  endfunction : write_control    

  function void scoreboard::write_port(port_item t, int port_index);
    if(port_item_prev_prev[port_index].read === 1'b1 && port_item_prev_prev[port_index].ready === 1'b1) begin : port_read_activated
      port_item_temp[port_index].port = port_queue[port_index].pop_front();
      make_port_packet(t, port_index);
      if(t.port === port_item_temp[port_index].port) begin : correct_port_read
        `uvm_info(get_name(), $sformatf("MATCH port read from port %0h : %0h.", port_index, t.port), UVM_DEBUG);
        byte_match[port_index]++;
      end : correct_port_read
      else begin : incorrect_port_read
        `uvm_info(get_name(), $sformatf("MISS port read from port %0h : expected %0h; received %0h.", port_index, port_item_temp[port_index].port, t.port), UVM_LOW);
        port_queue[port_index].push_front(port_item_temp[port_index].port);
        byte_miss[port_index]++;
      end : incorrect_port_read
    end : port_read_activated
    port_item_prev_prev[port_index].copy(port_item_prev[port_index]);
    port_item_prev[port_index].copy(t);
  endfunction : write_port

  function void scoreboard::make_port_packet(port_item t, int port_index);
    data_packet port_packet_temp_child = new("port_packet_temp_child");
    if(port_packet_position[port_index] === 0 && t.port !== 8'hFF) return;
    case(port_packet_position[port_index])
      0 : port_packet_temp[port_index].SOF = t.port;
      1 : port_packet_temp[port_index].da = t.port;
      2 : port_packet_temp[port_index].sa = t.port;
      3 : port_packet_temp[port_index].length = t.port;
      3 + port_packet_temp[port_index].length : port_packet_temp[port_index].parity = t.port;
      4 + port_packet_temp[port_index].length : port_packet_temp[port_index].EOF = t.port;
      default : port_packet_temp[port_index].payload.push_back(t.port);
    endcase
    port_packet_position[port_index]++;
    if(t.port === 8'h55) begin : end_of_packet
      `uvm_info(get_name(), $sformatf("Port %0h packet constructed : %s ", port_index, port_packet_temp[port_index].convert2string()), UVM_DEBUG);
      nr_of_packets_received_per_port[port_index]++;
      port_packet_temp_child.copy(port_packet_temp[port_index]);
      port_packet_queue[port_index].push_back(port_packet_temp_child);
      port_packet_temp[port_index].reset_all();
      port_packet_position[port_index] = 0;
    end : end_of_packet
  endfunction : make_port_packet
           
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
        nr_memory_write_incorrect++;
      end : incorrect_memory_address
      else 
        if(memory_item_prev.mem_wr_rd_s === 1'b1) begin : memory_write
          `uvm_info(get_name(), $sformatf("Correct port %0h address changed from %0h to %0h.", memory_item_prev.mem_addr, mem_data[memory_item_prev.mem_addr], t.mem_wr_data), UVM_DEBUG);
          mem_data[memory_item_prev.mem_addr] = t.mem_wr_data;
          nr_memory_write_correct++;
        end : memory_write
        else begin : memory_read
          if(mem_data[memory_item_prev.mem_addr] === t.mem_rd_data>>(8*memory_item_prev.mem_addr)) begin : correct_memory_read
            `uvm_info(get_name(), $sformatf("Correct memory read from port %0h : %0h.", memory_item_prev.mem_addr, t.mem_rd_data>>(8*memory_item_prev.mem_addr)), UVM_DEBUG);
            nr_memory_read_correct++;
          end : correct_memory_read
          else begin : incorrect_memory_read
            `uvm_info(get_name(), $sformatf("Incorrect memory read from port %0h : %0h.", memory_item_prev.mem_addr, t.mem_rd_data>>(8*memory_item_prev.mem_addr)), UVM_LOW);
            nr_memory_read_incorrect++;
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
    if(t.reset == 1'b0) begin : reset_all_signals
      `uvm_info(get_name(), $sformatf("Reset acivated : %s ", t.convert2string()), UVM_FULL);
      port_known = 1'b0;
      port_current = 0;
      transaction_started = 1'b0;
      port_indexes.delete();
      control_packet_temp.reset_all();
      control_item_prev.sw_enable_in = 1'b0;
      control_item_prev_prev.sw_enable_in = 1'b0;
      control_packet_position = 0;
      for(int i = 0; i < 4; i++) begin
        mem_data[i] = 8'h00;
        port_item_prev_prev[i].read = 1'b0;
        port_item_prev[i].read = 1'b0;
        port_item_temp[i].read = 1'b0;
        port_item_prev_prev[i].ready = 1'b0;
        port_item_prev[i].ready = 1'b0;
        port_item_temp[i].ready = 1'b0;
        port_packet_temp[i].reset_all();
        mem_data[i] = 8'h00;
        port_packet_position[i] = 0;
        port_queue[i].delete();
      end
    end: reset_all_signals    
  endfunction : write_reset
  
    
  function void scoreboard::check_phase(uvm_phase phase);
    int packet_on_control = 0;
    `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> CHECK <--"), UVM_MEDIUM);
    packet_on_control = control_packet_queue.size();
    `uvm_info(get_name(), $sformatf("There are %0h packets on control.", packet_on_control), UVM_DEBUG);
    for(int i = 0; i < packet_on_control; i++) begin : compare_check_control
      `uvm_info(get_name(), $sformatf("Packet no. %0h - start checking.", i), UVM_DEBUG);

      control_packet_temp = control_packet_queue.pop_front();
      control_port_pecket_sent_temp = control_port_pecket_sent.pop_front();

      if(port_packet_queue[control_port_pecket_sent_temp].size() > 0) begin : there_is_data_on_port_queue
        port_packet_check_temp = port_packet_queue[control_port_pecket_sent_temp].pop_front();
        
        `uvm_info(get_name(), $sformatf("control: %s", control_packet_temp.convert2string()), UVM_DEBUG);
        `uvm_info(get_name(), $sformatf("port %0d: %s", control_port_pecket_sent_temp, port_packet_check_temp.convert2string()), UVM_DEBUG);

        if(control_packet_temp.compare(port_packet_check_temp) === 1'b1) begin : correct_packet_read
          `uvm_info(get_name(), $sformatf("MATCH packet nr %0h read from port %0h.", i, control_port_pecket_sent_temp), UVM_DEBUG);
        end : correct_packet_read
        else begin : incorrect_packet_read
          `uvm_info(get_name(), $sformatf("MISS packet nr %0h read from port %0h.", i, control_port_pecket_sent_temp), UVM_LOW);
          nr_of_packets_received_per_port_missed[control_port_pecket_sent_temp]++;
        end : incorrect_packet_read
      end : there_is_data_on_port_queue
      else nr_of_packets_received_per_port_missed[control_port_pecket_sent_temp]++;

      if(control_packet_temp.check() === 1'b1) begin : correct_packet_structure
        `uvm_info(get_name(), $sformatf("Correct structure for packet nr %0h.", i), UVM_DEBUG);
      end : correct_packet_structure
      else begin : incorrect_packet_structure
        `uvm_info(get_name(), $sformatf("Incorrect structure for packet nr %0h.", i), UVM_LOW);
        nr_of_packets_sent_incorrect++;
      end : incorrect_packet_structure

      `uvm_info(get_name(), $sformatf("Packet no. %0h - finished checking.", i), UVM_DEBUG);
    end : compare_check_control

    for(int i = 0; i < 4; i++) begin : check_empty_port_queue
      if(port_packet_queue[i].size() !== 0) begin : port_queue_not_empty
        `uvm_info(get_name(), $sformatf("There are %0h left packets on port %0h.", port_packet_queue[i].size(), i), UVM_LOW);
        nr_of_packets_left_on_port[i]++;
      end : port_queue_not_empty
    end : check_empty_port_queue

    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> CHECK <--"), UVM_MEDIUM);
  endfunction : check_phase
    
  function void scoreboard::report_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> REPORT <--"), UVM_MEDIUM);
    `uvm_info(get_name(), $sformatf("There were %0d memory write accesses: INCORRECT/CORRECT: %0d/%0d.", nr_memory_write_correct+nr_memory_write_incorrect, nr_memory_write_incorrect, nr_memory_write_correct), UVM_LOW);
    `uvm_info(get_name(), $sformatf("There were %0d memory read accesses: INCORRECT/CORRECT: %0d/%0d.", nr_memory_read_correct+nr_memory_read_incorrect, nr_memory_read_incorrect, nr_memory_read_correct), UVM_LOW);
    `uvm_info(get_name(), $sformatf("There were %0d sent packets: INCORRECT/CORRECT STRUCTURE: %0d/%0d.", nr_of_packets_sent, nr_of_packets_sent_incorrect, nr_of_packets_sent-nr_of_packets_sent_incorrect), UVM_LOW);
    `uvm_info(get_name(), $sformatf("There were %0d dropped packets.", nr_of_packets_received_dropped), UVM_LOW);
    for(int i = 0; i < 4; i++) begin : check_every_port
      `uvm_info(get_name(), $sformatf("ON PORT %0d:", i), UVM_LOW);
      `uvm_info(get_name(), $sformatf("There were %0d received packets: MISSED/MATCHED: %0d/%0d.", nr_of_packets_received_per_port[i], nr_of_packets_received_per_port_missed[i], nr_of_packets_received_per_port[i]-nr_of_packets_received_per_port_missed[i]), UVM_LOW);
      `uvm_info(get_name(), $sformatf("There were %0d left packets.", nr_of_packets_left_on_port[i]), UVM_LOW);
      `uvm_info(get_name(), $sformatf("Byte MISS/MATCH: %0d/%0d.", byte_miss[i], byte_match[i]), UVM_LOW);
    end : check_every_port
    `uvm_info(get_name(), $sformatf("Byte MISS/MATCH: %0d/%0d.", byte_miss[0]+byte_miss[1]+byte_miss[2]+byte_miss[3], byte_match[0]+byte_match[1]+byte_match[2]+byte_match[3]), UVM_LOW);
    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> REPORT <--"), UVM_MEDIUM);
  endfunction : report_phase
