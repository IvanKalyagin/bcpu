
// import taiga_config::*;
import riscv_types::*;
// import taiga_types::*;

module alu (
    input   logic           rst,
    input   logic           clk,

    input alu_inputs_t alu_inputs,

    input logic rs1_en,
    input logic rs2_en,
    input logic rd_en,
    input logic[XLEN-1:0] rs1_data,
    input logic[XLEN-1:0] rs2_data,
    input rs_addr_t rd_addr,

    output logic rd_en_o,
    output logic[XLEN-1:0] rd_data,

    // New pc
    output logic[28:0] new_pc[3]
);
    logic[XLEN:0] add_sub_result;
    logic add_sub_carry_in;
    logic[XLEN-1:0] shift_result;

    logic[XLEN:0] adder_in1;
    logic[XLEN:0] adder_in2;

    logic[XLEN-1:0] result;

    logic[30:0] inc_pc;

    // alu_inputs_t alu_inputs;

    //implementation
    ////////////////////////////////////////////////////

    assign rd_en_o = rd_en;

    always_comb begin
        if (rs1_en)
            alu_inputs.in1 = rs1_data;
        if (rs2_en)
            alu_inputs.in2 = rs2_data;
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

    barrel_shifter shifter (
            .shifter_input(alu_inputs.shifter_in),
            .shift_amount(alu_inputs.shift_amount),
            .arith(alu_inputs.arith),
            .lshift(alu_inputs.lshift),
            .shifted_result(shift_result)
        );

    always_comb begin
        result = (alu_inputs.shifter_path ? shift_result : add_sub_result[31:0]);
        result[31:1] &= {31{~alu_inputs.slt_path}};
        result[0] = alu_inputs.slt_path ? add_sub_result[XLEN] : result[0];
    end

    ////////////////////////////////////////////////////
    //Output
    always_comb begin
        if (rd_en_o)
            rd_data = result;
    end
    ////////////////////////////////////////////////////
    //Assertions

endmodule
