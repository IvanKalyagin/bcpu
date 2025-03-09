
/*
    Instruction Fetch Unit
*/


module ifu
    import cpu_config::*;
    import riscv_types::*;
    import cpu_types::*;
    (
    input logic rst,
    input logic clk,

    // Thread timer
    input logic [1:0] thread_id,

    input logic[XLEN-1:0] mem_data, // data from mem to ifu

    // From exu
    // input logic new_pc_req[3],  // Нужно ли
    input logic[28:0] new_pc,

    output logic[XLEN-1:0] pc2mem,
    output logic[XLEN-1:0] pc2decode,

    output logic [1:0] thread_idu_id,

    output logic[XLEN-1:0] curr_pc
);

logic[30:0] inc_pc[3]; // !!!!

assign pc2decode = mem_data; // либо в always

always @(posedge clk) begin
    if (rst) begin
        pc2mem <= {thread_timer, 30'h0000200}; //reset vector
    end else begin
        pc2mem <= {thread_timer, new_pc, 2'b00};
    end
end

always @(posedge clk) begin
    curr_pc <= pc2mem;
end

always @(posedge clk) begin
    thread_idu_id <= thread_id;
end

endmodule
