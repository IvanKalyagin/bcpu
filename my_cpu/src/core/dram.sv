

module dram  
    import cpu_config::*;
    import riscv_types::*;
    import cpu_types::*;
    (
        input logic clk,
        input logic rst,

        input logic[XLEN-1:0] addr_a,
        input logic load,
        input logic store,
        input logic [XLEN-1:0] data_in,

        output logic [XLEN-1:0] data_out_a
    );

    (* ram_style = "block", ramstyle = "no_rw_check" *) logic  [XLEN-1:0] tag_entry [LINES];
    initial tag_entry = '{default: 0};

    always_ff @ (posedge clk) begin
        if (load) begin
            data_out_a <= tag_entry[addr_a];
        end
        if (store) begin
            tag_entry[addr_a] <= data_in;
        end
    end

endmodule
