
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

PROG_LIST ?= 00_counter 01_fibonacci 02_sqrt 03_ram 04_irq_timer 05_exc_ri 06_hz_forward 07_hz_stall 08_hz_branch 09_ahb_mem 10_ahb_gpio

PROG_NAME ?= 00_counter

show_progs:
	echo $(PROG_LIST)

prog_comp:
	mkdir -p program_file
	mips-mti-elf-gcc -nostdlib -EL -march=mips32 -T schoolMIPS/program/$(PROG_NAME)/program.ld schoolMIPS/program/$(PROG_NAME)/main.S -o program_file/program.elf
	mips-mti-elf-objdump -M no-aliases -Dz program_file/program.elf > program_file/program.dis
	echo @00000000 > program_file/program.hex
	mips-mti-elf-objdump -Dz program_file/program.elf | sed -rn 's/\s+[a-f0-9]+:\s+([a-f0-9]*)\s+.*/\1/p' >> program_file/program.hex

prog_copy_hex:
	mkdir -p program_file
	cp schoolMIPS/program/$(PROG_NAME)/program.hex program_file/program.hex

prog_clean:
	rm -rfd $(PWD)/program_file

########################################################
# log 

log_clean:
	rm -rfd $(PWD)/log/*
