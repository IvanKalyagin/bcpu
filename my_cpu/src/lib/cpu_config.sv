
`ifndef _CPU_CONFIG_SV
`define _CPU_CONFIG_SV
package cpu_config;

////////////////////////////////////////////////////
    //Number of commit ports
    localparam COMMIT_PORTS = 2; //min 2
    localparam REGFILE_READ_PORTS = 2; //min 2, for RS1 and RS2

endpackage
`endif //_CPU_CONFIG_SV

