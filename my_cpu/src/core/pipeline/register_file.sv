
module register_file

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

    (* ram_style = "block", ramstyle = "no_rw_check" *) logic [XLEN-1:0] register_file_1 [128];  // (4 register files)
    (* ram_style = "block", ramstyle = "no_rw_check" *) logic [XLEN-1:0] register_file_2 [128];  // (4 register files)
    
    always_ff @ (posedge clk) begin
        if (rst) begin
            register_file_1 <= '{default: 0};
        end else begin
            if (wr_en) begin
                register_file_1[{thread_rd_id, rd_addr}] <= new_data; //thread timer 0 , 32, 64, 96
            end
        end
        if (rs1_en) begin
            rs1_data <= register_file_1[{thread_rs_id, rs1_addr}];
        end
    end

    always_ff @ (posedge clk) begin
        if (rst) begin
            register_file_2 <= '{default: 0};
        end else begin
            if (wr_en) begin
                register_file_2[{thread_rd_id, rd_addr}] <= new_data; //thread timer 0 , 32, 64, 96
            end
        end
        if (rs2_en) begin
            rs2_data <= register_file_2[{thread_rs_id, rs2_addr}];
        end
    end

endmodule
