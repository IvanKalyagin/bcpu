// Decode module


module idu
    import cpu_config::*;
    import riscv_types::*;
    import cpu_types::*;
    (
    input logic rst,
    input logic clk,

    // Thread timer
    input logic [1:0] thread_id,

    input logic[XLEN-1:0] pc2decode, // data from ifu to idu
    input logic[ADDR_LEN-3:0] curr_pc,  // pc_addr

    output logic rs1_en,
    output logic rs2_en,
    output rs_addr_t rs1_addr_o,
    output rs_addr_t rs2_addr_o,

    output logic rd_en,
    output rs_addr_t rd_addr_o,

    output logic jal_req_o,
    output logic jalr_req_o,
    output logic b_req_o,
    output logic lui_req_o,
    output logic auipc_req_o,
    output logic l_req_o,
    output logic s_req_o,
    
    output logic [2:0] cmd_o,
    output alu_logic_op_t alu_logic_op_o,
    output logic logic_op_o,
    output logic sub_o,
    output logic sra_cmd_o,

    output logic[ADDR_LEN-3:0] curr_pc_o,

    output logic[XLEN-1:0] data_o,

    output logic [1:0] thread_exu_id,

    output logic illegal_inst_o
);

logic [4:0] cmd;
logic [2:0] fn3;
logic [4:0] fn5;
alu_logic_op_t alu_logic_op;
logic sub;
logic logic_op;

logic uses_rs1;
logic uses_rs2;
logic uses_rd;

logic jal_req;
logic jalr_req;
logic b_req;
logic lui_req;
logic auipc_req;
logic l_req;
logic s_req;

logic illegal_inst;

logic [4:0] rs1_addr;
logic [4:0] rs2_addr;
logic [4:0] rd_addr;

logic [XLEN-1:0] curr_data;

assign cmd = pc2decode[6:2];
assign fn3 = pc2decode[14:12];
assign fn5 = pc2decode[31:27];

assign rs1_addr = pc2decode[19:15];
assign rs2_addr = pc2decode[24:20];
assign rd_addr  = pc2decode[11:7];

