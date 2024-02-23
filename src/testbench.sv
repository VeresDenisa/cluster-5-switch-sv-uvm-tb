
  import uvm_pkg::*;
  `include "uvm_macros.svh"
 
  import test_pack::*;

module testbench;  
  bit clk;
  
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end
  
  reset_interface   rst_i(clk);
  memory_interface  mem_i(clk);
  control_interface ctrl_i(clk);
  port_interface port_0_i(clk), 
  				 port_1_i(clk),
  				 port_2_i(clk), 
  				 port_3_i(clk);
   
  switch_top DUT(
    .clk(clk),
    .rst_n(rst_i.reset),
    .sw_enable_in(ctrl_i.sw_enable_in),
    .read_out(ctrl_i.read_out),
    .data_in(ctrl_i.data_in),
    .port_out_0(port_0_i.port),
    .port_out_1(port_1_i.port),
    .port_out_2(port_2_i.port),
    .port_out_3(port_3_i.port),
    .port_ready('{port_0_i.ready, port_1_i.ready, port_2_i.ready, port_3_i.ready}),
    .port_read('{port_0_i.read, port_1_i.read, port_2_i.read, port_3_i.read}),
    .mem_sel_en(mem_i.mem_sel_en),
    .mem_wr_rd_s(mem_i.mem_wr_rd_s),
    .mem_addr(mem_i.mem_addr),
    .mem_wr_data(mem_i.mem_wr_data),
    .mem_rd_data(mem_i.mem_rd_data),
    .mem_ack(mem_i.mem_ack)
  );
  
  initial begin
    uvm_config_db#(virtual reset_interface)::  set(null, "uvm_test_top.env.rst_agent*",  "reset_interface",   rst_i);
    uvm_config_db#(virtual memory_interface):: set(null, "uvm_test_top.env.mem_agent*",  "memory_interface",  mem_i);
    uvm_config_db#(virtual control_interface)::set(null, "uvm_test_top.env.ctrl_agent*", "control_interface", ctrl_i);
    
    uvm_config_db#(virtual port_interface)::set(null, "uvm_test_top.env.port_0_agent*", "port_interface", port_0_i);
    uvm_config_db#(virtual port_interface)::set(null, "uvm_test_top.env.port_1_agent*", "port_interface", port_1_i);
    uvm_config_db#(virtual port_interface)::set(null, "uvm_test_top.env.port_2_agent*", "port_interface", port_2_i);
    uvm_config_db#(virtual port_interface)::set(null, "uvm_test_top.env.port_3_agent*", "port_interface", port_3_i);
  end
  
  initial begin
    run_test();
  end
  
  initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
  end
endmodule : testbench