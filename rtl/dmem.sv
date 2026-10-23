module dmem (
    input  logic clk,
    input  logic mem_read,
    input  logic mem_write,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata
);
    logic [31:0] mem [0:255];
    assign rdata = mem_read ? mem[addr[9:2]] : 32'd0;
    always_ff @(posedge clk) begin
        if (mem_write) mem[addr[9:2]] <= wdata;
    end
endmodule
