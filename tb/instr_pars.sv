/*
*  File            :   instr_pars.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.08.28
*  Language        :   SystemVerilog
*  Description     :   This is class for parsing instruction from instruction memory
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "cpu_defs.svh"

class instr_pars#(parameter print_info_en = '1, term_print = '1, txt_log_print = '1, html_log_print = '1);

    logic   [31 : 0]    instr   [5];

    logic   [31 : 0]    pc;
    int                 cycle_counter;
    logic   [31 : 0]    cpu_rf      [31 : 0];

    string              log_str;
    string              reg_str;
    string              instruction [5];

    integer             txt_p;

    // for working html file
    logic   [31 : 0]    reg_file_l  [31 : 0];   // local register file
    logic   [1  : 0]    table_c     [31 : 0];   // change table
    string              html_str = "";          // html string
    integer             html_p;                 // pointer to html log file

    // register file list names 
    string registers_list [0:31] =  {
                                        "zero ",
                                        "at   ",
                                        "v0   ",
                                        "v1   ",
                                        "a0   ",
                                        "a1   ",
                                        "a2   ",
                                        "a3   ",
                                        "t0   ",
                                        "t1   ",
                                        "t2   ",
                                        "t3   ",
                                        "t4   ",
                                        "t5   ",
                                        "t6   ",
                                        "t7   ",
                                        "s0   ",
                                        "s1   ",
                                        "s2   ",
                                        "s3   ",
                                        "s4   ",
                                        "s5   ",
                                        "s6   ",
                                        "s7   ",
                                        "t8   ",
                                        "t9   ",
                                        "k0   ",
                                        "k1   ",
                                        "gp   ",
                                        "sp   ",
                                        "fp/s8",
                                        "ra   "
                                    };
    // instruction list
    instr_s instr_list[] = 
                            {
                                I_ADDU,
                                I_OR,
                                I_SRL,
                                I_SLL,
                                I_SLTU,
                                I_SUBU,
                                I_ADDIU,
                                I_BEQ,
                                I_LUI,
                                I_BNE,
                                I_LW,
                                I_SW,
                                I_MFC0,
                                I_MTC0,
                                I_ERET,
                                I_MFHI,
                                I_MFLO
                            };

    // class constructor
    function new(string log_file_name);
        for(int i = 0; i < 32; i++)
        begin
            reg_file_l[i]   = '0;
            table_c[i]  = '0;
        end
        html_p = $fopen( { log_file_name , ".html" } , "w" );
        txt_p  = $fopen( { log_file_name , ".log"  } , "w" );
        if( !html_p )
        begin
            $display("Error! File %s not open.", { log_file_name , ".html"} );
            $stop;
        end
        if( !txt_p )
        begin
            $display("Error! File %s not open.", { log_file_name , ".log"} );
            $stop;
        end
    endfunction : new

    // function for finding instruction operands
    function string find_operands(instr_s instr_s_, int index);
        string ret_str;
        if( instr_s_.INSTR_TYPE == "I" )
        begin
            ret_str = { registers_list[instr[index][20 : 16]] , $psprintf("(0x%h)", instr[index][20 : 16] ) };
            ret_str = { ret_str , " " , registers_list[instr[index][25 : 21]] , $psprintf("(0x%h)", instr[index][25 : 21] ) };
            ret_str = { ret_str , " " , $psprintf("0x%h", instr[index][0 +: 16]) };
        end
        if( instr_s_.INSTR_TYPE == "R" )
        begin
            ret_str = { registers_list[instr[index][15 : 11]] , $psprintf("(0x%h)", instr[index][15 : 11] ) };
            ret_str = { ret_str , " " , registers_list[instr[index][25 : 21]] , $psprintf("(0x%h)", instr[index][25 : 21] ) };
            ret_str = { ret_str , " " , registers_list[instr[index][20 : 16]] , $psprintf("(0x%h)", instr[index][20 : 16] ) };
        end
        if( instr_s_.INSTR_TYPE == "C0" )
        begin
            ret_str = { registers_list[instr[index][20 : 16]] , $psprintf("(0x%h)", instr[index][20 : 16] ) };
            ret_str = { ret_str , " " , registers_list[instr[index][15 : 11]] , $psprintf("(0x%h)", instr[index][15 : 11] ) };
        end
        return ret_str;
    endfunction : find_operands

    // task for loading values from schoolMIPS in class
    task load_values(
                        logic [31 : 0] instr_F, 
                        logic [31 : 0] instr_D, 
                        logic [31 : 0] instr_E, 
                        logic [31 : 0] instr_M, 
                        logic [31 : 0] instr_W, 
                        logic [31 : 0] reg_file[31 : 0], 
                        logic [31 : 0] pc, 
                        int cycle_counter
                    );
        this.instr[0] = instr_F;
        this.instr[1] = instr_D;
        this.instr[2] = instr_E;
        this.instr[3] = instr_M;
        this.instr[4] = instr_W;
        this.pc = pc;
        this.cycle_counter = cycle_counter;
        this.cpu_rf = reg_file;
    endtask : load_values

    // function for finding instruction fields
    function string pars_instr(int index = 0);
        string ret_str;
        ret_str = "";
        if( $isunknown(| instr[index]) )
        begin
            ret_str =  $psprintf("0x%h : unknown instruction\n", instr[index] );
            return ret_str;
        end
        foreach( instr_list[i] )
        begin 
            casex( { instr[index][31-:6] , instr[index][0+:6] , instr[index][21 +: 5] } )
                { instr_list[i].OPCODE , instr_list[i].INSTR_FUNC , instr_list[i].COP_HF } : 
                    begin
                        ret_str =  $psprintf("0x%h : %s %s\n", instr[index], instr_list[i].I_NAME, find_operands(instr_list[i],index) );
                        return ret_str;
                    end
            endcase
        end
        ret_str =  $psprintf("0x%h : unknown instruction\n", instr[index] );
        return ret_str;
    endfunction : pars_instr

    // task for printing info in terminal/log file/htlm log file
    task print_info();
        if( print_info_en )
        begin
            log_str = "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n";
            log_str = { log_str, $psprintf("pc = 0x%h, cycle = %0d, time = %0tns \n", pc, cycle_counter, $time) };
            log_str = { log_str, "Fetch stage      : "};
            instruction[0] = pars_instr(0);
            log_str = { log_str, instruction[0] };
            log_str = { log_str, "Decode stage     : "};
            instruction[1] = pars_instr(1);
            log_str = { log_str, instruction[1] };
            log_str = { log_str, "Execute stage    : "};
            instruction[2] = pars_instr(2);
            log_str = { log_str, instruction[2] };
            log_str = { log_str, "Memory stage     : "};
            instruction[3] = pars_instr(3);
            log_str = { log_str, instruction[3] };
            log_str = { log_str, "Write back stage : "};
            instruction[4] = pars_instr(4);
            log_str = { log_str, instruction[4] };
            form_reg_table();
            if( html_log_print )
                form_info_html();
            log_str = { log_str, "\n" ,reg_str };
            if( term_print )
                $display(log_str);
            if( txt_log_print )
                write_txt_info();
            if( html_log_print )
                write_html_info();
        end
    endtask : print_info

    // task for writing info in html file
    task write_html_info();
        $fwrite(html_p,html_str);
    endtask : write_html_info

    // task for writing info in log file
    task write_txt_info();
        $fwrite(txt_p,log_str);
    endtask : write_txt_info

    // task for writing register file values in txt file ( table )
    task form_reg_table();

        integer reg_addr;
        string  reg_value;
        cpu_rf[0] = '0;
        reg_addr = '0;
        reg_str = "register list :\n";

        do
        begin
            reg_value = $psprintf("%h",cpu_rf[reg_addr]);
            reg_str =  {
                            reg_str, 
                            $psprintf("%5s", registers_list[reg_addr] ), 
                            $psprintf(" = 0x%s | ", reg_value.toupper() ), 
                            reg_addr[0 +: 2] == 3 ? "\n" : "" 
                        };
            reg_addr++;
        end
        while( reg_addr != 32 );

    endtask : form_reg_table

    // task for formirate current instruction info in html
    task form_info_html();

        html_str = "";
        html_str = { html_str , "<font size = \"4\">" };
        html_str = { html_str , "<pre>" };
        html_str = { html_str , log_str };
        html_str = { html_str , "\nregister list :" };
        html_str = { html_str , "</pre>" };
        html_str = { html_str , "</font>\n" };
        this.form_html_table();

    endtask : form_info_html

    // task for formirate register file values in html table
    task form_html_table();

        integer tr_i;
        integer td_i;
        string  reg_value;
        reg_value = "";
        tr_i = 0;
        td_i = 0;

        for( int i = 0 ; i < 32 ; i++ )
        begin
            table_c[i] = reg_file_l[i] == cpu_rf[i] ? 2'b00 : 2'b01;
            if( $isunknown( | table_c[i] ) )
            begin
                if( $isunknown( | cpu_rf[i] ) )
                    table_c[i] = 2'b10;
                else
                    table_c[i] = 2'b01;
                reg_file_l[i] = cpu_rf[i];
            end
            else
                reg_file_l[i] = table_c[i] == 2'b00 ? 
                                reg_file_l[i] : 
                                cpu_rf[i];
        end

        html_str = { html_str , "<table border=\"1\">\n" };

        do
        begin
            html_str = { html_str , "    <tr>\n" };
            do
            begin
                html_str = { html_str , $psprintf("        <td %s>",    table_c[ tr_i * 4 + td_i ] == 2'b00 ? "bgcolor = \"white\"" : ( 
                                                                        table_c[ tr_i * 4 + td_i ] == 2'b01 ? "bgcolor = \"green\"" : 
                                                                                                               "bgcolor = \"red\"" ) ) };
                html_str = { html_str , "<pre>" };
                reg_value = $psprintf("%h",reg_file_l[ tr_i * 4 + td_i ]);
                html_str = { html_str , $psprintf(" %5s 0x%H ", registers_list[ tr_i * 4 + td_i ], reg_value.toupper()) };
                html_str = { html_str , "</pre>" };
                html_str = { html_str , "</td>\n" };
                td_i++;
            end
            while( td_i != 4 );
            html_str = { html_str , "    </tr>\n" };
            tr_i++;
            td_i = 0;
        end
        while( tr_i != 8 );

        html_str = { html_str , "</table>\n" };

    endtask : form_html_table

endclass : instr_pars
