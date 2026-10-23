module pc (
    input  logic clk,
    input  logic rst_n,
    input  logic [31:0] pc_next,
    output logic [31:0] pc_current
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) pc_current <= 32'd0;
        else pc_current <= pc_next;
    end
endmodule
