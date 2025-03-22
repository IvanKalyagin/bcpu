
module register_file

import cpu_config::*;
import riscv_types::*;
import cpu_types::*;
    (
        input logic clk,
        input logic rst,

        //Writeback
        input rs_addr_t rd_addr,
        input reg   [XLEN-1:0] new_data,
        input logic wr_en,

        //Thread_timer
        input logic [1:0] thread_rd_id,
        input logic [1:0] thread_rs_id,

        //rs1 rs2
        input rs_addr_t rs1_addr,
        input rs_addr_t rs2_addr,
        input logic rs1_en,
        input logic rs2_en,

        output reg [XLEN-1:0] rs1_data,
        output reg [XLEN-1:0] rs2_data
    );

    (* ram_style = "block" *)
    reg [XLEN-1:0] register_file [128];  // (4 register files)

    ////////////////////////////////////////////////////
    //Implementation

    ////////////////////////////////////////////////////
    //Register File
    //Assign zero to r0 and initialize all registers to zero

    always_ff @ (negedge rst) begin
        register_file <= '{default: 0};
    end
    
    always_ff @ (posedge clk) begin
        if (wr_en)
            register_file[{thread_rd_id, rd_addr}] <= new_data; //thread timer 0 , 32, 64, 96
        if (rs1_en)
            rs1_data <= register_file[{thread_rs_id, rs1_addr}];
        if (rs2_en)
            rs2_data <= register_file[{thread_rs_id, rs2_addr}];
    end

    ////////////////////////////////////////////////////
    //Assertions
/*    write_to_zero_reg_assertion:
        assert property (@(posedge clk) disable iff (rst) !(wr_en & rd_addr == 0))
        else $error("Write to zero reg occured!");
*/ //TODO: Assert
    ////////////////////////////////////////////////////
    //Simulation Only
    //synthesis translate_off
    // logic [31:0][31:0] sim_registers_unamed;
    // simulation_named_regfile sim_register;
    // always_comb begin
    //     //foreach(register_file[i])
	// 	  for(int i=0;i<32;i++)
    //         sim_registers_unamed[i] = register_file[i];
    //     sim_register = sim_registers_unamed;
    // end
    //synthesis translate_on

endmodule
