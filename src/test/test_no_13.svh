`define NO_OF_TESTS 1
`define NO_OF_PORTS 4

class test_no_13 extends uvm_test;
  `uvm_component_utils(test_no_13);
  
  bit [7:0]first_memory_config_data[`NO_OF_PORTS];

  environment env;  
  
  memory_sequence mem_seq[4];

  environment_config env_config;
  
  function new (string name = "test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  extern function void build_phase(uvm_phase phase);
  extern function void start_of_simulation_phase(uvm_phase phase);
  extern task main_phase(uvm_phase phase);
endclass : test_no_13
    
    

  function void test_no_13::build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> BUILD <--"), UVM_DEBUG);

    env_config = new(.is_cluster(UNIT), .number_of_ports(`NO_OF_PORTS));
    uvm_config_db #(environment_config)::set(this, "env*", "config", env_config);

    env = environment::type_id::create("env", this);
   
    foreach(first_memory_config_data[i]) begin
      $cast(first_memory_config_data[i], $urandom_range(0,254)); 
      while(first_memory_config_data[i] === 'h55) $cast(first_memory_config_data[i], $urandom_range(0,254)); 
    end

    for(int i = 0; i < `NO_OF_PORTS - 1; i++) begin
      while(first_memory_config_data[i] === first_memory_config_data[i+1]) $cast(first_memory_config_data[i], $urandom_range(0,254)); 
    end   
    
    foreach(first_memory_config_data[i]) begin
      uvm_config_db #(logic[7:0])::set(this, "*", $sformatf("mem_data[%0d]", i), first_memory_config_data[i]);
    end 
    
    foreach(mem_seq[i]) begin
        mem_seq[i] = memory_sequence::type_id::create("mem_seq");
    end

    mem_seq[0].set_parameters(.nr_items(4), .rotate(1'b1), .memory_trans(READ_TRANS));
    mem_seq[1].set_parameters(.nr_items(8), .memory_trans(WRITE_TRANS));
    mem_seq[2].set_parameters(.nr_items(8), .memory_trans(READ_TRANS));
    mem_seq[3].set_parameters(.nr_items(4), .rotate(1'b1), .memory_trans(READ_TRANS));
    
    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
  endfunction : build_phase
    
  function void test_no_13::start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> START OF SIMULATION <--"), UVM_DEBUG);
    uvm_top.print_topology();
    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> START OF SIMULATION <--"), UVM_DEBUG);
  endfunction : start_of_simulation_phase
    
  task test_no_13::main_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> MAIN <--"), UVM_DEBUG);
    
    phase.phase_done.set_drain_time(this, 100);

    phase.raise_objection(this);
    fork
      foreach(mem_seq[i]) #100 mem_seq[i].start(env.mem_agent.seqr);
    join
    phase.drop_objection(this);  

    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> MAIN <--"), UVM_DEBUG);  
  endtask : main_phase