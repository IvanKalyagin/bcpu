   
package riscv_types;

    localparam XLEN = 32;
    localparam ECODE_W = 5;
    localparam LINES = 65536; //2^16
    localparam ADDR_LEN = $clog2(LINES);

    typedef logic [4:0] rs_addr_t;

endpackage
