
// Arithmetic Logic module


module alu 
    import cpu_config::*;
    import riscv_types::*;
    import cpu_types::*;
    (

    input   logic           rst,
    input   logic           clk,

    input logic rs1_en,
    input logic rs2_en,
    input logic rd_en,
    input logic[XLEN-1:0] rs1_data,
    input logic[XLEN-1:0] rs2_data,
    input rs_addr_t rd_addr,

    input logic jal_req,
    input logic jalr_req,
    input logic b_req,
    input logic lui_req;
    input logic auipc_req;
    input logic l_req,
    input logic s_req,
    
    input logic [2:0] cmd,
    input alu_logic_op_t alu_logic_op,
    input logic logic_op,
    input logic sub,
    input logic sra_cmd, 

    input logic[XLEN-1:0] curr_pc,

    input logic[XLEN-1:0] data,

    input logic [1:0] thread_exu_id,

    input logic illegal_inst,

    output logic rd_en_o,
    output rs_addr_t rd_addr_o,
    output logic[XLEN-1:0] rd_data,

    output logic alu_res_en,
    output logic lsu_res_en, 

    output logic [1:0] thread_exu_id_out,

    // New pc
    output logic[28:0] new_pc
);
    logic[XLEN:0] add_sub_result;
    logic add_sub_carry_in;
    logic[XLEN-1:0] shift_result;

    logic[XLEN:0] adder_in1;
    logic[XLEN:0] adder_in2;

    logic[XLEN-1:0] result;

    logic[XLEN-1:0] inc_pc;

    alu_inputs_t alu_inputs;

    //implementation
    ////////////////////////////////////////////////////

    assign rd_en_o = rd_en;

    always_comb begin
        if (rs1_en)
            alu_inputs.in1 = rs1_data;
        else
            alu_inputs.in1 = curr_pc;
        if (rs2_en && !s_req)
            alu_inputs.in2 = rs2_data;
        else
            alu_inputs.in2 = data;
        alu_inputs.subtract = sub;
    end

    //Logic ops put through the adder carry chain to reduce resources
    always_comb begin
        case (logic_op)
            ALU_LOGIC_XOR : adder_in1 = alu_inputs.in1 ^ alu_inputs.in2;    
            ALU_LOGIC_OR : adder_in1 = alu_inputs.in1 | alu_inputs.in2;
            ALU_LOGIC_AND : adder_in1 = alu_inputs.in1 & alu_inputs.in2;
            ALU_LOGIC_ADD : adder_in1 = alu_inputs.in1;
        endcase
        case (logic_op)
            ALU_LOGIC_XOR : adder_in2 = 0;
            ALU_LOGIC_OR : adder_in2 = 0;
            ALU_LOGIC_AND : adder_in2 = 0;
            ALU_LOGIC_ADD : adder_in2 = alu_inputs.in2 ^ {33{alu_inputs.subtract}};
        endcase
    end

    assign {add_sub_result, add_sub_carry_in} = {adder_in1, alu_inputs.subtract} + {adder_in2, alu_inputs.subtract};

    always_comb begin
        main_sum_pos_ovflw = ~adder_in1[XLEN-1]
                        &  adder_in2[XLEN-1]
                        &  add_sub_result[XLEN-1];
        main_sum_neg_ovflw =  adder_in1[XLEN-1]
                        & ~adder_in2[XLEN-1]
                        & ~add_sub_result[XLEN-1];

        // FLAGS1 - flags for comparison (result of subtraction)
        main_sum_flag_c = add_sub_result[XLEN];
        main_sum_flag_z = ~|add_sub_result[XLEN-1:0];
        main_sum_flag_s = add_sub_result[XLEN-1];
        main_sum_flag_o = main_sum_pos_ovflw | main_sum_neg_ovflw;
    end

    always_comb begin
        if (logic_op) begin
            case (cmd)
                3'b001 : begin // SLL
                    result = alu_inputs.in1 << alu_inputs.in2;
                end

                3'b101 : begin // SR
                    if (sra_cmd) begin
                        result = alu_inputs.in1 >>$ alu_inputs.in2;
                    end else begin
                        result = alu_inputs.in1 >>> alu_inputs.in2;
                    end
                end

                3'b010 : begin // SLT
                    if (main_sum_flag_s ^ main_sum_flag_o) begin
                        result = 'd1;
                    end else begin
                        result = 'd0;
                    end
                end

                3'b011 : begin // SLTU
                    if (main_sum_flag_s ^ main_sum_flag_o) begin
                        result = 'd1;
                    end else begin
                        result = 'd0;
                    end
                end

                default : result = add_sub_result;
            endcase
        end
    end

    // barrel_shifter shifter (
    //         .shifter_input(alu_inputs.shifter_in),
    //         .shift_amount(alu_inputs.shift_amount),
    //         .arith(alu_inputs.arith),
    //         .lshift(alu_inputs.lshift),
    //         .shifted_result(shift_result)
    //     );

    // always_comb begin
    //     result = (alu_inputs.shifter_path ? shift_result : add_sub_result[31:0]);
    //     result[31:1] &= {31{~alu_inputs.slt_path}};
    //     result[0] = alu_inputs.slt_path ? add_sub_result[XLEN] : result[0];
    // end

    always_comb begin
        if (b_req) begin
            case (cmd)
                3'b000 : begin // BEQ
                    if (main_sum_flag_z) begin
                        inc_pc = result[30:2];
                    end else begin
                        inc_pc = curr_pc + 'd4;
                    end
                end

                3'b001 : begin // BNE
                    if (~main_sum_flag_z) begin
                        inc_pc = result[30:2];
                    end else begin
                        inc_pc = curr_pc + 'd4;
                    end
                end

                3'b100 : begin // BLT
                    if (main_sum_flag_s ^ main_sum_flag_o) begin
                        inc_pc = result[30:2];
                    end else begin
                        inc_pc = curr_pc + 'd4;
                    end
                end

                3'b101 : begin // BGE
                    if (~(main_sum_flag_s ^ main_sum_flag_o)) begin
                        inc_pc = result[30:2];
                    end else begin
                        inc_pc = curr_pc + 'd4;
                    end
                end

                3'b110 : begin // BLTU
                    if (main_sum_flag_c) begin
                        inc_pc = result[30:2];
                    end else begin
                        inc_pc = curr_pc + 'd4;
                    end
                end

                3'b111 : begin // BGEU
                    if (~main_sum_flag_c) begin
                        inc_pc = result[30:2];
                    end else begin
                        inc_pc = curr_pc + 'd4;
                    end
                end

                default : inc_pc = curr_pc + 'd4;

            endcase
        end else if (jal_req || jalr_req) begin
            inc_pc = result[30:2];
        end else begin
            inc_pc = curr_pc + 'd4;
        end 
    end

    ////////////////////////////////////////////////////
    //Output
    always_ff @( posedge clk ) begin
        rd_en_o <= rd_en;
        rd_addr_o <= rd_addr;
        if (jal_req || jalr_req) begin
            rd_data <= curr_pc + 'd4;
        end else begin
            rd_data <= result;
        end 
        new_pc <= inc_pc;
        thread_exu_id_out <= thread_exu_id;
    end
    ////////////////////////////////////////////////////
    //Assertions

endmodule
