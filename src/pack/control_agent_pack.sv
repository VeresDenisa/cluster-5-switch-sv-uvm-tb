package control_agent_pack;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import item_pack::*;
  import base_pack::*;
  import config_pack::*;

  `include "src/test/environment/agent_control/control_driver.svh"
  `include "src/test/environment/agent_control/control_monitor.svh"

  `include "src/test/environment/agent_control/control_agent.svh"
endpackage : control_agent_pack