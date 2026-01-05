# AHB to APB Bridge – SystemVerilog Project

## Overview

This repository contains a complete **AHB-Lite to APB bridge** implementation written in SystemVerilog. The project includes synthesizable RTL, a simple APB slave model, and a testbench that verifies correct read and write operation through waveform observation.

The bridge handles the protocol mismatch between the high-performance AHB-Lite bus and the low-power APB bus by stalling AHB transactions while performing APB SETUP and ACCESS phases.

This project is intended for RTL design practice, protocol understanding, and verification interview preparation.

---

## Features

* AHB-Lite compliant interface
* APB-compliant two-phase transfer (SETUP and ACCESS)
* FSM-based bridge architecture
* Proper AHB stalling using HREADY
* Supports single read and write transfers
* Fully synthesizable RTL
* Executable behavioral testbench

---

## Project Structure

```
AHB_APB_Bridge/
├── ahb_to_apb_bridge.sv   # AHB to APB bridge RTL
├── apb_slave_model.sv    # Simple APB memory-mapped slave
├── tb_ahb_apb_bridge.sv  # Testbench (AHB master)
└── README.md
```

---

## Design Description

### AHB to APB Bridge

The bridge captures valid AHB-Lite transfers and converts them into APB transactions. Since APB is non-pipelined and slower, the bridge stalls the AHB bus using HREADY until the APB transfer completes.

A three-state FSM is used:

```
IDLE → SETUP → ACCESS → IDLE
```

* **IDLE**: Waits for a valid AHB transfer
* **SETUP**: Drives APB address and control signals
* **ACCESS**: Asserts PENABLE and waits for PREADY

Read data from APB is returned to AHB only after the ACCESS phase completes.

---

## APB Slave Model

The APB slave model is a simple memory-mapped peripheral used for verification.

* 256-word internal memory
* Zero wait states (PREADY always high)
* Supports APB read and write operations

This model allows validation of correct address, data, and control transfer through the bridge.

---

## Testbench

The testbench acts as an AHB-Lite master and performs the following operations:

1. Generates clock and reset
2. Issues a single AHB write transaction
3. Issues a single AHB read transaction
4. Verifies returned read data via waveform and console output

The testbench is intended for functional verification and waveform inspection.

---

## Simulation Instructions

### Vivado / Questa / ModelSim

1. Add all SystemVerilog files to the project
2. Set `tb_ahb_apb_bridge` as the simulation top module
3. Run behavioral simulation

### EDA Playground

* Language: SystemVerilog
* Top module: `tb_ahb_apb_bridge`
* Run simulation

---

## Expected Result

Console output:

```
Read Data = DEADBEEF
```

Waveform verification confirms:

* Correct AHB stalling during APB access
* Proper APB SETUP and ACCESS phases
* Correct read and write data transfer

---

## Tools Used

* Vivado Simulator 2025.1

---

## Limitations

* Single AHB master
* Single APB slave
* No burst transactions
* No SPLIT or RETRY responses
* Common clock for AHB and APB

---

## Possible Extensions

* Multiple APB slaves with address decoding
* APB wait-state insertion
* SystemVerilog assertions for protocol checking
* Functional coverage
* Randomized AHB transactions

---

