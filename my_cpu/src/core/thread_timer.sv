
/*
    Module that every cycle increase timer for switching register file
*/

module thread_timer (

    input   logic           rst,
    input   logic           clk,

    output  logic [1:0]    thread_timer_data

)

    always_ff @(posedge clk) begin
        if (rst) begin
            thread_timer_data <= '0;
        end else begin
            thread_timer_data <= thread_timer_data + 'b1;
        end
    end

endmodule // thread_timer
