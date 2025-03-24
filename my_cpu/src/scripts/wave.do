onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/ext_reset
add wave -noupdate /tb/sys_clk
add wave -noupdate -radix decimal /tb/cyc_cnt
add wave -noupdate -divider {CPU}
add wave -noupdate /tb/uut/cpu/*
add wave -noupdate -divider Fetch
add wave -noupdate /tb/uut/cpu/ifu_block/*
add wave -noupdate -divider Decode
add wave -noupdate /tb/uut/cpu/idu_block/*
add wave -noupdate -divider ALU
add wave -noupdate /tb/uut/cpu/alu_block/*
add wave -noupdate -divider WB
add wave -noupdate /tb/uut/cpu/wb_block/*
add wave -noupdate -divider Register File
add wave -noupdate /tb/uut/cpu/reg_file_block/*
add wave -noupdate /tb/uut/cpu/reg_file_block/register_file