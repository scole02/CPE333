`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/27/2020 11:01:48 AM
// Design Name: 
// Module Name: CU_FSM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CU_FSM(
    input CLK,
    input INTR = 0,
    input RST = 0,
    input [6:0] CU_OPCODE,
    input [2:0] FUNC3,
    output logic PC_WRITE, REG_WRITE, MEM_WRITE, MEM_READ1, MEM_READ2, CSR_WRITE, INT_TAKEN

    );
    
    logic [1:0] NS;
    logic [1:0] PS = 0;
    parameter [1:0] FETCH = 2'b00, EXECUTE = 2'b01, WRITE_BACK = 2'b10, INTERRUPT = 2'b11;
    
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
    
    
    always_ff @ (posedge CLK)
    begin
        PS = NS;
        if(RST)
        PS = FETCH;
    end
    
    always_comb
    begin
    
    PC_WRITE = 0;
    REG_WRITE = 0;
    MEM_WRITE = 0;
    MEM_READ1 = 0;
    MEM_READ2 = 0;
    CSR_WRITE = 0;
    INT_TAKEN = 0;
    
        case(PS)
            FETCH:
                begin
                    MEM_READ1 = 1;
                    NS = EXECUTE;
                end
            EXECUTE:
                begin
                   case(OPCODE)
                    OP:
                        begin
                            REG_WRITE = 1;
                            PC_WRITE = 1;
                            NS = FETCH;
                        end
                    OP_IMM:
                        begin
                            REG_WRITE = 1;
                            PC_WRITE = 1;
                            NS = FETCH;
                        end
                    LUI:
                        begin
                            REG_WRITE = 1;
                            PC_WRITE = 1;
                            NS = FETCH;
                        end
                    AUIPC:
                        begin
                            REG_WRITE = 1;
                            PC_WRITE = 1;
                            NS = FETCH;
                        end
                    JAL:
                        begin
                            REG_WRITE = 1;
                            PC_WRITE = 1;
                            NS = FETCH;
                        end
                    JALR:
                        begin
                            REG_WRITE = 1;
                            PC_WRITE = 1;
                            NS = FETCH;
                        end
                    LOAD:
                        begin
                            MEM_READ2 = 1;
                            NS = WRITE_BACK;
                        end
                    STORE:
                        begin
                            PC_WRITE = 1;
                            MEM_WRITE = 1;
                            NS = FETCH;
                        end
                    BRANCH:
                        begin
                            PC_WRITE = 1;
                            NS = FETCH;
                        end
                    SYSTEM:
                        begin
                            if(FUNC3 == 3'b001)
                            begin
                                REG_WRITE = 1;
                                PC_WRITE = 1;
                                CSR_WRITE = 1;
                            end
                            else
                                PC_WRITE = 1;
                            NS = FETCH;
                        end
                    endcase
                    if(INTR)
                        NS = INTERRUPT;
                end
            WRITE_BACK:
            begin
                PC_WRITE = 1;
                REG_WRITE = 1;
                if(INTR)
                    NS = INTERRUPT;
                else
                    NS = FETCH;
            end
            
            INTERRUPT:
            begin
                INT_TAKEN = 1;
                PC_WRITE = 1;
                NS = FETCH;
            end
        endcase
    end
endmodule
