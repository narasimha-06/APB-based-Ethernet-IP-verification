home = /home/chicago/tools/Questa_2021.4_3/questasim/linux_x86_64/../modelsim.ini

pack = ../MCS_DV09_ETHERNET_TEST/mcs_dv09_ethernet_package.sv
interface = ../MCS_DV09_ETHERNET_INTERFACE/mcs_dv09_ethernet_interface.sv
top = ../MCS_DV09_ETHERNET_TOP/mcs_dv09_ethernet_top.sv

work:
	vlib work
map:
	vmap work work 

comp:
	vlog -work work +cover +acc -sv $(interface) $(pack) $(top) 
	vsim -debugdb -coverage -sva -c -do "log -r /*;coverage save -oneexit cover_file.ucdb -assert -directive -cvg -code All ;run -all ;exit" -coverage -sva -l ethernet_test.log work.ethernet_top +UVM_TESTNAME=ethernet_test +svSeed=RANDOM +UVM_VERBOSITY=UVM_NONE

TC_RESET:
	vlog -work work +cover +acc -sv $(interface) $(pack) $(top) 
	vsim -coverage -sva -c -do "log -r /*;coverage save -oneexit cover_file.ucdb -assert -directive -cvg -code All ;run -all ;exit" -coverage -sva -l ethernet_test.log work.ethernet_top +UVM_TESTNAME=TC_RESET +svSeed=RANDOM +UVM_VERBOSITY=UVM_MEDIUM

wave: 
	vsim -view vsim.wlf

merge:
	vcover merge all_cover.ucdb *.ucdb
	
clean:
	rm -rf *.ini transcript work regression_status_list *.log merge_list_file *.wlf .goutputstream* *.swp *.dbg wlf* *.vstf *.ucdb
