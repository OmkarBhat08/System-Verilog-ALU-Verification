coverage_it: simulate_it
	vcover report -details coverage.ucdb 

simulate_it: compile_file 
	vsim -c work.top -c -do "coverage save -onexit coverage.ucdb; run -all; exit"

compile_file:
	vlog -sv top.sv

clean:
	rm -rf covReport/ work/ 
	rm coverage.ucdb
