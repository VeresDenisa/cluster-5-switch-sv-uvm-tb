covergroup data_covergroup (ref data_packet item);
  da_cvp :     coverpoint item.da        { bins value_0_FF[7]  = {0, 85, 170, 255, [1 : 84], [86 : 169], [171 : 254]}; }
  sa_cvp :     coverpoint item.sa        { bins value_0_FF[7]  = {0, 85, 170, 255, [1 : 84], [86 : 169], [171 : 254]}; }
  length_cvp : coverpoint item.length    { bins value_binary[] = {0, 255, [1:254]}; }
endgroup : data_covergroup