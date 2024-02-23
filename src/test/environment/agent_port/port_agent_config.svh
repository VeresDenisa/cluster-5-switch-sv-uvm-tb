class port_agent_config extends base_agent_config;
  protected int port_number;
  
  function new ( uvm_active_passive_enum is_active, int port_number );
    super.new(is_active);
    this.port_number = port_number;
  endfunction : new  
  
  function int get_port_number();
    return port_number;
  endfunction : get_port_number
endclass : port_agent_config