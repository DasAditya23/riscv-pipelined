`timescale 1ns/1ps

module tb_datapath;
    logic clk = 0;
    logic rst_n = 0;

    logic [31:0] alu_a, alu_b, alu_result;
    logic [3:0] alu_ctrl;
    logic alu_zero;

    logic we;
    logic [4:0] rs1, rs2, rd;
    logic [31:0] wdata, rdata1, rdata2;

    alu my_alu (
        .a(alu_a), .b(alu_b), .alu_ctrl(alu_ctrl),
        .result(alu_result), .zero(alu_zero)
    );

    regfile my_regs (
        .clk(clk), .rst_n(rst_n), .we(we),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .wdata(wdata), .rdata1(rdata1), .rdata2(rdata2)
    );

    always #5 clk = ~clk;

    initial begin
        $display("TESTBENCH STARTED");

        rst_n = 0; we = 0;
        repeat(2) @(posedge clk);
        rst_n = 1;
        repeat(2) @(posedge clk);

        we = 1; rd = 5; wdata = 32'd100;
        @(posedge clk); #1; we = 0;

        we = 1; rd = 6; wdata = 32'd25;
        @(posedge clk); #1; we = 0;

        rs1 = 5; rs2 = 6;
        #1;
        $display("rdata1=%0d rdata2=%0d", rdata1, rdata2);

        alu_a = 32'd100; alu_b = 32'd25;
        alu_ctrl = 4'b0000; #1;
        $display("ALU ADD: 100 + 25 = %0d", alu_result);

        alu_ctrl = 4'b0001; #1;
        $display("ALU SUB: 100 - 25 = %0d", alu_result);

        rs1 = 0; #1;
        $display("Register x0 reads as: %0d (Should be 0)", rdata1);

        $display("Simulation complete.");
        $finish;
    end
endmodule
