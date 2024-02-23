covergroup control_covergroup (ref control_item item);
  data_in_cvp :      coverpoint item.data_in      { bins value_0_FF[7]  = {0, 85, 170, 255, [1 : 84], [86 : 169], [171 : 254]}; }
  sw_enable_in_cvp : coverpoint item.sw_enable_in { bins value_binary[] = {0, 1}; }
  read_out_cvp :     coverpoint item.read_out     { bins value_binary[] = {0, 1}; }
endgroup : control_covergroup