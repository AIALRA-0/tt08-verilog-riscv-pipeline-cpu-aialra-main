<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

### Introduction
This is a project for a 5-stage pipeline CPU based on the RISC-V instruction set. 
The stages include Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), and Write Back (WB).
By implementing pipelining technology, the CPU can process multiple instructions in each clock cycle, thus improving processing efficiency.

### Basic Features Implemented
- Basic pipeline structure
- Basic instruction set execution (RV32I without CSR)
- Forwarding unit in the EX stage
- Independent memory read/write based on UART

### Reference Pipeline Architecture
![image](https://github.com/user-attachments/assets/e4b04ce4-fd53-48a1-ab15-ee8ad56b84f4)

### Supported Instructions
- add: addition
- sub: subtraction
- and: bitwise AND
- or: bitwise OR
- xor: bitwise XOR
- addi: addition with immediate
- andi: bitwise AND with immediate
- ori: bitwise OR with immediate
- xori: bitwise XOR with immediate
- beq: branch if equal
- bne: branch if not equal
- mul: signed multiplication
- mulh: high part of signed multiplication
- mulhu: high part of unsigned multiplication
- mulhsu: high part of signed and unsigned mixed multiplication
- div: signed division
- divu: unsigned division
- rem: signed remainder
- remu: unsigned remainder
- sll: logical left shift
- srl: logical right shift
- sra: arithmetic right shift
- slli: logical left shift with immediate
- srli: logical right shift with immediate
- srai: arithmetic right shift with immediate
- slt: set less than
- sltu: set less than unsigned
- slti: set less than immediate
- sltiu: set less than immediate unsigned
- blt: branch if less than
- bge: branch if greater than or equal
- bltu: branch if less than unsigned
- bgeu: branch if greater than or equal unsigned
- jal: jump and link (for function calls)
- jalr: jump and link register
- sw: store word
- lw: load word to register, requires at least one nop to avoid hazards
- lui: load upper immediate
- lb: load byte, requires at least one nop to avoid hazards
- lh: load half-word, requires at least one nop to avoid hazards
- lbu: load byte unsigned, requires at least one nop to avoid hazards
- lhu: load half-word unsigned, requires at least one nop to avoid hazards
- sb: store byte
- sh: store half-word
- auipc: add upper immediate to PC

## How to test

### Testing Process
- Test project memory file located at ./test/program.mem
- (Simulation) Load binary instructions into the program.mem file
- (Testing) Use ui_in[1] to send UART data packets, loading binary instructions/data into instruction memory and data memory
- Enable ui_in[0], CPU starts executing instructions sequentially
- Disable ui_in[0], use the UART interface uo_out[0] to send UART data packets to read instruction memory and data memory

### UART Data Packet Format
![data_frame](https://github.com/user-attachments/assets/f64bc7ff-de2d-498a-bfa6-c8b2dd5403c6)

## External hardware

Uses a 7-segment display as the test output for the benchmark loop program.
The project includes a default 7-segment display driver peripheral that reads the value in data memory[0] for output.
