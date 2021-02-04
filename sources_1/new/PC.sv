`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Eric Crompton
// 
// Module Name: PC
// Description: 
// 
//////////////////////////////////////////////////////////////////////////////////


module PC(
    input CLK, RESET, PC_WRITE,
    input [31:0] PC_IN,
    output logic [31:0] PC_OUT = 0
    );
    
    always_ff @ (posedge CLK)
    begin
        if (RESET)
            PC_OUT = 0;
        else if(PC_WRITE)
            PC_OUT = PC_IN;
    end
endmodule
