# SystemVerilog OOP Verification Environment
A robust SystemVerilog Layered Testbench using OOP principles to verify a Digital Multiplier (DUT). Features constrained random generation, self-checking scoreboard, and functional coverage analysis.
## Overview
This project implements a **layered testbench architecture** to verify the functional correctness of an arithmetic unit. 
<img width="1627" height="1090" alt="Architecture" src="https://github.com/user-attachments/assets/761c2357-a99f-411e-a355-da149975ce48" />

## Tools Used 
-Simulated using :EDA Playground

## Key Features
- **Generator:** Uses rand and constraint blocks for corner-case stimulus.
- **Driver/Monitor:** Modular Componentes communicating via **Interfaces** and **Mailboxes**.
- **Scoreboard:** Automated self-checking mechanism (Golden Model).
- **Coverage:** Functional coverage gropus ensuring 100% verification of edge cases.



