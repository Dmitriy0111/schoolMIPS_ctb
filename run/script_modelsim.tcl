
vlib work

set i0 +incdir+../schoolMIPS/src
set i1 +incdir+../tb

set s0 ../schoolMIPS/src/*.*v
set s1 ../tb/*.*v

vlog $i0 $i1 $s0 $s1 
vlog ../schoolMIPS/testbench/sm_als_stub.v
vsim -novopt work.tb

add wave -divider  "Instruction strings"
add wave -position insertpoint sim:/tb/instruction
add wave -divider  "Testbench signals"
add wave -position insertpoint sim:/tb/*
add wave -divider  "schoolMIPS top module signals"
add wave -position insertpoint sim:/tb/sm_top_0/*

run -all

wave zoom full

quit
