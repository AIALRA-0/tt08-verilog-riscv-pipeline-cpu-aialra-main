![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# RISC-V 5-Stage Pipeline CPU

## Introduction
This is a 5-stage pipeline CPU project based on the RISC-V instruction set.

## Completed
- Basic pipeline structure
- Basic instruction set execution (RV32I without CSR)
- EX stage forwarding unit
- UART-based independent memory read/write

## To Be Implemented
- More complete instruction set support (RV32I/others)
- System operation
- Multi-issue
- Out-of-order execution
- Timing optimization

## Reference Pipeline Architecture
![image](https://github.com/user-attachments/assets/e4b04ce4-fd53-48a1-ab15-ee8ad56b84f4)

## Schematic
![image](https://github.com/user-attachments/assets/d1385b1f-b282-435e-81fb-10700d6a8599)

## Supported Instructions
- add: Addition
- sub: Subtraction
- and: Bitwise AND
- or: Bitwise OR
- xor: Bitwise XOR
- addi: Addition with immediate
- andi: Bitwise AND with immediate
- ori: Bitwise OR with immediate
- xori: Bitwise XOR with immediate
- beq: Branch if equal
- bne: Branch if not equal
- mul: Signed multiplication
- mulh: High-order signed multiplication
- mulhu: High-order unsigned multiplication
- mulhsu: High-order signed and unsigned mixed multiplication
- div: Signed division
- divu: Unsigned division
- rem: Signed remainder
- remu: Unsigned remainder
- sll: Logical left shift
- srl: Logical right shift
- sra: Arithmetic right shift
- slli: Immediate logical left shift
- srli: Immediate logical right shift
- srai: Immediate arithmetic right shift
- slt: Set if less than
- sltu: Set if unsigned less than
- slti: Set if less than immediate
- sltiu: Set if unsigned less than immediate
- blt: Branch if less than
- bge: Branch if greater than or equal
- bltu: Branch if unsigned less than
- bgeu: Branch if unsigned greater than or equal
- jal: Jump and link (for function calls)
- jalr: Register jump and link
- sw: Store word
- lw: Load word into register, at least one nop required to avoid hazard
- lui: Load upper immediate into register
- lb: Load byte, at least one nop required to avoid hazard
- lh: Load halfword, at least one nop required to avoid hazard
- lbu: Load unsigned byte, at least one nop required to avoid hazard
- lhu: Load unsigned halfword, at least one nop required to avoid hazard
- sb: Store byte
- sh: Store halfword
- auipc: Load 20-bit immediate into PC upper bits, adding current PC lower bits to form new address

* Test project file is `./test/program.mem` 
