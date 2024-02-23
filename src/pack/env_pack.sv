package env_pack;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import item_pack::*;
  import seq_pack::*;
  import base_pack::*;
  import config_pack::*;

  import reset_agent_pack::*;
  import control_agent_pack::*;
  import memory_agent_pack::*;
  import port_agent_pack::*;

  `include "src/test/environment/virtual_sequencer.svh"
  `include "src/test/sequence/virtual_sequence.svh"

  `include "src/test/environment/scoreboard.svh"

  `include "src/test/environment/coverage/port_covergroup.sv"
  `include "src/test/environment/coverage/control_covergroup.sv"
  `include "src/test/environment/coverage/memory_covergroup.sv"
  `include "src/test/environment/coverage/data_covergroup.sv"
  `include "src/test/environment/coverage/event_covergroup.sv" 

  `include "src/test/environment/coverage/coverage.svh"

  `include "src/test/environment/environment.svh"
endpackage : env_pack