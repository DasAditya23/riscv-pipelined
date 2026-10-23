module id_ex_reg (
    input  logic clk,
    input  logic rst_n,
    input  logic flush,
    input  logic [31:0] pc_in,
    input  logic [31:0] rdata1_in, rdata2_in, imm_in,
    input  logic [4:0] rs1_in, rs2_in, rd_in,
    input  logic reg_write_in, mem_read_in, mem_write_in, mem_to_reg_in,
    input  logic alu_src_in, branch_in,
    input  logic [3:0] alu_ctrl_in,
    output logic [31:0] pc_out,
    output logic [31:0] rdata1_out, rdata2_out, imm_out,
    output logic [4:0] rs1_out, rs2_out, rd_out,
    output logic reg_write_out, mem_read_out, mem_write_out, mem_to_reg_out,
    output logic alu_src_out, branch_out,
    output logic [3:0] alu_ctrl_out
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            pc_out <= 0; rdata1_out <= 0; rdata2_out <= 0; imm_out <= 0;
            rs1_out <= 0; rs2_out <= 0; rd_out <= 0;
            reg_write_out <= 0; mem_read_out <= 0; mem_write_out <= 0;
            mem_to_reg_out <= 0; alu_src_out <= 0; branch_out <= 0;
            alu_ctrl_out <= 0;
        end else begin
            pc_out <= pc_in; rdata1_out <= rdata1_in; rdata2_out <= rdata2_in; imm_out <= imm_in;
            rs1_out <= rs1_in; rs2_out <= rs2_in; rd_out <= rd_in;
            reg_write_out <= reg_write_in; mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in; mem_to_reg_out <= mem_to_reg_in;
            alu_src_out <= alu_src_in; branch_out <= branch_in; alu_ctrl_out <= alu_ctrl_in;
        end
    end
endmodule
