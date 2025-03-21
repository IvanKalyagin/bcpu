
import cpu_config::*, riscv_types::*, cpu_types::*;
module tb #(parameter HEX_FILE="") ();
   logic sys_clk; 
   logic ext_reset;
   
   
   cpu_wrapper #(.HEX_FILE(HEX_FILE)) uut(
        .sys_clk(sys_clk),
        .ext_reset(ext_reset)
   );
   
  initial 
  begin
	  sys_clk <= 0;
	  #1us;
	forever
	  #1us sys_clk <= ! sys_clk;
  end 

  initial 
  begin
	  ext_reset <= 1;
	for(int i=0; i< 5; i++)      
	  @(negedge sys_clk);
	    ext_reset <= 0;     
  end
        
endmodule 
