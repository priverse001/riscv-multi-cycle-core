# M-RV32I: Multi-Cycle RISC-V Processor Core

![RISC-V](https://img.shields.io/badge/Architecture-RISC--V-blue)
![ISA](https://img.shields.io/badge/ISA-RV32I-orange)
![Pipeline](https://img.shields.io/badge/Pipeline-Multi--Cycle-green)
![Target](https://img.shields.io/badge/Target-Xilinx_FPGA-purple)

This repository contains the Verilog RTL source code and documentation for **M-RV32I**, an open-source, area-optimized CPU core implementing the 32-bit RISC-V Base Integer Instruction Set Architecture (RV32I).

## Features
- **Resource Multiplexing**: Highly optimized area footprint utilizing a single Shared ALU for PC calculations, branching, and arithmetic.
- **Unified Memory**: Operates on a Von Neumann architecture with a unified Instruction/Data memory.
- **Variable CPI (3-5)**: 10-state Finite State Machine (FSM) ensures instructions only consume necessary clock cycles.
- **Synthesizable**: Clean Verilog HDL tailored for Xilinx 7-Series / UltraScale+ FPGAs.

## Repository Structure
- `*.v` / `srcs/` - Verilog RTL core files (ALU, FSM Control Unit, Memory, etc.)
- `tb_processor.v` - Self-checking simulation testbench
- `/docs/` - High-quality PDF architecture reference manual

## Documentation
A massive, detailed technical architecture manual is available in the `docs` folder. It includes complete 10-state FSM orthogonal flow diagrams, cycle-by-cycle breakdowns, and estimated resource utilization metrics.

**[Read the full Design Report (PDF)](./docs/design_report.pdf)**

## Performance & Resource Utilization
By breaking the critical path into stages and heavily multiplexing components, this architecture achieves excellent area utilization at the cost of a higher average CPI.
- **Average CPI**: $\approx$ 4.05 (Based on standard integer workloads)
- **Max Frequency ($F_{max}$)**: $\approx$ 115 MHz (Significantly faster clock than a single-cycle implementation)
- **LUT Utilization**: $\approx$ 480 LUTs (Highly efficient due to Shared ALU)
- **Flip-Flops**: $\approx$ 250 (State and Pipeline Registers)

## Simulation
You can simulate the core using Xilinx Vivado or Icarus Verilog. The testbench verifies the core by running a sequence of instructions (load, store, arithmetic, branch) achieving exact expected register file states after 80 clock cycles.
