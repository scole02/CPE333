`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Eric Crompton
// 
// Module Name: Mux4_1
// Description: 32-bit 4 to 1 mulitplexor
// 
//////////////////////////////////////////////////////////////////////////////////


module mux4_1 # (parameter WIDTH = 32)(
    input [WIDTH - 1:0] zero, one, two, three,
    input logic [1:0] sel,
    output logic [WIDTH - 1:0] mux_out
    );
        
    always_comb
    begin
        case(sel)
            2'b00: mux_out <= zero;
            2'b01: mux_out <= one;
            2'b10: mux_out <= two;
            2'b11: mux_out <= three;

        endcase
    end
endmodule
