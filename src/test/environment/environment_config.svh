typedef enum bit { CLUSTER = 1'b1, UNIT   = 1'b0 } cluster_unit_enum;

class environment_config;
  protected cluster_unit_enum is_cluster;
  protected int number_of_ports;
  
  function new ( cluster_unit_enum is_cluster, int number_of_ports);
    this.is_cluster = is_cluster;
    this.number_of_ports = number_of_ports;
  endfunction : new
  
  function cluster_unit_enum get_is_cluster();
    return is_cluster;
  endfunction : get_is_cluster
  
  function int get_number_of_ports();
    return number_of_ports;
  endfunction : get_number_of_ports
  
endclass : environment_config