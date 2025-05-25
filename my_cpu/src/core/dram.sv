

module dram  
    
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
        input logic[XLEN/8-1:0] be_a,
        input logic load,
        input logic store,
        input logic [XLEN-1:0] data_in,

        output logic [XLEN-1:0] data_out_a
    );

    (* ram_style = "block", ramstyle = "no_rw_check" *) logic  [XLEN-1:0] ram_block [LINES-1:0];
    // initial tag_entry = '{default: 0};
    initial
    begin
        if(USE_PRELOAD_FILE)
            $readmemh(preload_file, ram_block, 0, LINES-1);
    end

    generate
    genvar i;
        for(i=0;i<XLEN/8;i=i+1) begin
            always @ (posedge clk) begin
                if(store) begin
                    if(be_a[i]) begin
                        ram_block[addr_a][8*i+:8] <= data_in[8*i+:8];
                    end
                end
            end
        end
    endgenerate

    always @ (posedge clk) begin
        if(load) begin
            if (~|be_a)
                data_out_a <= ram_block[addr_a];
            end
    end

    // generate
    // genvar i;
    // for (i=0; i < XLEN/8; i++) begin
    //     always_ff @(posedge clk) begin
    //         if (load) begin
    //             if (be_a[i]) begin
    //                 data_out_a[8*i+:8] <= tag_entry[addr_a][8*i+:8];
    //             end
    //         end
    //         if (store) begin
    //             if (be_a[i]) begin
    //                 tag_entry[addr_a][8*i+:8] <= data_in[8*i+:8];
    //             end
    //         end
    //     end
    // end
    // endgenerate

    // always_ff @ (posedge clk) begin
    //     if (load) begin
    //         data_out_a <= tag_entry[addr_a];
    //     end
    //     if (store) begin
    //         tag_entry[addr_a] <= data_in;
    //     end
    // end

endmodule
