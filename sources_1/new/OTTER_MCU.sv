`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2020 10:30:39 AM
// Design Name: 
// Module Name: OTTER_MCU
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


module OTTER_MCU(
    input CLK, RST, INTR,
    input [31:0] IOBUS_IN,
    output [31:0] IOBUS_OUT,
    output [31:0] IOBUS_ADDR,
    output IOBUS_WR
    );
    
    logic [31:0] PC_IN, PC_OUT, PC_4, IR, ALU_OUT, RS1, ALUB_OUT, ALUA_OUT, REG_MUX_OUT, DOUT2;
    logic [1:0] RF_WR_SEL, ALU_SRCB;
    logic [2:0] PC_SOURCE;
    logic [3:0] ALU_FUN;
    logic ALU_SCRA, PC_WRITE, REG_WRITE, MEM_WRITE, MEM_READ1, MEM_READ2, BR_EQ, BR_LT, BR_LTU, INT_TAKEN, CSR_WRITE, MIE, INTER;
    logic [31:0] JAL, BRANCH, JALR, CSR_OUT, MEPC, MTVEC;
    logic [31:0] UTYPE, ITYPE, STYPE, JTYPE, BTYPE;
   
    //Mux Module
    mux8_1 PC_Mux(.sel(PC_SOURCE), .zero(PC_4), .one(JALR), .two(BRANCH), .three(JAL), .four(MTVEC), .five(MEPC), .mux_out(PC_IN));
    mux4_1 REG_Mux(.sel(RF_WR_SEL), .zero(PC_4), .one(CSR_OUT), .two(DOUT2), .three(ALU_OUT), .mux_out(REG_MUX_OUT));
    mux2_1 ALU_MuxA(.sel(ALU_SCRA), .zero(RS1), .one(UTYPE), .mux_out(ALUA_OUT));
    mux4_1 ALU_MuxB(.sel(ALU_SRCB), .zero(IOBUS_OUT), .one(ITYPE), .two(STYPE), .three(PC_OUT), .mux_out(ALUB_OUT));
    
    //CSR
    CSR OTTER_CSR(.RST(RST), .CLK(CLK), .INT_TAKEN(INT_TAKEN), .ADDR(IR[31:20]), .PC(PC_OUT), .WD(ALU_OUT), .WR_EN(CSR_WRITE), .RD(CSR_OUT),
                  .CSR_MEPC(MEPC), .CSR_MTVEC(MTVEC), .CSR_MIE(MIE));
    
    //Program Counter Module
    PC myPC(.CLK(CLK), .RESET(RST), .PC_WRITE(PC_WRITE), .PC_IN(PC_IN), .PC_OUT(PC_OUT));
    
    //Memory Module
    OTTER_mem_byte otter_memory(.MEM_CLK(CLK), .MEM_ADDR1(PC_OUT), .MEM_ADDR2(ALU_OUT), .MEM_DIN2(IOBUS_OUT), .MEM_READ1(MEM_READ1), .MEM_DOUT1(IR),
                                .IO_IN(IOBUS_IN), .IO_WR(IOBUS_WR), .MEM_SIGN(IR[14]), .MEM_SIZE(IR[13:12]), .MEM_DOUT2(DOUT2),
                                .MEM_WRITE2(MEM_WRITE), .MEM_READ2(MEM_READ2));
    //ALU Module                            
    ALU ALU_OTTER(.A(ALUA_OUT), .B(ALUB_OUT), .ALU_OUT(ALU_OUT), .ALU_FUN(ALU_FUN));
    
    //Register Module
    RegisterFile RF_OTTER(.CLK(CLK), .ADR1(IR[19:15]), .ADR2(IR[24:20]), .WA(IR[11:7]), .EN(REG_WRITE), .WD(REG_MUX_OUT), .RS1(RS1), .RS2(IOBUS_OUT));
    
    //Decoder Module
    CUDecoder CUD_OTTER(.BR_EQ(BR_EQ), .BR_LT(BR_LT), .BR_LTU(BR_LTU), .FUNC3(IR[14:12]), .FUNC7(IR[31:25]), .CU_OPCODE(IR[6:0]), .ALU_FUN(ALU_FUN),
                        .ALU_SCRA(ALU_SCRA), .ALU_SCRB(ALU_SRCB), .PC_SOURCE(PC_SOURCE), .RF_WR_SEL(RF_WR_SEL), .INT_TAKEN(INT_TAKEN));
    //Finite State Machine
    CU_FSM CU_OTTER_FSM(.CLK(CLK), .RST(RST), .INTR(INTER), .CU_OPCODE(IR[6:0]), .PC_WRITE(PC_WRITE), .REG_WRITE(REG_WRITE), .MEM_WRITE(MEM_WRITE),
                        .MEM_READ1(MEM_READ1), .MEM_READ2(MEM_READ2), .INT_TAKEN(INT_TAKEN), .CSR_WRITE(CSR_WRITE), .FUNC3(IR[14:12]));
    assign PC_4 = PC_OUT + 4;
    assign IOBUS_ADDR = ALU_OUT;
    assign INTER = INTR & MIE;
    
    //Immediate Generator
    assign ITYPE = {{21{IR[31]}}, IR[30:20]};
    assign STYPE = {{21{IR[31]}}, IR[30:25],IR[11:7]};
    assign UTYPE = {{IR[31:12], 12'b0}};
    assign BTYPE = {{20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
    assign JTYPE = {{12{IR[31]}}, IR[19:12], IR[20], IR[30:21], 1'b0};
    
    //Conditional Generator
    assign BR_EQ = RS1 == IOBUS_OUT ? 1:0;
    assign BR_LT = $signed(RS1) < $signed(IOBUS_OUT) ? 1 : 0;
    assign BR_LTU = RS1 < IOBUS_OUT ? 1 : 0;
    
    //Target Generator
    assign BRANCH = PC_OUT + BTYPE;
    assign JAL = PC_OUT + JTYPE;
    assign JALR = RS1 + ITYPE;
    
endmodule
