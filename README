Building the caravel_openframe_project:
==================================================================
Tim Edwards
August 29, 2023

This is an example project of a picoRV32 processor and SoC that
roughly matches the management core used on first Efabless SkyWater
OpenMPW.  However, this project is intended to synthesize into the
project area of the Caravel Openframe, which is a version of
Caravel maintaining the padframe and pinout but containing no
other resources except for a power-on-reset circuit and a user
ID via-programmed ROM.  This repository is independent of the
Caravel Openframe but depends on the Caravel Openframe verilog
code for testbench simulation/verification.  The Openframe
wrapper layout exists as a DEF file

	openframe_project_wrapper.def

in the path

	openlane/openframe_project_wrapper/fixed_dont_change/.

The only other files needed for any Openframe project are the
power connection cells vccd1_connection and vssd1_connection.
(GDS, LEF, gate-level verilog, etc.)

==================================================================
These instructions are for building the openframe example project
using a standalone set of EDA tools.  The set of tools needed for
the build is:

	OpenROAD	https://github.com/The-OpenROAD-Project/OpenROAD
	openlane	https://github.com/The-OpenROAD-Project/openlane
	yosys		https://github.com/YosysHQ/yosys
	klayout		https://github.com/KLayout/klayout
	magic		https://github.com/RTimothyEdwards/magic

Note that the above tools have numerous dependencies, some of which
require compiling additional tools from git sources.  This set of
instructions does not include how to compile everything from source.
All the tools above were git pulled and current as of Aug. 29, 2023.

All files in the repository constitute the minimum set needed to
rebuild the GDS layout of the caravel openframe project example.

==================================================================
Steps to build:
(0) Preparation:

	Go to this repository.  I have it put in ~/gits/ along with
	everything else I clone from git repositories:

		cd ~/gits/caravel_openframe_project

	Set up the technology.  The PDK is installed locally with
	open_pdks using --prefix=/usr, so that the PDK is rooted
	at /usr/share/pdk:

		setenv PDK_ROOT /usr/share/pdk
		setenv PDK sky130A

	Check out a new branch for building so as not to sully the
	upstream repository with build files:

		git branch build
		git checkout build

	Create python virtual environment.  I have openlane cloned
	into the ~/gits/ directory.  Openlane is just a set of
	scripts and does not install like normal software, so it
	is referenced from the source directory.  I run a local
	tcsh environment, which is why I use activate.csh.

		python3 -m venv ./venv
		./venv/bin/python3 -m pip install --upgrade --no-cache-dir \
			-r ~/gits/openlane/requirements.txt
		source ./venv/bin/activate.csh
		
(1) Build digital_locked_loop circuit:
	This subcomponent contains a ring oscillator and needs to
	be self-contained.

		cd openlane/digital_locked_loop
		~/gits/openlane/flow.tcl -ignore_mismatches

	Copy the built files to the top level (name of run directory is
	time-dependent, change accordingly) (again, this is in a tcsh
	environment;  use export instead of setenv in a bash environment):

		setenv RUNDIR RUN_2023.08.29_14.59.39
		cp runs/$RUNDIR/results/final/gds/digital_locked_loop.gds \
			../../gds/
		cp runs/$RUNDIR/results/final/lib/digital_locked_loop.lib \
			../../lib/
		cp runs/$RUNDIR/results/final/lef/digital_locked_loop.lef \
			../../lef/
		mkdir -p ../../verilog/gl
		cp runs/$RUNDIR/results/final/verilog/gl/digital_locked_loop.v \
			../../verilog/gl/
		mkdir -p ../../signoff/digital_locked_loop/openlane-signoff/spef
		cp runs/$RUNDIR/results/final/spef/multicorner/digital_locked_loop.* \
			../../signoff/digital_locked_loop/openlane-signoff/spef/

(2) Build the picosoc processor:
	Contains the bulk of the project example, including SRAM
	macros, and the digital_locked_loop macro.  This is the
	bulk of the example, and takes the longest to run through
	synthesis, place, and route.

		cd ../picosoc
		~/gits/openlane/flow.tcl -ignore_mismatches

	Copy the built files to the top level (see above):

		setenv RUNDIR RUN_2023.08.29_15.08.17
		cp runs/$RUNDIR/results/final/gds/picosoc.gds ../../gds/
		cp runs/$RUNDIR/results/final/lib/picosoc.lib ../../lib/
		cp runs/$RUNDIR/results/final/lef/picosoc.lef ../../lef/
		cp runs/$RUNDIR/results/final/verilog/gl/picosoc.v ../../verilog/gl/
		mkdir -p ../../signoff/picosoc/openlane-signoff/spef
		cp runs/$RUNDIR/results/final/spef/multicorner/picosoc.* \
			../../signoff/picosoc/openlane-signoff/spef/

(3) Build the openframe_project_wrapper:
	Placement of the picosoc macro and wiring out to the
	wrapper pins.

		cd ../openframe_project_wrapper
		~/gits/openlane/flow.tcl -ignore_mismatches

	Copy final files to the top level:

		setenv RUNDIR RUN_2023.08.29_15.52.52
		cp runs/$RUNDIR/results/final/gds/openframe_project_wrapper.gds \
			../../gds/
		cp runs/$RUNDIR/results/final/verilog/gl/openframe_project_wrapper.v \
			../../verilog/gl/

	Additional work needed to get GL simulation running:
	caravel_openframe_project/verilog/gl/openframe_project_wrapper.v does
	not have all of the power supplies listed, only the vccd1 and vssd1 that
	are used by the module.  The remaining power supply pins need to be added
	to the list of module I/Os (matching the I/O list in the RTL module for
	openframe_project_wrapper.v).

	Currently, the GL simulaton also fails because the caravel repository
	has entries in verilog/rtl/openframe_netlists.v in the GL case of
	gl/user_id_programming.v, gl/chip_io_openframe.v, and gl/caravel_openframe.v.
	All three of these are already structural verilog, exist in rtl/ and do
	not have corresponding entries in gl/.  The "gl/" prefix needs to be
	removed.  This may get fixed by separate pull request.

(4) Run verilog verification on RTL and gate-level netlists:
	Needed: (1) RISC-V toolchain with RV32IMC architecture support
		(2) iverilog
		(3) The caravel repository from
			https://github.com/efabless/caravel
		    (This contains the openframe definition in verilog)

	Do the following:

		cd ~/gits/caravel_openframe_wrapper/verilog/dv/gpio_vector
		
	(Set environment variables PDK_ROOT, GCC_PATH, GCC_PREFIX,
	and CARAVEL_ROOT as needed if they don't match what's in
	the Makefile.)

		make

	for the RTL simulation, and

		make SIM=GL

	for the gate-level simulation.  Both should end with the output
	"Monitor: gpio_vector test Passed".

(5) Remove unneeded files and compress the final GDS:
	The resulting compressed project wrapper GDS is about 115MB.

		cd ~/gits/caravel_openframe_wrapper/gds
		rm digital_locked_loop.gds
		rm picosoc.gds
		gzip -n --best openframe_project_wrapper.gds
		cd ..
