/*
*  File            :   tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.08.28
*  Language        :   SystemVerilog
*  Description     :   This is other testbench for schoolMIPS
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "instr_pars.sv"

module tb();

    // simulation settings
    timeprecision       1ns;
    timeunit            1ns;
    // simulation constants
    parameter           T = 20,                 // 50 MHz (clock period)
                        rst_n_delay = 7,        // delay for reset signal (posedge clk)
                        repeat_cycles = 200;    // number of repeat cycles before stop

    logic   [0  : 0]    clk;
    logic   [0  : 0]    rst_n;
    logic   [0  : 0]    cpuClk;
    logic   [4  : 0]    regAddr;
    logic   [31 : 0]    regData;
    
    // help variables
    int                 cycle_counter;      // cycle counter
    string              instruction;        // instruction string

    instr_pars
    #(
        .print_info_en  ( '1        ), 
        .term_print     ( '1        ), 
        .txt_log_print  ( '1        ), 
        .html_log_print ( '1        )
    )
    instr_pars_0;

    sm_top 
    sm_top_0
    (
        .clkIn          ( clk       ),
        .rst_n          ( rst_n     ),
        .clkDevide      ( 4'b0      ),
        .clkEnable      ( 1'b1      ),
        .clk            ( cpuClk    ),
        .regAddr        ( regAddr   ),
        .regData        ( regData   )
    );

    defparam sm_top_0.sm_clk_divider.bypass = 1;

    // clock generation
    initial begin
        clk = '0;
        forever 
            #(T/2) clk = !clk;
    end
    // reset generation
    initial begin
        rst_n = '0;
        repeat (rst_n_delay) @(posedge clk);
        rst_n = '1;
    end
    // simulation process
    initial
    begin
        $readmemh("../program_file/program.hex", sm_top_0.reset_rom.rom );
        instr_pars_0 = new("../log/log");
        cycle_counter = '0;
        regAddr = '0;
        @(posedge rst_n);
        forever
        begin
            @(posedge cpuClk);
            instr_pars_0.load_values(sm_top_0.sm_cpu.instr, sm_top_0.sm_cpu.rf.rf, sm_top_0.sm_cpu.pc, cycle_counter);
            instr_pars_0.print_info();
            instruction = instr_pars_0.instruction;
            cycle_counter++;
            if( cycle_counter == repeat_cycles )
                $stop;
        end
    end

endmodule : tb
