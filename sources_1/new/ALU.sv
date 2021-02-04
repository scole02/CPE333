`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////// 
// Engineer: 
// Module Name: ALU
// Project Name: 
// Description: 
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU #(parameter M = 32)(
    input [M - 1:0] A, B,
    input [3:0] ALU_FUN,
    output logic [M - 1:0] ALU_OUT
    );
    
    always_comb
    begin
        case(ALU_FUN)
        4'b0000: ALU_OUT = A + B;//ADD
        4'b0001: ALU_OUT = A << B[4:0];//SLL
        4'b0010: ALU_OUT = $signed(A) < $signed(B) ? 1 : 0;//SLT
        4'b0011: ALU_OUT = (A < B) ? 1 : 0;//SLTU
        4'b0100: ALU_OUT = A ^ B;//XOR
        4'b0101: ALU_OUT = A >> B[4:0];//SRL
        4'b0110: ALU_OUT = A | B;//OR
        4'b0111: ALU_OUT = A & B;//AND
        4'b1000: ALU_OUT = A - B;//SUB
        4'b1001: ALU_OUT = A;//LUI
        4'b1101: ALU_OUT = $signed(A) >>> B[4:0]; //SRA
        default: ALU_OUT = A + B;
        endcase
    end
endmodule
