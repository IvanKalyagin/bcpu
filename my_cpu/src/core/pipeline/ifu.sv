
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
    input logic[ADDR_LEN-3:0] new_pc,

    output logic[ADDR_LEN-1:0] pc2mem,
    output logic[XLEN-1:0] pc2decode,

    output logic [1:0] thread_idu_id,

    output logic[ADDR_LEN-3:0] curr_pc
);

// logic[30:0] inc_pc[3]; // !!!!
logic rst_ff;

always @(posedge clk) begin
    rst_ff <= rst;
end

always_comb begin
    if (~rst_ff)
        pc2decode = mem_data;
end

always @(posedge clk) begin
    if (rst) begin
        pc2mem <= {thread_id, 13'h0000000}; //reset vector
    end else begin
        pc2mem <= {thread_id, new_pc};
    end
end

always @(posedge clk) begin
    curr_pc <= pc2mem;
end

always @(posedge clk) begin
    thread_idu_id <= thread_id;
end

endmodule
