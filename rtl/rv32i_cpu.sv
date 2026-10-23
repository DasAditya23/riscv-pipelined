module rv32i_cpu (
    input  logic clk,
    input  logic rst_n
);
    // PC
    logic [31:0] pc_current, pc_next, pc_plus4, pc_target;
    logic [31:0] instr;

    // Register file
    logic        reg_write;
    logic [4:0]  rs1, rs2, rd;
    logic [31:0] rdata1, rdata2, wdata;

    // Control
    logic        mem_read, mem_write, mem_to_reg, alu_src, branch;
    logic [3:0]  alu_ctrl;
    logic [31:0] imm;

    // ALU
    logic [31:0] alu_a, alu_b, alu_result;
    logic        alu_zero;

    // Branch calculation
    logic        take_branch;
    assign take_branch = branch && alu_zero;
    assign pc_plus4  = pc_current + 4;
    assign pc_target = pc_current + imm;
    assign pc_next   = take_branch ? pc_target : pc_plus4;

    // Instantiate everything
    pc u_pc (.clk(clk), .rst_n(rst_n), .pc_next(pc_next), .pc_current(pc_current));
    imem u_imem (.addr(pc_current), .instr(instr));

    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd  = instr[11:7];

    regfile u_regs (
        .clk(clk), .rst_n(rst_n), .we(reg_write),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .wdata(wdata), .rdata1(rdata1), .rdata2(rdata2)
    );

    immgen u_imm (.instr(instr), .imm_out(imm));

    control u_ctrl (
        .opcode(instr[6:0]), .funct3(instr[14:12]), .funct7(instr[31:25]),
        .reg_write(reg_write), .mem_read(mem_read), .mem_write(mem_write),
        .mem_to_reg(mem_to_reg), .alu_src(alu_src), .branch(branch), .alu_ctrl(alu_ctrl)
    );

    assign alu_a = rdata1;
    assign alu_b = alu_src ? imm : rdata2;

    alu u_alu (.a(alu_a), .b(alu_b), .alu_ctrl(alu_ctrl), .result(alu_result), .zero(alu_zero));

    logic [31:0] mem_rdata;
    dmem u_dmem (
        .clk(clk), .mem_read(mem_read), .mem_write(mem_write),
        .addr(alu_result), .wdata(rdata2), .rdata(mem_rdata)
    );

    assign wdata = mem_to_reg ? mem_rdata : alu_result;

endmodule
