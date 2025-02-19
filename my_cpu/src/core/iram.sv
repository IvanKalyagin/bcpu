

module iram  
    (
        input logic clk,
        input logic rst,

        input logic[XLEN-1:0] addr_a
        input logic en_a
        output logic [XLEN-1:0] data_out_a
    );

    (* ram_style = "block", ramstyle = "no_rw_check" *) logic  [XLEN-1:0] tag_entry [LINES];
    initial tag_entry = '{default: 0};

    always_ff @ (posedge clk) begin
        if (en_a) begin
            data_out_a <= tag_entry[addr_a];
        end
    end

endmodule
