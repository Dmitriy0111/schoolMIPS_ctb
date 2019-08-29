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
`define     COP0_OP     6'b010000   // Soprocessor 0 instructions
                                    //

// instruction function field
`define     ADDU_IFF    6'b100001   // Integer Add Unsigned
                                    //      Rd = Rs + Rt
`define     OR_IFF      6'b100101   // Logical OR
                                    //      Rd = Rs | Rt
`define     SRL_IFF     6'b000010   // Shift Right Logical
                                    //      Rd = Rs >> shift
`define     SLL_IFF     6'b000000   // Shift Left Logical
                                    //      Rd = Rs << shift
`define     SLTU_IFF    6'b101011   // Set on Less Than Unsigned
                                    //      Rd = (Rs < Rt) ? 1 : 0
`define     SUBU_IFF    6'b100011   // Unsigned Subtract
                                    //      Rd = Rs - Rt
`define     ERET_IFF    6'b011000   // ERET, Exception Return
                                    //        
`define     MFHI_IFF    6'b010000   // Move From HI Register
                                    //      Rd = HI
`define     MFLO_IFF    6'b010010   // Move From HI Register
                                    //      Rd = LO
`define     ANY_IFF     6'b??????

// coprocessor instructions
`define     COP0_MF     5'b00000    // MFC0, Move from Coprocessor 0
                                    //         Rt = CP0 [Rd, Sel]
`define     COP0_MT     5'b00100    // MTC0, Move to Coprocessor 0
                                    //         CP0 [Rd, Sel] = Rt
`define     ERET        5'b10000    // ERET, Exception Return
                                    //         CP0 [Rd, Sel] = Rt
`define     ANY_HF      5'b?????    

typedef struct {
    string              I_NAME;
    string              INSTR_TYPE;
    logic   [5 : 0]     OPCODE;
    logic   [5 : 0]     INSTR_FUNC;
    logic   [4 : 0]     COP_HF;
} instr_s;

parameter   instr_s     I_ADDU  = '{ "ADDU " , "R"  , `SPEC_OP  , `ADDU_IFF , `ANY_HF  };
parameter   instr_s     I_OR    = '{ "OR   " , "R"  , `SPEC_OP  , `OR_IFF   , `ANY_HF  };
parameter   instr_s     I_SRL   = '{ "SRL  " , "R"  , `SPEC_OP  , `SRL_IFF  , `ANY_HF  };
parameter   instr_s     I_SLL   = '{ "SLL  " , "R"  , `SPEC_OP  , `SLL_IFF  , `ANY_HF  };
parameter   instr_s     I_SLTU  = '{ "SLTU " , "R"  , `SPEC_OP  , `SLTU_IFF , `ANY_HF  };
parameter   instr_s     I_SUBU  = '{ "SUBU " , "R"  , `SPEC_OP  , `SUBU_IFF , `ANY_HF  };
parameter   instr_s     I_MFHI  = '{ "MFHI " , "R"  , `SPEC_OP  , `MFHI_IFF , `ANY_HF  };
parameter   instr_s     I_MFLO  = '{ "MFLO " , "R"  , `SPEC_OP  , `MFLO_IFF , `ANY_HF  };
 
parameter   instr_s     I_ADDIU = '{ "ADDIU" , "I"  , `ADDIU_OP , `ANY_IFF  , `ANY_HF  };
parameter   instr_s     I_BEQ   = '{ "BEQ  " , "I"  , `BEQ_OP   , `ANY_IFF  , `ANY_HF  };
parameter   instr_s     I_LUI   = '{ "LUI  " , "I"  , `LUI_OP   , `ANY_IFF  , `ANY_HF  };
parameter   instr_s     I_BNE   = '{ "BNE  " , "I"  , `BNE_OP   , `ANY_IFF  , `ANY_HF  };
parameter   instr_s     I_LW    = '{ "LW   " , "I"  , `LW_OP    , `ANY_IFF  , `ANY_HF  };
parameter   instr_s     I_SW    = '{ "SW   " , "I"  , `SW_OP    , `ANY_IFF  , `ANY_HF  };

parameter   instr_s     I_MFC0  = '{ "MFC0 " , "C0" , `COP0_OP  , `ANY_IFF  , `COP0_MF };
parameter   instr_s     I_MTC0  = '{ "MTC0 " , "C0" , `COP0_OP  , `ANY_IFF  , `COP0_MT };
parameter   instr_s     I_ERET  = '{ "ERET " , ""   , `COP0_OP  , `ERET_IFF , `ERET    };

`endif // CPU_DEFS__SVH
