
module cpu_wrapper 
import cpu_config::*, riscv_types::*, cpu_types::*;
(
	input logic sys_clk,
    input logic ext_reset
);
        
    parameter HEX_FILE = "";

    logic clk;
	 assign clk=sys_clk;
    logic rst;
	 assign rst=ext_reset;

    
    logic[XLEN-1:0] pc_data;
    logic[ADDR_LEN-1:0] pc_addr;

    logic[ADDR_LEN-1:0] dram_addr;
    logic[XLEN-1:0] dram_data_out;
    logic[XLEN-1:0] dram_data_in;

	 
    bcpu cpu(
        .clk(clk),
        .rst(rst),

        .pc_data(pc_data),
        .pc_addr(pc_addr),

        .dram_addr(dram_addr),
        .dram_data_out(dram_data_out),
        .dram_data_in(dram_data_in)
    );

    iram #(HEX_FILE, 1) iram_block (
        .clk(clk),
        .rst(rst),

        .data_out_a(pc_data),
        .addr_a(pc_addr)
    );

    // dram dram_block(

    // );

    //design_2 infra(.*);

   /* generate
        if (ENABLE_S_MODE || USE_ICACHE || USE_DCACHE) begin
            l2_arbiter l2_arb (.*, .request(l2));
            axi_to_arb l2_to_mem (.*, .l2(mem));
        end
    endgenerate */

    //arm proc(.*);
    // byte_en_BRAM #(MEM_LINES, HEX_FILE, 1) inst_data_ram (
    //         .clk(clk),
    //         .addr_a(instruction_bram.addr[$clog2(MEM_LINES)- 1:0]),
    //         .en_a(instruction_bram.en),
    //         .be_a(instruction_bram.be),
    //         .data_in_a(instruction_bram.data_in),
    //         .data_out_a(instruction_bram.data_out),

    //         .addr_b(data_bram.addr[$clog2(MEM_LINES)- 1:0]),
    //         .en_b(data_bram.en),
    //         .be_b(data_bram.be),
    //         .data_in_b(data_bram.data_in),
    //         .data_out_b(data_bram.data_out)
    //     );

endmodule