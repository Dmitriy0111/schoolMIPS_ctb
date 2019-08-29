/*
*  File            :   cpu_defs.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.08.28
*  Language        :   SystemVerilog
*  Description     :   This is cpu defines
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef CPU_DEFS__SVH
`define CPU_DEFS__SVH

// instruction operation code
`define     SPEC_OP     6'b000000   // Special instructions (depends on instruction function field)
                                    //
`define     ADDIU_OP    6'b001001   // Integer Add Immediate Unsigned
                                    //      Rd = Rs + Immed
`define     BEQ_OP      6'b000100   // Branch On Equal
                                    //      if (Rs == Rt) PC += (int)offset
`define     LUI_OP      6'b001111   // Load Upper Immediate
                                    //      Rt = Immed << 16
`define     BNE_OP      6'b000101   // Branch on Not Equal
                                    //      if (Rs != Rt) PC += (int)offset
`define     LW_OP       6'b100011   // Load Word
                                    //      Rt = memory[Rs + Immed]
`define     SW_OP       6'b101011   // Store Word
                                    //      memory[Rs + Immed] = Rt

// instruction function field
`define     ADDU_IFF    6'b100001   // Integer Add Unsigned
                                    //      Rd = Rs + Rt
`define     OR_IFF      6'b100101   // Logical OR
                                    //      Rd = Rs | Rt
`define     SRL_IFF     6'b000010   // Shift Right Logical
                                    //      Rd = Rs >> shift
`define     SLTU_IFF    6'b101011   // Set on Less Than Unsigned
                                    //      Rd = (Rs < Rt) ? 1 : 0
`define     SUBU_IFF    6'b100011   // Unsigned Subtract
                                    //      Rd = Rs - Rt
`define     ANY_IFF     6'b??????

typedef struct {
    string              I_NAME;
    string              INSTR_TYPE;
    logic   [5 : 0]     OPCODE;
    logic   [5 : 0]     INSTR_FUNC;
} instr_s;

parameter   instr_s     I_ADDU  = '{ "ADDU " , "R" , `SPEC_OP  , `ADDU_IFF };
parameter   instr_s     I_OR    = '{ "OR   " , "R" , `SPEC_OP  , `OR_IFF   };
parameter   instr_s     I_SRL   = '{ "SRL  " , "R" , `SPEC_OP  , `SRL_IFF  };
parameter   instr_s     I_SLTU  = '{ "SLTU " , "R" , `SPEC_OP  , `SLTU_IFF };
parameter   instr_s     I_SUBU  = '{ "SUBU " , "R" , `SPEC_OP  , `SUBU_IFF };

parameter   instr_s     I_ADDIU = '{ "ADDIU" , "I" , `ADDIU_OP , `ANY_IFF };
parameter   instr_s     I_BEQ   = '{ "BEQ  " , "I" , `BEQ_OP   , `ANY_IFF };
parameter   instr_s     I_LUI   = '{ "LUI  " , "I" , `LUI_OP   , `ANY_IFF };
parameter   instr_s     I_BNE   = '{ "BNE  " , "I" , `BNE_OP   , `ANY_IFF };
parameter   instr_s     I_LW    = '{ "LW   " , "I" , `LW_OP    , `ANY_IFF  };
parameter   instr_s     I_SW    = '{ "SW   " , "I" , `SW_OP    , `ANY_IFF  };

`endif // CPU_DEFS__SVH
