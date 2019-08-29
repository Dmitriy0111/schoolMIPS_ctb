
help:
	$(info make help           - show this message)
	$(info make clean          - delete synth and simulation folders)
	$(info make sim            - the same as sim_gui)
	$(info make synth          - clean, create the board project and run the synthesis (for default board))
	$(info make open           - the same as synth_gui)
	$(info make load           - the same as synth_load)
	$(info make sim_cmd        - run simulation in Modelsim (console mode))
	$(info make sim_gui        - run simulation in Modelsim (gui mode))
	$(info make prog_comp      - compile program and copy program.hex to program_file folder)
	$(info make prog_copy_hex  - copy program.hex to program_file folder)
	$(info Open and read the Makefile for details)
	@true

PWD     := $(shell pwd)
BRD_DIR  = $(PWD)/board
RUN_DIR  = $(PWD)/run
RTL_DIR  = $(PWD)/rtl
TB_DIR   = $(PWD)/tb

########################################################
# common make targets

show_pwd:
	PWD

clean: \
	sim_clean \
	log_clean \
	prog_clean

sim_all: \
	sim_cmd 

sim: sim_gui

########################################################
# simulation - Modelsim

VSIM_DIR = $(PWD)/sim_modelsim

VLIB_BIN = cd $(VSIM_DIR) && vlib
VLOG_BIN = cd $(VSIM_DIR) && vlog
VSIM_BIN = cd $(VSIM_DIR) && vsim

VSIM_OPT_COMMON += -do $(RUN_DIR)/script_modelsim.tcl -onfinish final

VSIM_OPT_CMD     = -c
VSIM_OPT_CMD    += -onfinish exit

VSIM_OPT_GUI     = -gui -onfinish stop

sim_clean:
	rm -rfd $(VSIM_DIR)
	rm -rfd log

sim_dir: sim_clean
	mkdir $(VSIM_DIR)
	mkdir log

sim_cmd: sim_dir
	$(VSIM_BIN) $(VSIM_OPT_COMMON) $(VSIM_OPT_CMD)

sim_gui: sim_dir
	$(VSIM_BIN) $(VSIM_OPT_COMMON) $(VSIM_OPT_GUI) &

########################################################
# compiling  - program

PROG_LIST ?= 00_counter 01_fibonacci 02_sqrt 03_ram 04_gpio 05_pwm 06_als

PROG_NAME ?= 00_counter

show_progs:
	echo $(PROG_LIST)

prog_comp:
	mkdir -p program_file
	java -jar schoolMIPS/scripts/bin/Mars4_5.jar nc a dump .text HexText program_file/program.hex schoolMIPS/program/$(PROG_NAME)/main.S

prog_copy_hex:
	mkdir -p program_file
	cp schoolMIPS/program/$(PROG_NAME)/program.hex program_file/program.hex

prog_clean:
	rm -rfd $(PWD)/program_file

########################################################
# log 

log_clean:
	rm -rfd $(PWD)/log/*
