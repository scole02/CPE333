`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Eric Crompton
// 
// Create Date: 01/22/2020 11:29:53 AM
// Module Name: CUDecoder
// Project Name: 
// Description:     Control Unit Decoder for OTTER 
// 
//////////////////////////////////////////////////////////////////////////////////


module CUDecoder(
    input BR_EQ,
    input BR_LT,
    input BR_LTU,
    input INT_TAKEN,
    input [2:0] FUNC3,
    input [6:0] FUNC7,
    input [6:0] CU_OPCODE,
    output logic [3:0] ALU_FUN,
    output logic ALU_SCRA,
    output logic [1:0] ALU_SCRB,
    output logic [2:0] PC_SOURCE,
    output logic [1:0] RF_WR_SEL
    );

    typedef enum logic [6:0] //assigns labels to different 7-bit combinations
    {
        LUI     = 7'b0110111,
        AUIPC   = 7'b0010111,
        JAL     = 7'b1101111,
        JALR    = 7'b1100111,
        BRANCH  = 7'b1100011,
        LOAD    = 7'b0000011,
        STORE   = 7'b0100011,
        OP_IMM  = 7'b0010011,
        OP      = 7'b0110011,
        SYSTEM  = 7'b1110011  
    } opcode_t;
    opcode_t OPCODE;
    assign OPCODE = opcode_t'(CU_OPCODE);
    
    always_comb
    begin

    ALU_FUN = 0;
    ALU_SCRA = 0;
    ALU_SCRB = 0;
    PC_SOURCE = 0;
    RF_WR_SEL = 0;
    
    begin
        case(OPCODE)
        LUI     :   begin
                        ALU_FUN = 9;
                        ALU_SCRA = 1;
                        RF_WR_SEL = 3;
                    end
        AUIPC   :   begin
                        ALU_SCRA = 1;
                        ALU_SCRB = 3;
                        RF_WR_SEL = 3;
                    end
        JAL     :   begin
                        PC_SOURCE = 3;
                    end
        JALR    :   begin
                        PC_SOURCE = 1;
                    end
        BRANCH  :   begin
                        if((FUNC3 == 0 && BR_EQ == 1) || (FUNC3 == 1 && BR_EQ == 0)||
                           (FUNC3 == 4 && BR_LT == 1) || (FUNC3 == 5 && BR_LT == 0)||
                           (FUNC3 == 6 && BR_LTU ==1) || (FUNC3 == 7 && BR_LTU == 0))//BEQ
                            PC_SOURCE = 2;
                    end
        LOAD    :   begin
                        ALU_SCRB = 1;
                        RF_WR_SEL = 2;
                    end
        STORE   :   begin
                        ALU_SCRB = 2;
                    end
        OP_IMM  :   begin
                        if(FUNC3 == 5)
                            ALU_FUN = {FUNC7[5], FUNC3};
                        else
                            ALU_FUN = {1'b0, FUNC3};
                        ALU_SCRB = 1;
                        RF_WR_SEL = 3;
                    end
        OP      :   begin
                        ALU_FUN = {FUNC7[5],FUNC3};
                        RF_WR_SEL = 3;
                    end
        SYSTEM  :   begin
                        ALU_FUN = 9;
                        RF_WR_SEL = 1;
                        if(FUNC3 == 0)
                            PC_SOURCE = 5;
                    end
        endcase
    end
        if(INT_TAKEN)
            PC_SOURCE = 4;
    end
endmodule