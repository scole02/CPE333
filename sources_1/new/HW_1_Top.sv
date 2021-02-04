`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/08/2020 10:32:50 AM
// Design Name: 
// Module Name: HW_1_Top
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


module HW_1_Top(
    input [31:0] JALR, BRANCH, JAL,
    input RESET, PC_WRITE, MEM_READ1, CLK,
    input [1:0] PC_SOURCE,
    output [31:0] DOUT
    );
    
    logic [31:0] PC_IN, PC_OUT, PC_4;    
    
    mux4_1 mux4_1(.sel(PC_SOURCE), .zero(PC_4), .one(JALR), .two(BRANCH), .three(JAL), .mux_out(PC_IN));
    PC myPC(.CLK(CLK), .RESET(RESET), .PC_WRITE(PC_WRITE), .PC_IN(PC_IN), .PC_OUT(PC_OUT));
    OTTER_mem_byte otter_memory(.MEM_CLK(CLK), .MEM_ADDR1(PC_OUT), .MEM_READ1(MEM_READ1), .MEM_DOUT1(DOUT));
    

    assign PC_4 = PC_OUT + 4;
endmodule
