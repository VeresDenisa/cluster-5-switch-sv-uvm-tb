class virtual_sequence extends uvm_sequence;
  `uvm_object_utils(virtual_sequence);
  `uvm_declare_p_sequencer(virtual_sequencer);
  
  port_sequence port_seq[4];  
  port_item request[4];
  bit started[4];
  
  function new (string name = "virtual_sequence");
    super.new(name);
  endfunction : new
    
  extern task pre_body();
  extern task body();  
endclass : virtual_sequence

    
    
task virtual_sequence::pre_body();
  foreach(port_seq[i]) begin
    port_seq[i] = port_sequence::type_id::create($sformatf("port_%0d_seq", i));
    request[i]  = port_item::type_id::create($sformatf("request_%0d", i));
    started[i] = 1'b0;
  end
endtask : pre_body
    
task virtual_sequence::body();
  foreach(port_seq[i]) begin
    automatic int var_i = i;
    fork
      forever begin
        p_sequencer.port_seqr[var_i].fifo.get(request[var_i]);

        if(started[var_i]) begin : not_first_frame
          port_seq[var_i].set_is_ready(1'b0);
          port_seq[var_i].start(p_sequencer.port_seqr[var_i]);
          if(~request[var_i].ready) started[var_i] = 1'b0;
        end : not_first_frame

        else begin : first_frame
          if(request[var_i].ready) port_seq[var_i].set_is_ready(1'b1);
          port_seq[var_i].start(p_sequencer.port_seqr[var_i]);
          started[var_i] = 1'b1;
        end : first_frame
      end
    join_none
  end
endtask : body
