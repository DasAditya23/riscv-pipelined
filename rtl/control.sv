module control (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic       reg_write,
    output logic       mem_read,
    output logic       mem_write,
    output logic       mem_to_reg,
    output logic       alu_src,
    output logic       branch,
    output logic [3:0] alu_ctrl
);

    always @(*) begin
        // Defaults
        reg_write = 0; mem_read = 0; mem_write = 0;
        mem_to_reg = 0; alu_src = 0; branch = 0;
        alu_ctrl = 4'b0000;

        case (opcode)
            // R-type (add, sub, and, or, slt)
            7'b0110011: begin
                reg_write = 1;
                case (funct3)
                    3'b000: alu_ctrl = (funct7[5]) ? 4'b0001 : 4'b0000; // SUB or ADD
                    3'b111: alu_ctrl = 4'b1001; // AND
                    3'b110: alu_ctrl = 4'b1000; // OR
                    3'b010: alu_ctrl = 4'b0011; // SLT
                endcase
            end
            // I-type (addi, lw)
            7'b0010011: begin
                reg_write = 1;
                alu_src = 1;
                alu_ctrl = 4'b0000; // ADD
            end
            7'b0000011: begin
                reg_write = 1;
                mem_read = 1;
                mem_to_reg = 1;
                alu_src = 1;
                alu_ctrl = 4'b0000; // ADD
            end
            // S-type (sw)
            7'b0100011: begin
                mem_write = 1;
                alu_src = 1;
                alu_ctrl = 4'b0000; // ADD
            end
            // B-type (beq)
            7'b1100011: begin
                branch = 1;
                alu_ctrl = 4'b0001; // SUB (for comparison)
            end
        endcase
    end

endmodule
