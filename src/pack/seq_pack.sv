package seq_pack;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import item_pack::*;

  `include "src/test/sequence/control_sequence.svh"
  `include "src/test/sequence/memory_sequence.svh"
  `include "src/test/sequence/reset_sequence.svh"
  `include "src/test/sequence/port_sequence.svh"
endpackage : seq_pack