covergroup port_covergroup (ref port_item item);
  option.per_instance = 0;
  option.get_inst_coverage = 1;
  type_option.merge_instances = 0;
  
  port_cvp :    coverpoint item.port  { bins value_0_FF[7]  = {0, 85, 170, 255, [1 : 84], [86 : 169], [171 : 254]}; }
  ready_cvp :   coverpoint item.ready { bins value_binary[] = {0, 1}; }
  read_cvp :    coverpoint item.read  { bins value_binary[] = {0, 1}; }
  receive_cross : cross ready_cvp, read_cvp {}
endgroup : port_covergroup