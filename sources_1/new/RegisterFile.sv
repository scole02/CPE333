`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/15/2020 12:54:51 PM
// Design Name: 
// Module Name: RegisterFile
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


module RegisterFile #(parameter M = 32, N = 32, P = 5) (
    input [P - 1:0] ADR1, ADR2, WA,
    input CLK, EN,
    input [M - 1:0] WD,
    output logic [M - 1:0] RS1, RS2
);

logic [M - 1:0] mem [0:N - 1];

//initialize all memory to zero 
initial begin
    for (int i = 0; i < M + 1; i++) begin
        mem[i] = 0;
    end
end

//create synchronous write 
always_ff @ (posedge CLK)
begin
    if (EN == 1 && WA!=0)
        mem[WA] <= WD;
end

//asynchronous read 
assign RS1 = mem[ADR1];
assign RS2 = mem[ADR2];
   
endmodule

