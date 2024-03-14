covergroup data_covergroup (ref data_packet item);
  da_cvp :     coverpoint item.da        { bins value_0_FF[5]  = {0, 170, [1 : 84], [86 : 169], [171 : 254]}; }
  sa_cvp :     coverpoint item.sa        { bins value_0_FF[5]  = {0, 170, [1 : 84], [86 : 169], [171 : 254]}; }
  length_cvp : coverpoint item.length    { bins value_binary[3] = {1, 254, [2 : 253]}; }
endgroup : data_covergroup