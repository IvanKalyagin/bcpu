
module cpu_wrapper 
import riscv_types::*, cpu_types::*;
(
	input logic sys_clk,
    input logic ext_reset,
    output logic [ADDR_LEN-1:0] pc_curr
);
        
    parameter HEX_FILE = ""; 
    parameter DATA_FILE = "";

    logic clk;
	 assign clk=sys_clk;
    logic rst;
	 assign rst=ext_reset;

    
    logic[XLEN-1:0] pc_data;
    logic[ADDR_LEN-1:0] pc_addr;
    logic en_a;
    logic en_b;
    assign en_a = 1; // need for xilinx to create bram (pc_out)
    assign en_b = 0; // need for xilinx to create bram (pc_in)

    logic[ADDR_LEN-1:0] dram_addr;
    logic[XLEN-1:0] dram_data_out;
    logic[XLEN-1:0] dram_data_in;
    logic[XLEN/8-1:0] ls_size_o;
    logic             l_req_o;
    logic             s_req_o;

    assign pc_curr = pc_addr;
	 
    bcpu cpu(
        .clk(clk),
        .rst(rst),

        .pc_data(pc_data),
        .pc_addr(pc_addr),

        .dram_addr(dram_addr),
        .l_req_o(l_req_o),
        .s_req_o(s_req_o),
        .ls_size_o(ls_size_o),
        .dram_data_out(dram_data_out),
        .dram_data_in(dram_data_in)
    );

    iram #(HEX_FILE, 1) iram_block (
        .clk(clk),
        .rst(rst),

        .en_a(en_a),
        .en_b(en_b),
        .data_out_a(pc_data),
        .addr_a(pc_addr)
    );

    dram #(DATA_FILE, 1) dram_block(
        .clk(clk),
        .rst(rst),

        .addr_a(dram_addr),
        .be_a(ls_size_o),
        .load(l_req_o),
        .store(s_req_o),
        .data_in(dram_data_out),

        .data_out_a(dram_data_in)
    );


endmodule