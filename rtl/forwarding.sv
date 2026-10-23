module forwarding (
    input  logic [4:0]  id_ex_rs1,
    input  logic [4:0]  id_ex_rs2,
    input  logic [4:0]  ex_mem_rd,
    input  logic        ex_mem_reg_write,
    input  logic [4:0]  mem_wb_rd,
    input  logic        mem_wb_reg_write,
    output logic [1:0]  fwd_a,  // 00 = from ID/EX regfile, 10 = from EX/MEM, 01 = from MEM/WB
    output logic [1:0]  fwd_b
);
    always @(*) begin
        // Forwarding for operand A
        if (ex_mem_reg_write && ex_mem_rd != 5'd0 && ex_mem_rd == id_ex_rs1) begin
            fwd_a = 2'b10;
        end else if (mem_wb_reg_write && mem_wb_rd != 5'd0 && mem_wb_rd == id_ex_rs1) begin
            fwd_a = 2'b01;
        end else begin
            fwd_a = 2'b00;
        end

        // Forwarding for operand B
        if (ex_mem_reg_write && ex_mem_rd != 5'd0 && ex_mem_rd == id_ex_rs2) begin
            fwd_b = 2'b10;
        end else if (mem_wb_reg_write && mem_wb_rd != 5'd0 && mem_wb_rd == id_ex_rs2) begin
            fwd_b = 2'b01;
        end else begin
            fwd_b = 2'b00;
        end
    end
endmodule
