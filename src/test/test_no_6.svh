`define NO_OF_PORTS 4

class test_no_6 extends uvm_test;
  `uvm_component_utils(test_no_6);
  
  bit [7:0]first_memory_config_data[`NO_OF_PORTS];

  environment env;  
  
  control_sequence ctrl_seq[3];
  virtual_sequence v_seq;

  environment_config env_config;
  
  function new (string name = "test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  extern function void build_phase(uvm_phase phase);
  extern function void start_of_simulation_phase(uvm_phase phase);
  extern task main_phase(uvm_phase phase);
endclass : test_no_6
    
    

  function void test_no_6::build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> BUILD <--"), UVM_DEBUG);

    env_config = new(.is_cluster(UNIT), .number_of_ports(`NO_OF_PORTS));
    uvm_config_db #(environment_config)::set(this, "env*", "config", env_config);

    env = environment::type_id::create("env", this);
   
    foreach(first_memory_config_data[i]) begin
      $cast(first_memory_config_data[i], $urandom_range(0,255));
      uvm_config_db #(logic[7:0])::set(this, "*", $sformatf("mem_data[%0d]", i), first_memory_config_data[i]);
    end
    
    foreach(ctrl_seq[i]) begin
      ctrl_seq[i] = control_sequence::type_id::create("ctrl_seq");
      ctrl_seq[i].set_da_options(first_memory_config_data);
    end
    
    ctrl_seq[0].set_parameters(.nr_items(1), .max_length(0));
    ctrl_seq[1].set_parameters(.nr_items(1), .min_length(254));
    ctrl_seq[2].set_parameters(.nr_items(1), .min_length(1), .max_length(254));
    
    v_seq = virtual_sequence::type_id::create("v_seq");
    v_seq.set_parameters(.bandwidth({100, 100, 100, 100}));

    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
  endfunction : build_phase
    
  function void test_no_6::start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> START OF SIMULATION <--"), UVM_DEBUG);
    uvm_top.print_topology();
    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> START OF SIMULATION <--"), UVM_DEBUG);
  endfunction : start_of_simulation_phase
    
  task test_no_6::main_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("---> ENTER PHASE: --> MAIN <--"), UVM_DEBUG);
    
    phase.raise_objection(this);
    fork
      v_seq.start(env.v_seqr);
      foreach(ctrl_seq[i]) begin
        #200 ctrl_seq[i].start(env.ctrl_agent.seqr);
      end
    join
    phase.drop_objection(this);  

    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> MAIN <--"), UVM_DEBUG);  
  endtask : main_phase