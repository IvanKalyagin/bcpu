
package cpu_types;
    import riscv_types::*;

    typedef enum logic [1:0] {
        ALU_LOGIC_XOR = 2'b00,
        ALU_LOGIC_OR = 2'b01,
        ALU_LOGIC_AND =2'b10,
        ALU_LOGIC_ADD = 2'b11
    } alu_logic_op_t;

    typedef struct packed{
        logic [XLEN:0] in1;//contains sign padding bit for slt operation
        logic [XLEN:0] in2;//contains sign padding bit for slt operation
        logic [XLEN-1:0] shifter_in;
        logic [4:0] shift_amount;
        logic subtract;
        logic arith;//contains sign padding bit for arithmetic shift right operation
        logic lshift;
        alu_logic_op_t logic_op;
        logic shifter_path;
        logic slt_path;
    } alu_inputs_t;

    /* For test bench
    typedef enum logic [1:0] {
        ALU_ADD_SUB = 2'b00,
        ALU_SLT = 2'b01,
        ALU_RSHIFT =2'b10,
        ALU_LSHIFT =2'b11
    } alu_op_t; */

endpackage
