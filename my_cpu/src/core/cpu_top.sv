
module bcpu 
import cpu_config::*, riscv_types::*, cpu_types::*;
(
        input logic clk,
        input logic rst,

        input logic[XLEN-1:0] pc_data,
        output logic[ADDR_LEN-1:0] pc_addr,

        output logic[ADDR_LEN-1:0] dram_addr,
        output logic[XLEN-1:0] dram_data_out,
        input logic[XLEN-1:0] dram_data_in

            // TODO load store support
        );

    logic [1:0] thread_timer_data;
    logic [1:0] thread_idu_id;
    logic [1:0] thread_exu_id;
    logic [1:0] thread_wb_id;

    // IFU
    logic[ADDR_LEN-3:0] new_pc;
    logic[XLEN-1:0] pc2decode;
    logic[ADDR_LEN-3:0] curr_pc;

    // IDU
    logic rs1_en;
    logic rs2_en;
    rs_addr_t rs1_addr_o;
    rs_addr_t rs2_addr_o;
    logic rd_en;
    rs_addr_t rd_addr;

    logic jal_req_o;
    logic jalr_req_o;
    logic b_req_o;
    logic lui_req_o;
    logic auipc_req_o;
    logic l_req_o;
    logic s_req_o;
    
    logic [2:0] cmd_o;
    alu_logic_op_t alu_logic_op_o;
    logic logic_op_o;
    logic sub_o;
    logic sra_cmd_o;

    logic[ADDR_LEN-3:0] curr_pc_o;

    logic[XLEN-1:0] data_o;

    logic illegal_inst_o;

    // ALU
    logic[XLEN-1:0] rs1_data;
    logic[XLEN-1:0] rs2_data;

    logic rd_en_o;
    rs_addr_t rd_addr_o;
    logic[XLEN-1:0] rd_data;

    logic alu_res_en;
    logic lsu_res_en;

    // WB
    rs_addr_t rd_addr_wb;
    logic res_en;
    logic[XLEN-1:0] result;

    //----------------------------------------------------------
    thread_timer thread_timer_block(
        .clk(clk),
        .rst(rst),

        .thread_timer_data(thread_timer_data)

    );

    ifu ifu_block(
        .clk(clk),
        .rst(rst),

        .thread_id(thread_timer_data),

        .mem_data(pc_data),
        .new_pc(new_pc),

        .pc2mem(pc_addr),
        .pc2decode(pc2decode),

        .thread_idu_id(thread_idu_id),

        .curr_pc(curr_pc)
    );

    idu idu_block(
        .clk(clk),
        .rst(rst),

        // Thread timer
        .thread_id(thread_idu_id),

        .pc2decode(pc2decode), // data from ifu to idu
        .curr_pc(curr_pc),  // pc_addr

        .rs1_en(rs1_en),
        .rs2_en(rs2_en),
        .rs1_addr_o(rs1_addr_o),
        .rs2_addr_o(rs2_addr_o),

        .rd_en(rd_en),
        .rd_addr_o(rd_addr),

        .jal_req_o(jal_req_o),
        .jalr_req_o(jalr_req_o),
        .b_req_o(b_req_o),
        .lui_req_o(lui_req_o),
        .auipc_req_o(auipc_req_o),
        .l_req_o(l_req_o),
        .s_req_o(s_req_o),
        
        .cmd_o(cmd_o),
        .alu_logic_op_o(alu_logic_op_o),
        .logic_op_o(logic_op_o),
        .sub_o(sub_o),
        .sra_cmd_o(sra_cmd_o),

        .curr_pc_o(curr_pc_o),

        .data_o(data_o),

        .thread_exu_id(thread_exu_id),

        .illegal_inst_o(illegal_inst_o)
    );

    alu alu_block(
        .clk(clk),
        .rst(rst),

        .rs1_en(rs1_en),
        .rs2_en(rs2_en),
        .rd_en(rd_en),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .rd_addr(rd_addr),

        .jal_req(jal_req_o),
        .jalr_req(jalr_req_o),
        .b_req(b_req_o),
        .lui_req(lui_req_o),
        .auipc_req(auipc_req_o),
        .l_req(l_req_o),
        .s_req(s_req_o),
        
        .cmd(cmd_o),
        .alu_logic_op(alu_logic_op_o),
        .logic_op(logic_op_o),
        .sub(sub_o),
        .sra_cmd(sra_cmd_o),

        .curr_pc(curr_pc_o),

        .data(data_o),

        .thread_exu_id(thread_exu_id),

        .illegal_inst(illegal_inst_o),

        .rd_en_o(rd_en_o),
        .rd_addr_o(rd_addr_o),
        .rd_data(rd_data),

        .alu_res_en(alu_res_en),
        .lsu_res_en(lsu_res_en), 

        .thread_exu_id_out(thread_wb_id),

        .result(dram_data_out),

        // New pc
        .new_pc(new_pc)
    );

    wb wb_block(
        .clk(clk),
        .rst(rst),

        .alu_res(rd_data),
        .alu_res_en(alu_res_en),

        .lsu_res(dram_data_in),
        .lsu_res_en(lsu_res_en), 

        .rd_en(rd_en_o),
        .rd_addr(rd_addr_o),

        .rd_addr_o(rd_addr_wb),

        .res_en(res_en),
        .result(result)
    );

    register_file reg_file_block(
        .clk(clk),
        .rst(rst),

        //Writeback
        .rd_addr(rd_addr_wb),
        .new_data(result),
        .wr_en(res_en),

        //Thread_timer
        .thread_rd_id(thread_wb_id),
        .thread_rs_id(thread_idu_id),

        //rs1 rs2
        .rs1_en(rs1_en),
        .rs2_en(rs2_en),
        .rs1_addr(rs1_addr_o),
        .rs2_addr(rs2_addr_o),

        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );


endmodule
