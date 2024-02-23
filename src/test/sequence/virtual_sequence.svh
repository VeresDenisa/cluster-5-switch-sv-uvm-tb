class virtual_sequence extends uvm_sequence;
  `uvm_object_utils(virtual_sequence);
  `uvm_declare_p_sequencer(virtual_sequencer);
  
  port_sequence port_seq[4];  
  port_item request[4];
  int bandwidth[4];
  
  function new (string name = "virtual_sequence");
    super.new(name);
  endfunction : new
  
  extern function void set_parameters(int bandwidth[4] = {100, 100, 100, 100});
    
  extern task pre_body();
  extern task body();  
endclass : virtual_sequence

    
    

function void virtual_sequence::set_parameters(int bandwidth[4] = {100, 100, 100, 100});
  this.bandwidth = bandwidth;
endfunction : set_parameters
    
task virtual_sequence::pre_body();
  foreach(port_seq[i]) begin
    port_seq[i] = port_sequence::type_id::create($sformatf("port_%0d_seq", i));
    port_seq[i].set_parameters(bandwidth[i]);
    request[i] = port_item::type_id::create($sformatf("request_%0d", i));
  end
endtask : pre_body
    
task virtual_sequence::body();
  foreach(port_seq[i]) begin
    automatic int var_i = i;
    fork
      forever begin
        p_sequencer.port_seqr[var_i].fifo.get(request[var_i]);
        port_seq[var_i].set_is_ready(request[var_i].ready);
        port_seq[var_i].start(p_sequencer.port_seqr[var_i]);
      end
    join_none
  end
endtask : body
