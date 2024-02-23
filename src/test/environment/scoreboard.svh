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

  data_packet packet_port_queue[4][$];
  data_packet packet_port_in[4];
  bit [7:0] bit_port_queue[4][$];

  int packet_port_in_position[4];

  bit [7:0] bit_temp[4];
  int miss_temp[4];
  
  data_packet data_packet_temp[4];
  port_item port_item_temp[4];

  bit [7:0] mem_data[4];
  int port_indexes[$];

  port_item port_prev[4];
  bit status_prev;

  bit port_unknown;
  int port_current;

  int dropped_packet_nr; // nr of dropped packets at control
  int lost_packet_nr; // nr of packets lost at port
  int lost_bits_nr; //extra bits in the output
  int packet_output_nr[4],  packet_input_nr; // number of packets received and sent forward
  int packet_match[4], packet_miss[4]; // if the entire packet is miss/match
  int miss[4], match[4]; // all and any individual miss/matchs 
  
  function new (string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  extern function void build_phase(uvm_phase phase);
  extern function void check_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);
    
  extern function void write_control(control_item t);
  extern function void write_reset(reset_item t);
  extern function void write_memory(memory_item t);
    
  extern function void write_port_0(port_item t);
  extern function void write_port_1(port_item t);
  extern function void write_port_2(port_item t);
  extern function void write_port_3(port_item t);
  
  extern function void make_packet(bit[7:0] data, bit port_in_OR_port_out = 1'b0, int port_ind = 0);
  extern function void end_packet(bit port_in_OR_port_out = 1'b0, int port_ind = 0);
  extern function void make_port_packet(port_item t, int port_ind);
      
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
      packet_port_in[i] = new("packet_port_in");
      port_item_temp[i] = new("port_item_temp");
      packet_port_in_position[i] = 0;
      packet_output_nr[i] = 0;
      packet_input_nr[i] = 0; 
      miss[i] = 0;
      match[i] = 0;
      packet_match[i] = 0;
      packet_miss[i] = 0;
      data_packet_temp[i] = new("data_packet_temp");
    end
    
    lost_packet_nr = 0;
    packet_input_nr = 0;
    lost_bits_nr = 0;
    port_unknown = 1'b0;
    dropped_packet_nr = 0;
    port_current = 0;
    status_prev = 1'b0; 
  
    `uvm_info(get_name(), $sformatf("---> EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
  endfunction : build_phase
    
    

  function void scoreboard::make_packet(bit[7:0] data, bit port_in_OR_port_out = 1'b0, int port_ind = 0); // port_in = 0; port_out = 1
    if(port_in_OR_port_out === 1'b0) begin: write_input_packet
      case(packet_port_in_position[port_current])
        0: packet_port_in[port_current].da     = data;
        1: packet_port_in[port_current].sa     = data;
        2: packet_port_in[port_current].length = data;
        default: packet_port_in[port_current].payload.push_back(data);
      endcase
      packet_port_in_position[port_current]++;
    end: write_input_packet
  endfunction : make_packet


  function void scoreboard::end_packet(bit port_in_OR_port_out = 1'b0, int port_ind = 0);
    if(port_in_OR_port_out === 1'b0) begin: write_input_packet
      packet_port_queue[port_current].push_back(packet_port_in[port_current]);
      packet_port_in[port_current].payload.delete();
      packet_port_in_position[port_current] = 0;
    end: write_input_packet
  endfunction : end_packet
    
  
  function void scoreboard::write_control(control_item t);
    `uvm_info(get_name(), $sformatf("Received item : %s ", t.convert2string()), UVM_FULL);
    
    if(t.sw_enable_in == 1'b1) begin : data_status_activated
      `uvm_info(get_name(), $sformatf("Data status active."), UVM_DEBUG);
      if(port_unknown !== 1'b0) begin : middle_of_transaction
        `uvm_info(get_name(), $sformatf("Add item to input packet in middle of transaction."), UVM_DEBUG);
        make_packet(t.data_in);
      end : middle_of_transaction
      else if(port_unknown === 1'b0) begin : choose_port
        `uvm_info(get_name(), $sformatf("Add item to input packet at the beginning of transaction."), UVM_DEBUG);
        port_indexes = mem_data.find_index with (item == t.data_in);
        if(port_indexes.size() > 0) begin : DA_is_mem
          port_unknown = 1'b1; 
          port_current = port_indexes.pop_front(); 
          make_packet(t.data_in);
          `uvm_info(get_name(), $sformatf("Memory data and received item match at beginning of transaction."), UVM_DEBUG);
        end : DA_is_mem
        else begin
          dropped_packet_nr++;
          `uvm_info(get_name(), $sformatf("Memory data and received item don't match at beginning of transaction."), UVM_DEBUG);
        end
      end : choose_port 
    end : data_status_activated
    else begin : data_status_deactivated
    `uvm_info(get_name(), $sformatf("Data status inactive."), UVM_DEBUG);
      if(status_prev === 1'b1) begin : save_packet
        `uvm_info(get_name(), $sformatf("End of input transaction. Finish packet."), UVM_DEBUG);
        end_packet();
        port_unknown = 1'b0;
      end : save_packet
    end : data_status_deactivated
    
    status_prev = t.sw_enable_in;

  endfunction : write_control
  
  function void scoreboard::write_memory(memory_item t);
    `uvm_info(get_name(), $sformatf("Received item : %s ", t.convert2string()), UVM_FULL);
    if(t.mem_sel_en && t.mem_wr_rd_s) begin
      `uvm_info(get_name(), $sformatf("Memory data changed."), UVM_DEBUG);
      mem_data[t.mem_addr] = t.mem_wr_data;
    end
  endfunction : write_memory
  
  function void scoreboard::write_reset(reset_item t);
    `uvm_info(get_name(), $sformatf("Received reset : %s ", t.convert2string()), UVM_FULL);
    if(t.reset == 1'b0) begin : reset_all
      `uvm_info(get_name(), $sformatf("Reset acivated : %s ", t.convert2string()), UVM_FULL);
      port_unknown = 1'b0;
      for(int i = 0; i < 4; i++) begin
        port_prev[i].read = 1'b0;
        port_prev[i].ready = 1'b0;
        status_prev = 1'b0;
        packet_port_in_position[i] = 0;
        packet_port_queue[i].delete();
        bit_port_queue[i].delete();
      end 
      port_current = 0;
    end: reset_all    
  endfunction : write_reset
  
     
  function void scoreboard::check_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("---> EXIT PHASE: --> CHECK <--"), UVM_MEDIUM);
    
    for(int i = 0; i < 4; i++) begin
      if(bit_port_queue[i].size !== 0) begin : info_in_port
        `uvm_info(get_name(), $sformatf("Port %0d sent valid data.", i), UVM_FULL);
        if(packet_port_queue[i].size !== 0) begin : info_was_sent_to_port
          data_packet_temp[i] = packet_port_queue[i].pop_front();
          miss_temp[i] = miss[i];
          
          for(int j = 0; j < data_packet_temp[i].length + 3; j++) begin : compare_8_bits
            bit_temp[i] = bit_port_queue[i].pop_front();

            case(j)
              0: if(bit_temp[i] === data_packet_temp[i].da) match[i]++; else miss[i]++;
              1: if(bit_temp[i] === data_packet_temp[i].sa) match[i]++; else miss[i]++;
              2: if(bit_temp[i] === data_packet_temp[i].length) match[i]++; else miss[i]++;
              default: if(bit_temp[i] === data_packet_temp[i].payload.pop_front()) match[i]++; else miss[i]++;
            endcase

          end : compare_8_bits

          if(miss[i] !== miss_temp[i]) begin : not_matched_bits
            `uvm_info(get_name(), $sformatf("Port %0d missed a packet.", i), UVM_FULL);
            packet_miss[i]++;
          end : not_matched_bits
          else begin : matched_all_bits
            `uvm_info(get_name(), $sformatf("Port %0d matched a packet.", i), UVM_FULL);
            packet_match[i]++;
          end : matched_all_bits

          
        end : info_was_sent_to_port
        else begin : info_was_not_sent_to_port
          `uvm_info(get_name(), $sformatf("Port %0d didn't receive any valid data.", i), UVM_FULL);
          lost_bits_nr = lost_bits_nr + bit_port_queue[i].size;
        end : info_was_not_sent_to_port
      end : info_in_port

      else begin : no_info_in_port
        `uvm_info(get_name(), $sformatf("Port %0d didn't send any valid data.", i), UVM_FULL);
        if(packet_port_queue[i].size !== 0) begin : info_was_sent_to_port
          `uvm_info(get_name(), $sformatf("Port %0d did receive valid data.", i), UVM_FULL);
          lost_packet_nr = lost_packet_nr + packet_port_queue[i].size;
        end : info_was_sent_to_port
        else begin : info_was_not_sent_to_port
          `uvm_info(get_name(), $sformatf("Port %0d didn't receive any valid data.", i), UVM_FULL);
        end : info_was_not_sent_to_port
      end : no_info_in_port
    end

    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> CHECK <--"), UVM_MEDIUM);
  endfunction : check_phase


  function void scoreboard::make_port_packet(port_item t, int port_ind);
    if(port_prev[port_ind].read == 1'b1 && port_prev[port_ind].ready == 1'b1 && t.ready == 1'b1) begin : read_port
      `uvm_info(get_name(), $sformatf("A valid read was made from port %0d.", port_ind), UVM_DEBUG);

      bit_port_queue[port_ind].push_back(t.port);
    end : read_port
    port_prev[port_ind].copy(t);
  endfunction : make_port_packet

    
  function void scoreboard::write_port_0(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 0 : %s ", t.convert2string()), UVM_FULL);
    make_port_packet(t, 0);   
  endfunction : write_port_0
  
  function void scoreboard::write_port_1(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 1 : %s ", t.convert2string()), UVM_FULL);
    make_port_packet(t, 1);   
  endfunction : write_port_1
  
  function void scoreboard::write_port_2(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 2 : %s ", t.convert2string()), UVM_FULL);
    make_port_packet(t, 2);   
  endfunction : write_port_2
  
  function void scoreboard::write_port_3(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 3 : %s ", t.convert2string()), UVM_FULL);
    make_port_packet(t, 3);   
  endfunction : write_port_3
  
    
  function void scoreboard::report_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("---> EXIT PHASE: --> REPORT <--"), UVM_MEDIUM);
    `uvm_info(get_name(), $sformatf("Number of valid packets: %0d", packet_input_nr), UVM_LOW);
    `uvm_info(get_name(), $sformatf("Number of dropped packets: %0d", dropped_packet_nr), UVM_LOW);
    `uvm_info(get_name(), $sformatf("Number of lost packets: %0d", lost_packet_nr), UVM_LOW);
    for(int i = 0; i < 4; i++) begin
      `uvm_info(get_name(), $sformatf("PORT %0d: Number of packets: %0d", i, packet_output_nr[i]), UVM_LOW);
      `uvm_info(get_name(), $sformatf("PORT %0d: Number of matched packets: %0d", i, packet_match[i]), UVM_LOW);
      `uvm_info(get_name(), $sformatf("PORT %0d: Number of missed packets: %0d", i, packet_miss[i]), UVM_LOW);
      `uvm_info(get_name(), $sformatf("PORT %0d: Number of matched 8 bits: %0d", i, match[i]), UVM_LOW);
      `uvm_info(get_name(), $sformatf("PORT %0d: Number of missed 8 bits: %0d", i, miss[i]), UVM_LOW);
    end
    `uvm_info(get_name(), $sformatf("Number of lost 8 bits: %0d", lost_bits_nr), UVM_LOW);
    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> REPORT <--"), UVM_MEDIUM);
  endfunction : report_phase
