.IGNORE:

# Default target
all: clean new_funct compile clear simulate coverage_report

# Clean build artifacts and temporary files
clean:
	rm -rf work/ transcript

# Remove previous coverage files
new_funct:
	rm -f alu_funct_coverage.ucdb

# Compile SystemVerilog code
compile:
	vlog -sv +acc +cover +fcover -l alu.log top.sv

# Run simulation with coverage and assertions
simulate:
	vsim -vopt work.top -voptargs=+acc=npr -assertdebug -l simulation.log -coverage -c -do \
		"coverage save -onexit -assert -directive -cvg -codeAll alu_coverage.ucdb; run -all; exit"

# Generate HTML coverage report
coverage_report:
	vcover report -html alu_coverage.ucdb -htmldir covReport -details

# Manually view coverage report in terminal
read_cov:
	vcover report -details alu_funct_coverage.ucdb

# Clear terminal screen twice
clear:
	clear
	clear

# Target to do a full test manually
main: clean
	vlog -sv +acc +cover +fcover -l alu.log top.sv
	make clear
	vsim -vopt work.top -voptargs=+acc=npr -assertdebug -l simulation.log -coverage -c -do \
		"coverage save -onexit -assert -directive -cvg -codeAll alu_coverage.ucdb; run -all; exit"
	vcover report -html alu_coverage.ucdb -htmldir covReport -details
