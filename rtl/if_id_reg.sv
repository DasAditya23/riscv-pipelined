module if_id_reg (
    input  logic clk,
    input  logic rst_n,
    input  logic flush,
    input  logic stall,
    input  logic [31:0] pc_in,
    input  logic [31:0] instr_in,
    output logic [31:0] pc_out,
    output logic [31:0] instr_out
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out <= 0; instr_out <= 32'h00000013; // NOP
        end else if (flush) begin
            pc_out <= 0; instr_out <= 32'h00000013;
        end else if (!stall) begin
            pc_out <= pc_in; instr_out <= instr_in;
        end
    end
endmodule
