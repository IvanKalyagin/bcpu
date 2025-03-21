transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

set HEX_FILE $1

vlog -sv -svinputport=net -work work +incdir+lib {lib/cpu_config.sv}
vlog -sv -svinputport=net -work work +incdir+lib {lib/riscv_types.sv}
vlog -sv -svinputport=net -work work +incdir+lib {lib/cpu_types.sv}
vlog -sv -svinputport=net -work work +incdir+core/pipeline {core/pipeline/alu.sv}
vlog -sv -svinputport=net -work work +incdir+core/pipeline {core/pipeline/idu.sv}
vlog -sv -svinputport=net -work work +incdir+core/pipeline {core/pipeline/ifu.sv}
vlog -sv -svinputport=net -work work +incdir+core/pipeline {core/pipeline/register_file.sv}
vlog -sv -svinputport=net -work work +incdir+core/pipeline {core/pipeline/wb.sv}
vlog -sv -svinputport=net -work work +incdir+core {core/thread_timer.sv}
vlog -sv -svinputport=net -work work +incdir+core {core/dram.sv}
vlog -sv -svinputport=net -work work +incdir+core {core/iram.sv}
vlog -sv -svinputport=net -work work +incdir+core {core/cpu_top.sv}
vlog -sv -svinputport=net -work work +incdir+core {core/cpu_wrapper.sv}

vlog -sv -svinputport=net -work work +incdir+my_tb {my_tb/tb.sv}

vsim -t 1ps -L rtl_work -L work -voptargs="+acc"  tb -G HEX_FILE=$HEX_FILE
