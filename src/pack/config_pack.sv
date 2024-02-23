package config_pack;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import base_pack::*;

  `include "src/test/environment/environment_config.svh"
  
  `include "src/test/environment/agent_reset/reset_agent_config.svh"
  `include "src/test/environment/agent_memory/memory_agent_config.svh"
  `include "src/test/environment/agent_control/control_agent_config.svh"
  `include "src/test/environment/agent_port/port_agent_config.svh"
endpackage : config_pack