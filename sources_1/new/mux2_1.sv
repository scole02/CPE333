`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2020 11:49:40 AM
// Design Name: 
// Module Name: mux2_1
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


module mux2_1# (parameter WIDTH = 32)(
    input [WIDTH - 1 : 0] zero, one,
    input sel,
    output logic [WIDTH - 1: 0] mux_out
    );
    
    always_comb
    begin
        case(sel)
            0: mux_out <= zero;
            1: mux_out <= one;
        endcase
    end
endmodule
