
// Write back module

module wb
    import cpu_config::*;
    import riscv_types::*;
    import cpu_types::*;
    (
    input   logic           rst,
    input   logic           clk,

    input logic[XLEN-1:0] alu_res,
    input logic alu_res_en,

    input logic[XLEN-1:0] lsu_res,
    input logic lsu_res_en,

    input rs_addr_t rd_addr,
    input logic rd_en,

    output rs_addr_t rd_addr_o,

    output logic res_en,
    output logic[XLEN-1:0] result,

    // input logic[28:0] curr_pc[3] // TODO size param

    // // New pc
    // output logic[28:0] new_pc[3]
);

// assign new_pc = curr_pc;

always_comb begin
    res_en = rd_en;
    if (alu_res_en) begin
        result <= alu_res;
        rd_addr_o <= rd_addr;
    end else if (lsu_res_en) begin
        result <= lsu_res;
        rd_addr_o <= rd_addr;
    end else begin
        result <= '0;
        rd_addr_o <= '0;
    end
end

endmodule
