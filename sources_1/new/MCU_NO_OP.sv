`timescale 1ns / 1ps 

////////////////////////////////////////////////////////////////////////////////// 

// Company:  

// Engineer:   

//  

// Create Date: 01/04/2019 04:32:12 PM 

// Design Name:  

// Module Name: OTTER_MCU_V2 

// Project Name: Single_Cycle_Otter 

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

  

typedef enum logic [6:0] { 

    LUI      = 7'b0110111, 

    AUIPC    = 7'b0010111, 

    JAL      = 7'b1101111, 

    JALR     = 7'b1100111, 

    BRANCH   = 7'b1100011, 

    LOAD     = 7'b0000011, 

    STORE    = 7'b0100011, 

    OP_IMM   = 7'b0010011, 

    OP       = 7'b0110011, 

    SYSTEM   = 7'b1110011 

} opcode_t; 

         

typedef struct packed{ 

    opcode_t opcode; 

    logic [4:0] rs1_addr; 

    logic [4:0] rs2_addr; 

    logic [4:0] rd_addr; 

    logic rs1_used; 

    logic rs2_used; 

    logic [2:0] pipeline_func3; 

    logic rd_used; 

    logic [3:0] ALU_fun; 

    logic memWrite; 

    logic memRead2; 

    logic regWrite; 

    logic [1:0] rf_wr_sel; 

    logic [2:0] mem_type;  //sign, size 

    logic [31:0] pc; 

    logic [31:0] ir; 

    logic [31:0] rs1; 

    logic [31:0] rs2; 

    logic [31:0] opA; 

    logic [31:0] opB; 

    logic [31:0] ALU_result; 

    logic [31:0] Btype; 

    logic [31:0] Jtype; 

    logic [31:0] Itype; 

} instr_t; 

  

module OTTER_MCU_NO_OP( 

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

    logic [31:0] UTYPE, STYPE; 

    

    //==== Instruction Fetch =========================================== 

    logic [31:0] if_de_pc; 

     

    //Program Counter Module 

    //Ask about the PC_Mux and connecting .one, .two, .three 

    PC myPC(.CLK(CLK), .RESET(RST), .PC_WRITE(PC_WRITE), .PC_IN(PC_IN), .PC_OUT(PC_OUT)); 

    mux8_1 PC_Mux(.sel(PC_SOURCE), .zero(PC_4), .one(JALR), .two(BRANCH), .three(JAL), .four(MTVEC), .five(MEPC), .mux_out(PC_IN)); 

     

    always_ff @(posedge CLK) begin 

               if_de_pc <= PC_OUT; 

    end 

     

    assign PC_WRITE = 1'b1;     //Hardwired high, assuming no hazards 

    assign MEM_READ1 = 1'b1;     //Fetch new instruction every cycle 

     

     

    assign PC_4 = PC_OUT + 4; 

     

    //=== End Instruction Fetch ======================================== 

     

    //==== Instruction Decode ========================================== 

     

  

    // Registers used for pipeline 

    // r_de_inst: Register for Fetch-Decode pipeline 

    // r_de_ex_instr: Register for Decode-Execute Pipeline 

    instr_t r_de_ex_inst, r_de_inst; 

     

    //Decoder Module 

    CUDecoder CUD_OTTER(.FUNC3(IR[14:12]), .FUNC7(IR[31:25]), .CU_OPCODE(IR[6:0]), .ALU_FUN(r_de_inst.ALU_fun), 

                        .ALU_SCRA(ALU_SCRA), .ALU_SCRB(ALU_SRCB), .RF_WR_SEL(r_de_inst.rf_wr_sel), 

                        .MEM_WRITE(r_de_inst.memWrite), .MEM_READ2(r_de_inst.memRead2), .REG_WRITE(r_de_inst.regWrite)); 

     

    //Register Module 

    RegisterFile RF_OTTER(.CLK(CLK), .ADR1(IR[19:15]), .ADR2(IR[24:20]), 

                          .WA(r_mem_wb_inst.ir[11:7]), .EN(r_mem_wb_inst.regWrite), .WD(REG_MUX_OUT), .RS1(r_de_inst.rs1), .RS2(r_de_inst.rs2)); 

     

    //Immediate Generator 

    assign r_de_inst.Itype = {{21{IR[31]}}, IR[30:20]}; 

    assign STYPE = {{21{IR[31]}}, IR[30:25],IR[11:7]}; 

    assign UTYPE = {{IR[31:12], 12'b0}}; 

    assign r_de_inst.Btype = {{20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0}; 

    assign r_de_inst.Jtype = {{12{IR[31]}}, IR[19:12], IR[20], IR[30:21], 1'b0}; 

     

    //ALU Muxes 

    mux2_1 ALU_MuxA(.sel(ALU_SCRA), .zero(r_de_inst.rs1), .one(UTYPE), .mux_out(r_de_inst.opA)); 

    mux4_1 ALU_MuxB(.sel(ALU_SRCB), .zero(r_de_inst.rs2), .one(r_de_inst.Itype), .two(STYPE), .three(if_de_pc), .mux_out(r_de_inst.opB)); 

     

    // Creates a RISC-V ALU 

     ALU ALU_OTTER(.A(r_de_inst.opA), .B(r_de_inst.opB), .ALU_OUT(r_de_inst.ALU_result), .ALU_FUN(r_de_inst.ALU_fun)); 

      

    opcode_t OPCODE; 

    assign OPCODE = opcode_t'(IR[6:0]); 

     

    assign r_de_inst.pc = if_de_pc; 

     

    assign r_de_inst.mem_type = IR[14:12]; 

    assign r_de_inst.pipeline_func3 = IR[14:12]; 

    assign r_de_inst.rs1_addr = IR[19:15]; 

    assign r_de_inst.rs2_addr = IR[24:20]; 

    assign r_de_inst.rd_addr = IR[11:7]; 

    assign r_de_inst.opcode = OPCODE; 

    assign r_de_inst.ir = IR; 

    assign r_de_inst.rf_wr_sel = RF_WR_SEL; 

    assign r_de_inst.ALU_fun = ALU_FUN; 

     

    assign r_de_inst.rs1_used =    r_de_inst.rs1_addr != 0 

                                && r_de_inst.opcode != LUI 

                                && r_de_inst.opcode != AUIPC 

                                && r_de_inst.opcode != JAL; 

     

     always_ff @(posedge CLK)  

     begin 

        r_de_ex_inst <= r_de_inst; 

    end 

     

    //==== End Instruction Decode ====================================== 

     

    //==== Execute ====================================================== 

     instr_t r_ex_mem_inst; 

     //logic [31:0] opA_forwarded; 

      

    // Branch Conditional Generator 

    // Ask about hardwiring PC_SOURCE back to FETCH stage 

    assign BR_EQ = r_de_ex_inst.rs1 ==  r_de_ex_inst.rs2 ? 1 : 0; 

    assign BR_LT = $signed(r_de_ex_inst.rs1) < $signed(r_de_ex_inst.rs2) ? 1 : 0; 

    assign BR_LTU = r_de_ex_inst.rs1 < r_de_ex_inst.rs2 ? 1 : 0; 

    always_comb 

    begin 

        PC_SOURCE = 0; 

         case(r_de_ex_inst.opcode) 

         JALR:  begin    

                PC_SOURCE = 1; 

                end 

         JAL:   begin 

                PC_SOURCE = 3; 

                end 

         BRANCH :   begin 

                     if((r_de_ex_inst.pipeline_func3 == 0 && BR_EQ == 1) || (r_de_ex_inst.pipeline_func3 == 1 && BR_EQ == 0)|| 

                        (r_de_ex_inst.pipeline_func3 == 4 && BR_LT == 1) || (r_de_ex_inst.pipeline_func3 == 5 && BR_LT == 0)|| 

                        (r_de_ex_inst.pipeline_func3 == 6 && BR_LTU ==1) || (r_de_ex_inst.pipeline_func3 == 7 && BR_LTU == 0))//BEQ 

                         PC_SOURCE = 2; 

                 end         

         endcase 

    end 

  

     

    //Target Generator 

    // Examine BRANCH wire and possible conflict with BRANCH OPCODE statement 

    assign BRANCH = PC_OUT + r_de_ex_inst.Btype; 

    assign JAL = PC_OUT + r_de_ex_inst.Jtype; 

    assign JALR = RS1 + r_de_ex_inst.Itype; 

      

      

     logic [31:0] opB_forwarded; 

      

      

      

     always_ff @(posedge CLK) 

     begin 

        r_ex_mem_inst <= r_de_ex_inst; 

     end 

     

    //==== End Execute ====================================== 

     

    //==== Memory ====================================================== 

     instr_t r_mem_wb_inst; 

      

    assign IOBUS_ADDR = r_ex_mem_inst.ALU_result; 

    assign IOBUS_OUT = r_ex_mem_inst.rs2; 

     

     

     

    always_ff @(posedge CLK) 

     begin 

        r_mem_wb_inst <= r_ex_mem_inst; 

     end 

    //==== End Memory ================================================== 

     

    //==== Write Back ================================================== 

     

    logic [31:0] wb_pc_4; 

    assign wb_pc_4 = r_mem_wb_inst.pc + 4; 

    //Why does the mem_wb register update at same time as ex_mem register 

    mux4_1 REG_Mux(.sel(r_mem_wb_inst.rf_wr_sel), .zero(wb_pc_4), .one(CSR_OUT), .two(DOUT2), 

                   .three(r_mem_wb_inst.ALU_result), .mux_out(REG_MUX_OUT)); 

    //==== End Write Back ============================================== 

     

  

    //Memory Module 

    OTTER_mem_byte otter_memory(.MEM_CLK(CLK), .MEM_ADDR1(PC_OUT), .MEM_ADDR2(r_ex_mem_inst.ALU_result), 

                                .MEM_DIN2(IOBUS_OUT), .MEM_READ1(MEM_READ1), .MEM_DOUT1(IR), .IO_IN(IOBUS_IN), 

                                .IO_WR(IOBUS_WR), .MEM_SIGN(r_mem_wb_inst.mem_type[2]), .MEM_SIZE(r_ex_mem_inst.mem_type), .MEM_DOUT2(DOUT2), 

                                .MEM_WRITE2(r_ex_mem_inst.memWrite), .MEM_READ2(r_ex_mem_inst.memRead2)); 

                                 

    assign INTER = INTR & MIE; 

  

endmodule