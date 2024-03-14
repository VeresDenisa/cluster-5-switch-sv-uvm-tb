covergroup memory_covergroup (ref memory_item item);
  mem_wr_data_cvp : coverpoint item.mem_wr_data { bins value[3] = {[0 : 84], [86 : 169], [170 : 254]}; }
  mem_rd_data_cvp : coverpoint item.mem_rd_data { bins value[3] = {[0 : 84], [86 : 169], [170 : 254]}; }
  mem_addr_cvp :    coverpoint item.mem_addr    { bins value[4] = {0, 1, 2, 3}; }
  mem_sel_en_cvp :  coverpoint item.mem_sel_en  { bins value_binary[2] = {0, 1}; }
  mem_wr_rd_s_cvp : coverpoint item.mem_wr_rd_s { bins value_binary[2] = {0, 1}; }
  mem_ack_cvp :     coverpoint item.mem_ack     { bins value_binary[2] = {0, 1}; }
  data_cross :       cross mem_wr_data_cvp, mem_addr_cvp   {}
  save_cross :       cross mem_sel_en_cvp, mem_wr_rd_s_cvp {}
endgroup : memory_covergroup