always_comb begin
    uses_rs1 = 1'b0;
    uses_rs2 = 1'b0;
    uses_rd = 1'b0;
    jal_req = 1'b0;
    jalr_req = 1'b0;
    lui_req = 1'b0;
    auipc_req = 1'b0;
    s_req = 1'b0;
    l_req = 1'b0;
    sub = 1'b0;
    logic_op = 1'b0;
    illegal_inst = 1'b0;

    case (cmd)
        5'b11011 : begin // JAL
            uses_rd   = 1'b1;
            jal_req   = 1'b1;
            curr_data = signed'({pc2decode[31], pc2decode[19:12], pc2decode[20], pc2decode[30:21]}); 
            alu_logic_op = ALU_LOGIC_ADD;
        end

        5'b11001 : begin // JALR
            uses_rd   = 1'b1;
            uses_rs1  = 1'b1;
            jalr_req  = 1'b1;
            curr_data = {signed'(pc2decode[31:20])};
            alu_logic_op = ALU_LOGIC_ADD;
        end

        5'b01101 : begin // LUI
            uses_rd   = 1'b1;
            lui_req   = 1'b1;
            curr_data = {signed'(pc2decode[31:12]), 12'b0};
        end

        5'b00101 : begin // AUIPC
            uses_rd   = 1'b1;
            auipc_req = 1'b1;
            curr_data = {signed'(pc2decode[31:12]), 12'b0};
            alu_logic_op = ALU_LOGIC_ADD;
        end

        5'b11001 : begin // BRANCH
            b_req = 1'b1;
            case (fn3)
                3'b000 : begin // BEQ
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    curr_data = {20'b0, pc2decode[31], pc2decode[7], pc2decode[30:25], pc2decode[11:8]};
                    alu_logic_op = ALU_LOGIC_ADD;
                    sub = 1'b1;
                end

                3'b001 : begin // BNE
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    curr_data = {20'b0, pc2decode[31], pc2decode[7], pc2decode[30:25], pc2decode[11:8]};
                    alu_logic_op = ALU_LOGIC_ADD; // XOR?
                    sub = 1'b1;
                end

                3'b100 : begin // BLT
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    curr_data = signed'({pc2decode[31], pc2decode[7], pc2decode[30:25], pc2decode[11:8]});
                    alu_logic_op = ALU_LOGIC_ADD;
                    sub = 1'b1;
                end

                3'b101 : begin // BGE
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    curr_data = signed'({pc2decode[31], pc2decode[7], pc2decode[30:25], pc2decode[11:8]});
                    alu_logic_op = ALU_LOGIC_ADD;
                    sub = 1'b1;
                end

                3'b110 : begin // BLTU
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    curr_data = {20'b0, pc2decode[31], pc2decode[7], pc2decode[30:25], pc2decode[11:8]};
                    alu_logic_op = ALU_LOGIC_ADD;
                    sub = 1'b1;
                end

                3'b111 : begin // BGEU
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    curr_data = {20'b0, pc2decode[31], pc2decode[7], pc2decode[30:25], pc2decode[11:8]};
                    alu_logic_op = ALU_LOGIC_ADD;
                    sub = 1'b1;
                end

                default : illegal_inst = 1'b1;
            endcase
        end

        5'b00100 : begin // logic immediate
            logic_op = 1'b1;
            case (fn3)
                3'b000 : begin // ADDI
                    uses_rs1 = 1'b1;
                    uses_rd  = 1'b1;
                    curr_data = {signed'(pc2decode[31:20])};
                    alu_logic_op = ALU_LOGIC_ADD;
                end

                3'b010 : begin //   SLTI
                    uses_rs1 = 1'b1;
                    uses_rd  = 1'b1;
                    curr_data = {signed'(pc2decode[31:20])};
                    alu_logic_op = ALU_LOGIC_ADD;
                    sub = 1'b1;
                end

                3'b011 : begin //   SLTIU
                    uses_rs1 = 1'b1;
                    uses_rd  = 1'b1;
                    curr_data = {20'b0, pc2decode[31:20]};
                    alu_logic_op = ALU_LOGIC_ADD;
                    sub = 1'b1;
                end

                3'b100 : begin //   XORI
                    uses_rs1 = 1'b1;
                    uses_rd  = 1'b1;
                    curr_data = {signed'(pc2decode[31:20])};
                    alu_logic_op = ALU_LOGIC_XOR;
                end

                3'b110 : begin //   ORI
                    uses_rs1 = 1'b1;
                    uses_rd  = 1'b1;
                    curr_data = {signed'(pc2decode[31:20])};
                    alu_logic_op = ALU_LOGIC_OR;
                end

                3'b111 : begin //   ANDI
                    uses_rs1 = 1'b1;
                    uses_rd  = 1'b1;
                    curr_data = {signed'(pc2decode[31:20])};
                    alu_logic_op = ALU_LOGIC_AND;
                end

                3'b001 : begin //   SLLI
                    uses_rs1 = 1'b1;
                    uses_rd  = 1'b1;
                    curr_data = {27'b0, pc2decode[24:20]};
                end

                3'b101 : begin //   SRI
                    case (fn5)
                        5'b00000 : begin //  SRLI
                            uses_rs1 = 1'b1;
                            uses_rd  = 1'b1;
                            curr_data = {27'b0, pc2decode[24:20]};
                        end

                        5'b01000 : begin //  SRAI
                            uses_rs1 = 1'b1;
                            uses_rd  = 1'b1;
                            curr_data = {27'b0, pc2decode[24:20]};
                        end

                        default : illegal_inst = 1'b1;
                    endcase
                end

                default : illegal_inst = 1'b1;
            endcase
        end

        5'b01100 : begin // logic
            logic_op = 1'b1;
            case (fn3)
                3'b000 : begin // arithmetic
                    case (fn5)
                        5'b00000 : begin //ADD
                            uses_rs1 = 1'b1;
                            uses_rs2 = 1'b1;
                            uses_rd  = 1'b1;
                            alu_logic_op = ALU_LOGIC_ADD;
                        end

                        5'b01000 : begin //SUB
                            uses_rs1 = 1'b1;
                            uses_rs2 = 1'b1;
                            uses_rd  = 1'b1;
                            alu_logic_op = ALU_LOGIC_ADD;
                            sub = 1'b1;
                        end

                        default : illegal_inst = 1'b1;
                    endcase
                end

                3'b001 : begin //   SLL
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1; // shamt
                    uses_rd  = 1'b1;
                end

                3'b010 : begin //   SLT
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1; 
                    uses_rd  = 1'b1;
                end

                3'b011 : begin //   SLTU
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    uses_rd  = 1'b1;
                end

                3'b100 : begin //   XOR
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    uses_rd  = 1'b1;
                    alu_logic_op = ALU_LOGIC_XOR;
                end

                3'b101 : begin //   SR
                    case (fn5)
                        5'b00000 : begin //  SRL
                            uses_rs1 = 1'b1;
                            uses_rs2 = 1'b1;
                            uses_rd  = 1'b1;
                        end

                        5'b01000 : begin //  SRA
                            uses_rs1 = 1'b1;
                            uses_rs2 = 1'b1;
                            uses_rd  = 1'b1;
                        end

                        default : illegal_inst = 1'b1;
                    endcase
                end

                3'b110 : begin //   OR
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    uses_rd  = 1'b1;
                    alu_logic_op = ALU_LOGIC_OR;
                end

                3'b111 : begin //   AND
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    uses_rd  = 1'b1;
                    alu_logic_op = ALU_LOGIC_AND;
                end

                default : illegal_inst = 1'b1;
            endcase
        end

        5'b00000 : begin // LOAD
            l_req   = 1'b1;
            logic_op = 1'b1;
            case (fn3)
                3'b000 : begin // LB
                    uses_rs1 = 1'b1;
                    uses_rd  = 1'b1;
                    curr_data = {signed'(pc2decode[31:20])};
                    alu_logic_op = ALU_LOGIC_ADD;
                end

                3'b001 : begin // LH
                    uses_rs1 = 1'b1;
                    uses_rd  = 1'b1;
                    curr_data = {signed'(pc2decode[31:20])};
                    alu_logic_op = ALU_LOGIC_ADD;
                end

                3'b010 : begin // LW
                    uses_rs1 = 1'b1;
                    uses_rd  = 1'b1;
                    curr_data = {signed'(pc2decode[31:20])};
                    alu_logic_op = ALU_LOGIC_ADD;
                end

                3'b100 : begin // LBU
                    uses_rs1 = 1'b1;
                    uses_rd  = 1'b1;
                    curr_data = {signed'(pc2decode[31:20])};
                    alu_logic_op = ALU_LOGIC_ADD;
                end

                3'b101 : begin // LHU
                    uses_rs1 = 1'b1;
                    uses_rd  = 1'b1;
                    curr_data = {signed'(pc2decode[31:20])};
                    alu_logic_op = ALU_LOGIC_ADD;
                end

                default : illegal_inst = 1'b1;
            endcase
        end

        'b01000 : begin // STORE    
            s_req   = 1'b1;
            logic_op = 1'b1;
            case (fn3)
                3'b000 : begin // SB
                    uses_rs1 = 1'b1;
                    uses_rs2  = 1'b1;
                    curr_data = signed'({pc2decode[31:25], pc2decode[11:7]});
                    alu_logic_op = ALU_LOGIC_ADD;
                end

                3'b001 : begin // SH
                    uses_rs1 = 1'b1;
                    uses_rs2  = 1'b1;
                    curr_data = signed'({pc2decode[31:25], pc2decode[11:7]});
                    alu_logic_op = ALU_LOGIC_ADD;
                end

                3'b010 : begin // SW
                    uses_rs1 = 1'b1;
                    uses_rs2  = 1'b1;
                    curr_data = signed'({pc2decode[31:25], pc2decode[11:7]});
                    alu_logic_op = ALU_LOGIC_ADD;
                end

                default : illegal_inst = 1'b1;
            endcase
        end

        default : illegal_inst = 1'b1;
    endcase

    //TODO add CSR instructions
    // Also mei and others from RV32I
end

always_ff @(posedge clk) begin
    rd_en  <= uses_rd && (rd_addr != '0); // Проверка, что не пишем в 0 регистр
    rs1_en <= uses_rs1;
    rs2_en <= uses_rs2;

    rd_addr_o  <= rd_addr;
    rs1_addr_o <= rs1_addr;
    rs2_addr_o <= rs2_addr;

    jal_req_o   <= jal_req;
    jalr_req_o  <= jalr_req;
    b_req_o     <= b_req;
    lui_req_o   <= lui_req;
    auipc_req_o <= auipc_req;
    l_req_o <= l_req;
    s_req_o <= s_req;

    data_o <= curr_data;

    sub_o <= sub;
    cmd_o <= fn3;
    alu_logic_op_o <= alu_logic_op;
    logic_op_o <= logic_op;
    sra_cmd_o <= fn5[3];

    illegal_inst_o <= !illegal_inst && &pc2decode[1:0];
end

always_ff @(posedge clk) begin
    curr_pc_o <= curr_pc;
end

always_ff @(posedge clk) begin
    thread_exu_id <= thread_id;
end

endmodule
