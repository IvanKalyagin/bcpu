// Decode module

module idu(
    input logic rst,
    input logic clk,

    // Thread timer
    input logic [1:0] thread_id,

    input logic[XLEN-1:0] pc2decode, // data from ifu to idu
    input logic[XLEN-1:0] curr_pc,  // pc_addr

    output logic rs1_en,
    output logic rs2_en,
    output rs_addr_t rs1_addr_o,
    output rs_addr_t rs2_addr_o,

    output logic rd_en,
    output rs_addr_t rd_addr_o,

    output logic [11:0] offset_o,

    output logic jal_req_o,
    output logic jalr_req_o,
    output logic b_req_o,
    output logic [2:0] branch_cmd,

    output logic [1:0] thread_exu_id,

    output logic[XLEN-1:0] curr_pc_o,

    output alu_inputs_t alu_inputs,

    output logic illegal_inst
);

logic [4:0] cmd;
logic [2:0] fn3;
logic [4:0] fn5;

logic uses_rs1;
logic uses_rs2;
logic uses_rd;
logic j_req;
logic b_req;

logic [4:0] rs1_addr;
logic [4:0] rs2_addr;
logic [4:0] rd_addr;

logic [11:0] offset;
logic [11:0] imm;
logic [19:0] offset_20;

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
    b_req = 1'b0;

    case (cmd)
        5'b11011 : begin // JAL
            uses_rd = 1'b1;
            jal_req = 1'b1;
            offset_20 = pc2decode[31, 19:12, 20, 30:21];
        end

        5'b11001 : begin // JALR
            uses_rd = 1'b1;
            uses_rs1 = 1'b1;
            jalr_req = 1'b1;
            offset = pc2decode[31:20];
        end

        5'b11001 : begin // BRANCH
            b_req = 1'b1;
            case (fn3)
                3'b000 : begin // BEQ
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    offset = pc2decode[31, 7, 30:25, 11:8];
                end

                3'b001 : begin // BNE
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    offset = pc2decode[31, 7, 30:25, 11:8];
                end

                3'b100 : begin // BLT
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    offset = pc2decode[31, 7, 30:25, 11:8];
                end

                3'b101 : begin // BGE
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    offset = pc2decode[31, 7, 30:25, 11:8];
                end

                3'b110 : begin // BLTU
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    offset = pc2decode[31, 7, 30:25, 11:8];
                end

                3'b111 : begin // BGEU
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    offset = pc2decode[31, 7, 30:25, 11:8];
                end

                default : illegal_inst = 1'b1;
            endcase
        end

        5'b00100 : begin // logic immediate
            case (fn3)
                3'b000 : begin // ADDI
                    uses_rs1 = 1'b1;
                    uses_rd = 1'b1;
                    imm = pc2decode[31:20];
                end

                3'b010 : begin //   SLTI
                    uses_rs1 = 1'b1;
                    uses_rd = 1'b1;
                    imm = pc2decode[31:20];
                end

                3'b011 : begin //   SLTIU
                    uses_rs1 = 1'b1;
                    uses_rd = 1'b1;
                    imm = pc2decode[31:20];
                end

                3'b100 : begin //   XORI
                    uses_rs1 = 1'b1;
                    uses_rd = 1'b1;
                    imm = pc2decode[31:20];
                end

                3'b110 : begin //   ORI
                    uses_rs1 = 1'b1;
                    uses_rd = 1'b1;
                    imm = pc2decode[31:20];
                end

                3'b111 : begin //   ANDI
                    uses_rs1 = 1'b1;
                    uses_rd = 1'b1;
                    imm = pc2decode[31:20];
                end

                3'b001 : begin //   SLLI
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1; // shamt
                    uses_rd = 1'b1;
                end

                3'b101 : begin //   SRI
                    case (fn5)
                        5'b00000 : begin //  SRLI
                            uses_rs1 = 1'b1;
                            uses_rs2 = 1'b1; // shamt
                            uses_rd = 1'b1;
                        end

                        5'b01000 : begin //  SRAI
                            uses_rs1 = 1'b1;
                            uses_rs2 = 1'b1; // shamt
                            uses_rd = 1'b1;
                        end

                        default : illegal_inst = 1'b1;
                    endcase
                end

                default : illegal_inst = 1'b1;
            endcase
        end

        5'b01100 : begin // logic
            case (fn3)
                3'b000 : begin // arithmetic
                    case (fn5)
                        5'b00000 : begin //ADD
                            uses_rs1 = 1'b1;
                            uses_rs2 = 1'b1;
                            uses_rd = 1'b1;
                        end

                        5'b01000 : begin //SUB
                            uses_rs1 = 1'b1;
                            uses_rs2 = 1'b1;
                            uses_rd = 1'b1;
                        end

                        default : illegal_inst = 1'b1;
                    endcase
                end

                3'b001 : begin //   SLL
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1; // shamt
                    uses_rd = 1'b1;
                end

                3'b010 : begin //   SLT
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1; 
                    uses_rd = 1'b1;
                end

                3'b011 : begin //   SLTU
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    uses_rd = 1'b1;
                end

                3'b100 : begin //   XOR
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    uses_rd = 1'b1;
                end

                3'b101 : begin //   SR
                    case (fn5)
                        5'b00000 : begin //  SRL
                            uses_rs1 = 1'b1;
                            uses_rs2 = 1'b1;
                            uses_rd = 1'b1;
                        end

                        5'b01000 : begin //  SRA
                            uses_rs1 = 1'b1;
                            uses_rs2 = 1'b1;
                            uses_rd = 1'b1;
                        end

                        default : illegal_inst = 1'b1;
                    endcase
                end

                3'b110 : begin //   OR
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    uses_rd = 1'b1;
                end

                3'b111 : begin //   AND
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    uses_rd = 1'b1;
                end

                default : illegal_inst = 1'b1;
            endcase
        end

        default : illegal_inst = 1'b1;
    endcase

    //TODO add CSR and LS instructions
    // Also mei and others from RV32I
end

always_ff @(posedge clk) begin
    rd_en  <= uses_rd;
    rs1_en <= uses_rs1;
    rs2_en <= uses_rs2;

    rd_addr_o  <= 5'b00000;
    rs1_addr_o <= 5'b00000;
    rs2_addr_o <= 5'b00000;

    jal_req_o  <= jal_req;
    jalr_req_o <= jalr_req;
    b_req_o    <= b_req;

    alu_inputs.in1 <= curr_pc;
    alu_inputs.in2 <= imm;
    if (jal_req)
        alu_inputs.in2 <= offset_20;
    if (jalr_req | b_req)
        alu_inputs.in2 <= offset;

    if (uses_rd)
        rd_addr_o <= rd_addr;
    if (uses_rs1)
        rs1_addr_o <= rs1_addr;
    if (uses_rs2)
        rs2_addr_o <= rs2_addr;
    if (b_req)
        branch_cmd <= fn3;
end

always_ff @(posedge clk) begin
    curr_pc_o <= curr_pc;
end

always_ff @(posedge clk) begin
    thread_exu_id <= thread_id;
end

endmodule
