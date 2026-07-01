# Pipelined RISC-V Processor

This repository contains a pipelined RISC-V processor implemented in SystemVerilog. The project is developed for computer architecture learning and focuses on improving a basic RISC-V processor design by applying pipeline execution.

The processor is divided into multiple pipeline stages, allowing different instructions to be processed at different stages in the same clock cycle. Compared with a single-cycle processor, this design helps demonstrate how instruction throughput can be improved by separating the datapath into smaller execution stages.

## 1. Project Overview

The main objective of this project is to design and verify a 32-bit pipelined RISC-V processor. The design includes instruction fetch, instruction decode, execute, memory access, and writeback stages.

The processor uses separate instruction memory and data memory. This follows a Harvard-like structure, where instruction access and data access are handled independently.

The design also includes basic hazard handling and forwarding logic. These units are important in a pipelined processor because instructions may depend on results from previous instructions that have not yet reached the writeback stage.

## 2. Main Features

1. 32-bit pipelined RISC-V processor

2. Written in SystemVerilog

3. Five main pipeline stages

4. Separate instruction memory and data memory

5. Register file with 32 general-purpose registers

6. ALU supporting arithmetic and logic operations

7. Branch decision logic

8. Load-store memory access

9. Hazard detection for load-use situations

10. Forwarding unit for reducing data hazards

11. Testbench with driver and scoreboard

12. Simulation support using Cadence Xcelium and SimVision

## 3. Pipeline Stages

The processor is organized into five main stages.

1. Instruction Fetch

This stage reads the instruction from instruction memory using the current program counter. The next program counter value is also calculated in this stage.

2. Instruction Decode

This stage decodes the instruction, reads source registers from the register file, generates immediate values, and produces control signals.

3. Execute

This stage performs ALU operations, branch comparison, jump address calculation, and operand forwarding.

4. Memory

This stage handles load and store operations through the load-store unit and data memory.

5. Writeback

This stage writes the final result back to the register file. The writeback data may come from the ALU, memory, or PC plus 4 for jump instructions.

## 4. Main Modules

### `pipelined.sv`

This is the main processor module. It connects the pipeline stages and controls the flow of instruction data through the processor.

Important functions in this module include PC update, instruction fetch, instruction decode, ALU execution, memory access, writeback, hazard detection, forwarding, and debug signal generation.

### `allmodule.sv`

This file contains supporting modules used by the pipelined processor. It includes arithmetic units, muxes, register file, immediate generator, branch logic, memory-related modules, and other basic digital components.

### `if_id`

This module stores information between the Instruction Fetch stage and the Instruction Decode stage. It keeps the fetched instruction, program counter, and instruction valid signal.

### `id_ex`

This module stores decoded instruction information and control signals between the Decode stage and Execute stage.

### `ex_mem`

This module stores ALU result, store data, control signals, and destination register information between the Execute stage and Memory stage.

### `mem_wb`

This module stores memory output, ALU result, destination register, and writeback control signals between the Memory stage and Writeback stage.

### `hazard_unit`

This module detects pipeline hazards. It is mainly used to stall or clear the pipeline when an instruction depends on data that is not ready yet.

### `forwarding_unit`

This module selects forwarded data from later pipeline stages to reduce unnecessary stalls caused by data dependency.

### `scoreboard.sv`

This module monitors the simulation result. It counts total clock cycles, valid instructions, control transfer instructions, and branch mispredictions. It also calculates IPC and branch misprediction rate during simulation.

## 5. Supported Instruction Groups

The processor is designed around the RV32I instruction format. It supports the main instruction groups needed for a basic RISC-V processor.

1. Register arithmetic and logic instructions

2. Immediate arithmetic and logic instructions

3. Load instructions

4. Store instructions

5. Conditional branch instructions

6. Jump instructions

7. Upper immediate instructions

Typical operations include ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND, LUI, AUIPC, JAL, JALR, branch instructions, load instructions, and store instructions.

## 6. Repository Structure

```text
pipeline-risc_v/

00_src/
  allmodule.sv
  pipelined.sv

01_bench/
  tbench.sv
  driver.sv
  scoreboard.sv
  tlib.svh

02_test/
  isa_1b.hex
  isa_4b.hex

03_sim/
  makefile
```

## 7. Simulation Environment

The project uses Cadence Xcelium for simulation and SimVision for waveform debugging.

To run the simulation, go to the simulation folder first.

```bash
cd 03_sim
```

Create the file list.

```bash
make create_filelist
```

Run simulation.

```bash
make sim
```

Open waveform.

```bash
make wave
```

Run simulation in GUI mode.

```bash
make gui
```

Clean generated simulation files.

```bash
make clean
```

## 8. Testbench Description

The testbench provides the clock, reset, timeout control, waveform dumping, driver, and scoreboard.

The default testbench configuration is:

```systemverilog
`define RESET_PERIOD 51
`define CLOCK_PERIOD 2
`define TIMEOUT      50_000
```

The driver provides input switch data to the processor.

```systemverilog
i_io_sw = 32'h12345678;
```

The scoreboard monitors debug signals from the processor, including valid instruction signal, PC debug signal, control signal, and branch misprediction signal.

## 9. Verification Output

During simulation, the scoreboard displays the name of the ISA test and reports execution statistics after the program reaches the ending PC value.

The reported statistics include total executed clock cycles, total executed instructions, total branch instructions, total branch mispredictions, instruction per cycle, and branch misprediction rate.

Expected simulation message:

```text
PIPELINE - ISA tests

END of ISA tests
```

The waveform database is generated as:

```text
wave.shm
```

This waveform can be opened using SimVision to inspect pipeline signals, PC movement, instruction flow, stall, clear, forwarding, and branch behavior.

## 10. Learning Outcomes

This project helps practice important computer architecture concepts.

1. Designing a pipelined RISC-V datapath

2. Understanding the five-stage pipeline model

3. Building pipeline registers between stages

4. Handling data hazards using forwarding

5. Handling load-use hazards using stalls

6. Handling branch and jump control flow

7. Measuring IPC and branch misprediction behavior

8. Verifying processor behavior through simulation

9. Debugging digital designs using waveform analysis

## 11. Notes

This repository is intended for educational purposes. It demonstrates the transition from a single-cycle RISC-V processor to a pipelined RISC-V processor.

The design is useful for studying how instruction throughput can be improved and why hazard detection, forwarding, stall, and clear control are necessary in pipelined CPU architecture.
