`timescale 1ns/1ps

module tb_cpu;
    logic clk = 0;
    logic rst_n = 0;
    always #5 clk = ~clk;

    rv32i_cpu u_cpu (.clk(clk), .rst_n(rst_n));

    initial begin
        $display("CPU TESTBENCH STARTED");
        repeat(2) @(posedge clk);
        rst_n = 1;

        // Run for 20 clock cycles
        repeat(20) @(posedge clk);

        // Check results
        if (u_cpu.u_regs.regs[1] === 32'd5)
            $display("PASS: x1 = 5");
        else
            $display("FAIL: x1 = %0d (expected 5)", u_cpu.u_regs.regs[1]);

        if (u_cpu.u_regs.regs[2] === 32'd3)
            $display("PASS: x2 = 3");
        else
            $display("FAIL: x2 = %0d (expected 3)", u_cpu.u_regs.regs[2]);

        if (u_cpu.u_regs.regs[3] === 32'd8)
            $display("PASS: x3 = 8");
        else
            $display("FAIL: x3 = %0d (expected 8)", u_cpu.u_regs.regs[3]);

        if (u_cpu.u_dmem.mem[0] === 32'd8)
            $display("PASS: mem[0] = 8");
        else
            $display("FAIL: mem[0] = %0d (expected 8)", u_cpu.u_dmem.mem[0]);

        $finish;
    end
endmodule
