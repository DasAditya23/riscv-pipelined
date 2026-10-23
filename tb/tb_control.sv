`timescale 1ns/1ps

module tb_control;
    logic [31:0] instr;
    logic [31:0] imm;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    
    logic reg_write, mem_read, mem_write, mem_to_reg, alu_src, branch;
    logic [3:0] alu_ctrl;

    immgen my_imm (.instr(instr), .imm_out(imm));
    control my_ctrl (
        .opcode(instr[6:0]), .funct3(instr[14:12]), .funct7(instr[31:25]),
        .reg_write(reg_write), .mem_read(mem_read), .mem_write(mem_write),
        .mem_to_reg(mem_to_reg), .alu_src(alu_src), .branch(branch), .alu_ctrl(alu_ctrl)
    );

    initial begin
        $display("TESTBENCH STARTED");
        
        // Instruction: addi x1, x0, 5
        // Encoding: imm[11:0]=5, rs1=0, funct3=000, rd=1, opcode=0010011
        instr = 32'b000000000101_00000_000_00001_0010011;
        
        #1;
        $display("Opcode: %b", instr[6:0]);
        $display("Immediate: %0d (Should be 5)", imm);
        $display("RegWrite: %b (Should be 1)", reg_write);
        $display("ALUSrc: %b (Should be 1)", alu_src);
        $display("ALUCtrl: %b (Should be 0000 for ADD)", alu_ctrl);
        
        $finish;
    end
endmodule
