# ARC4 Hardware Decryption & Cracking (SystemVerilog)

This project implements an ARC4 decryption and key-cracking system in SystemVerilog, targeting FPGA-based execution.

The design uses on-chip memories and a ready/enable microprotocol to support multi-cycle operations and modular composition.

---

## Overview

The ARC4 pipeline consists of:
- State initialization
- Key-Scheduling Algorithm (KSA)
- Pseudo-Random Generation Algorithm (PRGA)
- Brute-force key search (cracking)

The system can decrypt ciphertext and recover the encryption key via exhaustive search.

---

## Features

- Modular RTL design with reusable components (`init`, `ksa`, `prga`, `arc4`, `crack`)
- Ready/enable handshake for variable-latency modules  
- On-chip memory integration for state, ciphertext, and plaintext  
- Brute-force key search over 24-bit key space  
- Simulation and FPGA validation support  

---

## Status

- State initialization
- scheduling (KSA)
- ARC4 decryption (PRGA + integration)
- Key cracking

---

## Notes

This project was developed as part of a digital design lab focused on memory-based architectures and hardware implementation of cryptographic algorithms

---

## Tech

- SystemVerilog  
- ModelSim (simulation)  
- Quartus (FPGA synthesis)  

---

## Future Work

- Parallel key search
- Performance optimization (latency, throughput)  
- Improved test coverage and verification  