
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
    input logic [2:0] cmd,

    input rs_addr_t rd_addr,
    input logic rd_en,

    output rs_addr_t rd_addr_o,

    output logic res_en,
    output logic[XLEN-1:0] result

);

// assign new_pc = curr_pc;

always_comb begin
    res_en = rd_en;
    result = '0;
    if (alu_res_en) begin
        result = alu_res;
        rd_addr_o = rd_addr;
    end else if (lsu_res_en) begin
        case (cmd)
            3'b000 : begin // LB
                result = signed'(lsu_res[7:0]);
            end

            3'b001 : begin // LH
                result = signed'(lsu_res[15:0]);
            end

            3'b010 : begin // LW
                result = lsu_res;
            end

            3'b100 : begin // LBU
                result = {24'b0,lsu_res[7:0]};
            end

            3'b101 : begin // LHU
                result = {16'b0,lsu_res[15:0]};
            end

            default : begin

            end
        endcase
        rd_addr_o = rd_addr;
    end else begin
        result = '0;
        rd_addr_o = '0;
    end
end

endmodule
