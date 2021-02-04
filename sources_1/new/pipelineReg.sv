`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/31/2021 05:14:22 PM
// Design Name: 
// Module Name: pipelineReg
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


module pipelineReg # (parameter N = 1) (
     input clk,
    input rest,
    input logic [N-1:0] in,
    output logic [N-1:0] out 
    );
    
    
    
    always_ff @(posedge clk)
        if(rest) out = 0;
        else out =  in;
         
   
endmodule
