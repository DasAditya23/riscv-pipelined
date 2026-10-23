module rv32i_pipelined (
    input  logic clk,
    input  logic rst_n
);
    // ===== IF stage =====
    logic [31:0] pc_current, pc_next, pc_plus4, pc_target;
    logic [31:0] instr_if;
    logic        take_branch;
    logic [31:0] branch_target_from_ex;

    assign pc_plus4 = pc_current + 4;
    assign pc_next  = take_branch ? branch_target_from_ex : pc_plus4;

    pc u_pc (.clk(clk), .rst_n(rst_n), .pc_next(pc_next), .pc_current(pc_current));
    imem u_imem (.addr(pc_current), .instr(instr_if));

    // ===== IF/ID =====
    logic [31:0] if_id_pc, if_id_instr;
    logic        stall, flush;
    assign flush = take_branch;

    if_id_reg u_if_id (
        .clk(clk), .rst_n(rst_n), .flush(flush), .stall(stall),
        .pc_in(pc_current), .instr_in(instr_if),
        .pc_out(if_id_pc), .instr_out(if_id_instr)
    );

    // ===== ID stage =====
    logic [4:0] id_rs1, id_rs2, id_rd;
    logic [31:0] id_rdata1, id_rdata2, id_imm;
    logic        id_reg_write, id_mem_read, id_mem_write, id_mem_to_reg;
    logic        id_alu_src, id_branch;
    logic [3:0]  id_alu_ctrl;

    assign id_rs1 = if_id_instr[19:15];
    assign id_rs2 = if_id_instr[24:20];
    assign id_rd  = if_id_instr[11:7];

    regfile u_regs (
        .clk(clk), .rst_n(rst_n), .we(mem_wb_reg_write_final),
        .rs1(id_rs1), .rs2(id_rs2), .rd(mem_wb_rd),
        .wdata(mem_wb_wdata), .rdata1(id_rdata1), .rdata2(id_rdata2)
    );

    immgen u_imm (.instr(if_id_instr), .imm_out(id_imm));

    control u_ctrl (
        .opcode(if_id_instr[6:0]), .funct3(if_id_instr[14:12]), .funct7(if_id_instr[31:25]),
        .reg_write(id_reg_write), .mem_read(id_mem_read), .mem_write(id_mem_write),
        .mem_to_reg(id_mem_to_reg), .alu_src(id_alu_src), .branch(id_branch), .alu_ctrl(id_alu_ctrl)
    );

    // ===== ID/EX =====
    logic [31:0] ex_pc, ex_rdata1, ex_rdata2, ex_imm;
    logic [4:0]  ex_rs1, ex_rs2, ex_rd;
    logic        ex_reg_write, ex_mem_read, ex_mem_write, ex_mem_to_reg;
    logic        ex_alu_src, ex_branch;
    logic [3:0]  ex_alu_ctrl;

    id_ex_reg u_id_ex (
        .clk(clk), .rst_n(rst_n), .flush(flush),
        .pc_in(if_id_pc), .rdata1_in(id_rdata1), .rdata2_in(id_rdata2), .imm_in(id_imm),
        .rs1_in(id_rs1), .rs2_in(id_rs2), .rd_in(id_rd),
        .reg_write_in(id_reg_write), .mem_read_in(id_mem_read), .mem_write_in(id_mem_write),
        .mem_to_reg_in(id_mem_to_reg), .alu_src_in(id_alu_src), .branch_in(id_branch),
        .alu_ctrl_in(id_alu_ctrl),
        .pc_out(ex_pc), .rdata1_out(ex_rdata1), .rdata2_out(ex_rdata2), .imm_out(ex_imm),
        .rs1_out(ex_rs1), .rs2_out(ex_rs2), .rd_out(ex_rd),
        .reg_write_out(ex_reg_write), .mem_read_out(ex_mem_read), .mem_write_out(ex_mem_write),
        .mem_to_reg_out(ex_mem_to_reg), .alu_src_out(ex_alu_src), .branch_out(ex_branch),
        .alu_ctrl_out(ex_alu_ctrl)
    );

    // ===== EX stage =====
    logic [1:0] fwd_a, fwd_b;
    logic [31:0] alu_a_muxed, alu_b_muxed, alu_b_pre, alu_result;
    logic        alu_zero;

    forwarding u_fwd (
        .id_ex_rs1(ex_rs1), .id_ex_rs2(ex_rs2),
        .ex_mem_rd(ex_mem_rd), .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_rd(mem_wb_rd), .mem_wb_reg_write(mem_wb_reg_write),
        .fwd_a(fwd_a), .fwd_b(fwd_b)
    );

    always @(*) begin
        case (fwd_a)
            2'b10: alu_a_muxed = ex_mem_alu_result;
            2'b01: alu_a_muxed = mem_wb_wdata;
            default: alu_a_muxed = ex_rdata1;
        endcase
    end

    always @(*) begin
        case (fwd_b)
            2'b10: alu_b_pre = ex_mem_alu_result;
            2'b01: alu_b_pre = mem_wb_wdata;
            default: alu_b_pre = ex_rdata2;
        endcase
    end

    assign alu_b_muxed = ex_alu_src ? ex_imm : alu_b_pre;
    assign branch_target_from_ex = ex_pc + ex_imm;
    assign take_branch = ex_branch && alu_zero;

    alu u_alu (.a(alu_a_muxed), .b(alu_b_muxed), .alu_ctrl(ex_alu_ctrl),
               .result(alu_result), .zero(alu_zero));

    // ===== EX/MEM =====
    logic [31:0] ex_mem_alu_result, ex_mem_rdata2;
    logic [4:0]  ex_mem_rd;
    logic        ex_mem_reg_write, ex_mem_mem_read, ex_mem_mem_write, ex_mem_mem_to_reg;

    ex_mem_reg u_ex_mem (
        .clk(clk), .rst_n(rst_n),
        .alu_result_in(alu_result), .rdata2_in(alu_b_pre),
        .rd_in(ex_rd),
        .reg_write_in(ex_reg_write), .mem_read_in(ex_mem_read), .mem_write_in(ex_mem_write),
        .mem_to_reg_in(ex_mem_to_reg),
        .alu_result_out(ex_mem_alu_result), .rdata2_out(ex_mem_rdata2),
        .rd_out(ex_mem_rd),
        .reg_write_out(ex_mem_reg_write), .mem_read_out(ex_mem_mem_read),
        .mem_write_out(ex_mem_mem_write), .mem_to_reg_out(ex_mem_mem_to_reg)
    );

    // ===== MEM stage =====
    logic [31:0] mem_rdata;
    dmem u_dmem (
        .clk(clk), .mem_read(ex_mem_mem_read), .mem_write(ex_mem_mem_write),
        .addr(ex_mem_alu_result), .wdata(ex_mem_rdata2), .rdata(mem_rdata)
    );

    // ===== MEM/WB =====
    logic [31:0] mem_wb_alu_result, mem_wb_mem_rdata, mem_wb_wdata;
    logic [4:0]  mem_wb_rd;
    logic        mem_wb_reg_write, mem_wb_mem_to_reg;
    logic        mem_wb_reg_write_final;

    mem_wb_reg u_mem_wb (
        .clk(clk), .rst_n(rst_n),
        .alu_result_in(ex_mem_alu_result), .mem_rdata_in(mem_rdata),
        .rd_in(ex_mem_rd),
        .reg_write_in(ex_mem_reg_write), .mem_to_reg_in(ex_mem_mem_to_reg),
        .alu_result_out(mem_wb_alu_result), .mem_rdata_out(mem_wb_mem_rdata),
        .rd_out(mem_wb_rd),
        .reg_write_out(mem_wb_reg_write), .mem_to_reg_out(mem_wb_mem_to_reg)
    );

    assign mem_wb_wdata = mem_wb_mem_to_reg ? mem_wb_mem_rdata : mem_wb_alu_result;
    assign mem_wb_reg_write_final = mem_wb_reg_write;

    // ===== Hazard detection =====
    hazard u_haz (
        .id_ex_mem_read(ex_mem_read), .id_ex_rd(ex_rd),
        .if_id_rs1(id_rs1), .if_id_rs2(id_rs2),
        .stall(stall)
    );

endmodule
