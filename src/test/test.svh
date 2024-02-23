/*-----------------------------------------------------------------------------------------

     --- SS Testing with UVM --- SMOKE TEST ---

This is the smoke test for the Simple Switch Verification.

It contains the following sequences:
	- a control sequence
    	- the number of packets created is defined
        - when this sequence ends the test ends
    - a virtual sequence
    	- starts the reactive port sequences
        
In the build phase the environment and the sequences are created and configured.

In the start of simulation phase the topology is printed.

In the main phase the sequences are started.

-----------------------------------------------------------------------------------------*/



`define NO_OF_PORTS 4

class test extends uvm_test;
  `uvm_component_utils(test);
  
  bit [7:0]first_memory_config_data[`NO_OF_PORTS];

  environment env;  
  
  control_sequence ctrl_seq;
  memory_sequence mem_seq[5];
  virtual_sequence v_seq;

  environment_config env_config;
  
  function new (string name = "test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  extern function void build_phase(uvm_phase phase);
  extern function void start_of_simulation_phase(uvm_phase phase);
  extern task main_phase(uvm_phase phase);
endclass : test
    
    

  function void test::build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> BUILD <--"), UVM_DEBUG);

    env_config = new(.is_cluster(UNIT), .number_of_ports(`NO_OF_PORTS));
    uvm_config_db #(environment_config)::set(this, "env*", "config", env_config);

    env = environment::type_id::create("env", this);
   
    foreach(first_memory_config_data[i]) begin
      $cast(first_memory_config_data[i], $urandom_range(0,255));
      uvm_config_db #(logic[7:0])::set(this, "*", $sformatf("mem_data[%0d]", i), first_memory_config_data[i]);
    end
    
    ctrl_seq = control_sequence::type_id::create("ctrl_seq");
    ctrl_seq.set_da_options(first_memory_config_data);
    
    ctrl_seq.set_parameters(.nr_items(2), .min_length(10), .no_random(1'b1));
    
    for(int i = 0; i < 5; i++) begin
      mem_seq[i] = memory_sequence::type_id::create("mem_seq");
      if(i == 4) mem_seq[i].set_parameters(.nr_items(3), .addr(2'b00), .sel(1'b0), .wr_rd(1'b0));
      else mem_seq[i].set_parameters(.nr_items(1), .addr(i), .sel(1'b1), .wr_rd(1'b0));
    end    

    v_seq = virtual_sequence::type_id::create("v_seq");
    v_seq.set_parameters(.bandwidth({100, 100, 100, 100}));

    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
  endfunction : build_phase
    
  function void test::start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> START OF SIMULATION <--"), UVM_DEBUG);
    uvm_top.print_topology();
    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> START OF SIMULATION <--"), UVM_DEBUG);
  endfunction : start_of_simulation_phase
    
  task test::main_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> MAIN <--"), UVM_DEBUG);
    
    phase.raise_objection(this);
    fork
      v_seq.start(env.v_seqr);
      #100 ctrl_seq.start(env.ctrl_agent.seqr);
      for(int i = 0; i < 4; i++) mem_seq[i].start(env.mem_agent.seqr);
    join
    phase.drop_objection(this);  

    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> MAIN <--"), UVM_DEBUG);  
  endtask : main_phase

