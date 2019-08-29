/*
*  File            :   tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.08.28
*  Language        :   SystemVerilog
*  Description     :   This is other testbench for schoolMIPS
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "instr_pars.sv"
`include "../schoolMIPS/src/sm_settings.vh"

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
        
    `ifdef SM_CONFIG_AHB_GPIO
    logic   [`SM_GPIO_WIDTH-1 : 0]  port_gpioIn;
    logic   [`SM_GPIO_WIDTH-1 : 0]  port_gpioOut;
    `endif
        
    
    // help variables
    int                 cycle_counter;      // cycle counter
    string              instruction_F;      // instruction string
    string              instruction_D;      // instruction string
    string              instruction_E;      // instruction string
    string              instruction_M;      // instruction string
    string              instruction_W;      // instruction string

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
        .clkIn          ( clk           ),
        .rst_n          ( rst_n         ),
        .clkDevide      ( 4'b0          ),
        .clkEnable      ( 1'b1          ),
        .clk            ( cpuClk        ),
        .regAddr        ( regAddr       ),
        .regData        ( regData       )
        `ifdef SM_CONFIG_AHB_GPIO
        ,
        .port_gpioIn    ( port_gpioIn   ),
        .port_gpioOut   ( port_gpioOut  )
        `endif
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
        `ifdef SM_CONFIG_AHB_GPIO
        port_gpioIn = $urandom_range(0,2**`SM_GPIO_WIDTH-1);
        $display("Gpio input = 0x%h",port_gpioIn);
        `endif
        instr_pars_0 = new("../log/log");
        cycle_counter = '0;
        regAddr = '0;
        @(posedge rst_n);
        forever
        begin
            @(posedge cpuClk);
            instr_pars_0.load_values(
                                        sm_top_0.sm_cpu.instr_F,
                                        sm_top_0.sm_cpu.instr_D,
                                        sm_top_0.sm_cpu.instr_E, 
                                        sm_top_0.sm_cpu.instr_M, 
                                        sm_top_0.sm_cpu.instr_W, 
                                        sm_top_0.sm_cpu.rf.rf, 
                                        sm_top_0.sm_cpu.imAddr, 
                                        cycle_counter
                                    );
            instr_pars_0.print_info();
            instruction_F = instr_pars_0.instruction[0];
            instruction_D = instr_pars_0.instruction[1];
            instruction_E = instr_pars_0.instruction[2];
            instruction_M = instr_pars_0.instruction[3];
            instruction_W = instr_pars_0.instruction[4];
            cycle_counter++;
            if( cycle_counter == repeat_cycles )
                $stop;
        end
    end

endmodule : tb
