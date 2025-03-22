

module iram  
    import cpu_config::*;
    import riscv_types::*;
    import cpu_types::*;
    #(
        parameter preload_file = "",
        parameter USE_PRELOAD_FILE = 0
    )
    (
        input logic clk,
        input logic rst,

        input logic[ADDR_LEN-1:0] addr_a,
        // input logic en_a,
        output logic [XLEN-1:0] data_out_a
    );

    (* ram_style = "block", ramstyle = "no_rw_check" *) logic  [XLEN-1:0] tag_entry [LINES-1:0];
    // initial tag_entry = '{default: 0};

    initial
    begin
        if(USE_PRELOAD_FILE)
            $readmemh(preload_file, tag_entry, 0, LINES-1);
    end

    always_ff @ (posedge clk) begin
        // if (en_a) begin
            data_out_a <= tag_entry[addr_a];
        // end
    end

endmodule
