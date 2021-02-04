`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2020 11:37:15 AM
// Design Name: 
// Module Name: mux8_1
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


module mux8_1 # (parameter WIDTH = 32)(
    input [WIDTH - 1:0] zero, one, two, three, four, five,
    input logic [2:0] sel,
    output logic [WIDTH - 1:0] mux_out
    );
        
    always_comb
    begin
        case(sel)
            3'b000: mux_out <= zero;
            3'b001: mux_out <= one;
            3'b010: mux_out <= two;
            3'b011: mux_out <= three;
            3'b100: mux_out <= four;
            3'b101: mux_out <= five;
        endcase

    end
endmodule
