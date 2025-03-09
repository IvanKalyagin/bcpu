
// module barrel_shifter 
// 	import taiga_config::*, taiga_types::*, riscv_types::*;
// 	(
//         input logic[XLEN-1:0] shifter_input,
//         input logic[4:0] shift_amount,
//         input logic arith,
//         input logic lshift,
//         output logic[XLEN-1:0] shifted_result
//         );

//     logic [62:0] shift_in;
//     logic [4:0] adjusted_shift_amount;
//     ////////////////////////////////////////////////////
//     //Implementation
//     //Performs a 63-bit right shift
//     //Left shift is handled by placing the left shift in the upper portion shifted by (~shift_amount + 1)
//     //with the value initially shifted by one so that only the complement of the shift_amount is needed
//     assign shift_in = lshift ? {shifter_input, 31'b0} : {{31{arith}}, shifter_input};
//     assign adjusted_shift_amount = shift_amount ^ {5{lshift}};
//     assign shifted_result = 32'(shift_in >> adjusted_shift_amount);
// endmodule
