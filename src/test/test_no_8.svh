`define NO_OF_TESTS 8
`define NO_OF_PORTS 4

class test_no_8 extends uvm_test;
  `uvm_component_utils(test_no_8);
  
  bit [7:0]first_memory_config_data[`NO_OF_PORTS];

  environment env;  
  
  control_sequence ctrl_seq[`NO_OF_TESTS];
  reset_sequence  rst_seq;
  virtual_sequence v_seq;

  environment_config env_config;
  
  function new (string name = "test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  extern function void build_phase(uvm_phase phase);
  extern function void start_of_simulation_phase(uvm_phase phase);
  extern task main_phase(uvm_phase phase);
endclass : test_no_8
    
    

  function void test_no_8::build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> BUILD <--"), UVM_DEBUG);

    env_config = new(.is_cluster(UNIT), .number_of_ports(`NO_OF_PORTS));
    uvm_config_db #(environment_config)::set(this, "env*", "config", env_config);

    env = environment::type_id::create("env", this);
   
    foreach(first_memory_config_data[i]) begin
      $cast(first_memory_config_data[i], $urandom_range(0,255));
      uvm_config_db #(logic[7:0])::set(this, "*", $sformatf("mem_data[%0d]", i), first_memory_config_data[i]);
    end
    
    rst_seq = reset_sequence::type_id::create("rst_seq");
    
    foreach(ctrl_seq[i]) begin
      ctrl_seq[i] = control_sequence::type_id::create("ctrl_seq");
      ctrl_seq[i].set_da_options(first_memory_config_data);
      ctrl_seq[i].set_parameters(.nr_items(1), .min_length(3), .max_length(4));
    end
    
    v_seq = virtual_sequence::type_id::create("v_seq");
    v_seq.set_parameters();
    
    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
  endfunction : build_phase
    
  function void test_no_8::start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> START OF SIMULATION <--"), UVM_DEBUG);
    uvm_top.print_topology();
    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> START OF SIMULATION <--"), UVM_DEBUG);
  endfunction : start_of_simulation_phase
    
  task test_no_8::main_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> MAIN <--"), UVM_DEBUG);
    
    phase.raise_objection(this);
    fork
      foreach(ctrl_seq[i]) begin
        #100 ctrl_seq[i].start(env.ctrl_agent.seqr);
      end
      foreach(ctrl_seq[i]) begin
        #((i==0)?100:200) rst_seq.start(env.rst_agent.seqr);
      end
      v_seq.start(env.v_seqr);
    join
    phase.drop_objection(this);  

    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> MAIN <--"), UVM_DEBUG);  
  endtask : main_phase