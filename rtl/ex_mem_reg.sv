module ex_mem_reg (
    input  logic clk,
    input  logic rst_n,
    input  logic [31:0] alu_result_in, rdata2_in,
    input  logic [4:0] rd_in,
    input  logic reg_write_in, mem_read_in, mem_write_in, mem_to_reg_in,
    output logic [31:0] alu_result_out, rdata2_out,
    output logic [4:0] rd_out,
    output logic reg_write_out, mem_read_out, mem_write_out, mem_to_reg_out
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alu_result_out <= 0; rdata2_out <= 0; rd_out <= 0;
            reg_write_out <= 0; mem_read_out <= 0; mem_write_out <= 0; mem_to_reg_out <= 0;
        end else begin
            alu_result_out <= alu_result_in; rdata2_out <= rdata2_in; rd_out <= rd_in;
            reg_write_out <= reg_write_in; mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in; mem_to_reg_out <= mem_to_reg_in;
        end
    end
endmodule
