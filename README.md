# 5-Stage Pipelined RV32I CPU

A synthesizable 5-stage pipelined RISC-V (RV32I) processor written in SystemVerilog, with data forwarding, load-use hazard detection, and branch flushing.

## Architecture
- IF: Program Counter + Instruction Memory
- ID: Register File + Immediate Generator + Control Unit
- EX: ALU + Forwarding Unit
- MEM: Data Memory
- WB: Write-back Mux

## Features
- 5 pipeline stages with IF/ID, ID/EX, EX/MEM, and MEM/WB pipeline registers.
- Forwarding paths from EX/MEM and MEM/WB back to the ALU (resolves data hazards without stalling).
- Hazard detection for load-use dependencies (1-cycle stall).
- Branch flushing to discard wrong-path instructions on taken branches.

## Verified Program
| Instruction | Effect | Result |
|---|---|---|
| addi x1, x0, 5 | x1 = 5 | PASS |
| addi x2, x0, 3 | x2 = 3 | PASS |
| add x3, x1, x2 | x3 = 8 (forwarded) | PASS |
| sw x3, 0(x0) | mem[0] = 8 | PASS |

## Related Projects
- [Synchronous FIFO RTL-to-GDSII](https://github.com/DasAditya23/sync-fifo-sky130)
- [8-Tap Fixed-Point FIR Filter](https://github.com/DasAditya23/fir-filter-sky130)
- [Secure E-Commerce Backend](https://github.com/DasAditya23/ecommerce-engine)
- [Personal Finance Tracker](https://github.com/DasAditya23/finance-tracker)

