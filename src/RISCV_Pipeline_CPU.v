//////////////////////////////////////////////////////////////////////////////////
// Company: AIALRA
// Engineer: Lucas Ding
// 
// Create Date: 2024/07/10 15:58:13
// Design Name: riscv_5stage_pipeline_cpu
// Module Name: RISCV_Pipeline
// Project Name: 
// Target Devices: xc7a35tcpg236-1/basys3
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Naming Convention:
// Independent Modules: Capitalized first letter
// Reusable Modules: Lowercase first letter
// Instantiated Modules: All lowercase

module RISCV_Pipeline_CPU
#(
    parameter INSTR_MEM_DEPTH = 128,
    parameter DATA_MEM_DEPTH = 128
)
(
    input wire clk,  // Global clock signal
    input wire reset, // Global reset signal
    input wire enable, // PC update enable signal
    input wire uart_rx, // uart_rx
    output wire uart_tx, // uart_tx
	output wire [31:0] data_mem0 // data_mem[0]
);

// *************************************
// ***            Signals            ***
// *************************************
// =====================================
// =        Memory Programming Signals =
// =====================================
    localparam BYTE_NUM = 4; // Number of bytes to transmit
    localparam DATA_BITS = 12; // Number of bits in the byte packet
    wire rw_flag; // Read/Write request flag
    
    // rx
    wire [31:0] uart_rx_data_out; // Data to write to the target
    wire write_mem_req; // Memory write request signal
    wire target_mem_type; // Target memory type
    wire [8:0] target_addr; // Target memory address
    
    // tx
    wire [41:0] uart_tx_data_out; // Read data
    wire uart_tx_done; // Memory write request signal
    wire instr_mem_tx_data_ready;
    wire data_mem_tx_data_ready;
    wire tx_ready;

// =====================================
// =            Cross-Domain Signals  =
// =====================================
    wire [31:0] write_data; // Data select mux output signal from memory to register
    wire [4:0] write_register; // Target write register number
    wire [31:0] pc_jump_addr; // Target branch address
    wire PCSrc;
    wire Flush;
    
// =====================================
// =        Control Unit Signals      =
// =====================================
    // ID stage
    wire [1:0] ALUOp_id;
    wire ALUSrc_id;
    wire Branch_id;
    wire MemRead_id;
    wire MemWrite_id;
    wire RegWrite_id;
    wire MemtoReg_id;
    wire Jump_id;
    wire JumpAddrSrc_id;
    wire ImmLoad_reg_id;
    wire [2:0] DataMemOutOp_id;
    wire WriteBackRegSrc_id;
    wire [1:0] ALUOp_mux_id;
    wire ALUSrc_mux_id;
    wire Branch_mux_id;
    wire MemRead_mux_id;
    wire MemWrite_mux_id;
    wire RegWrite_mux_id;
    wire MemtoReg_mux_id;
    wire Jump_mux_id;
    wire JumpAddrSrc_mux_id;
    wire ImmLoad_reg_mux_id;
    wire [2:0] DataMemOutOp_mux_id;
    wire WriteBackRegSrc_mux_id;
    
    // EX stage
    wire [1:0] ALUOp_ex;
    wire ALUSrc_ex;
    wire Branch_ex;
    wire MemRead_ex;
    wire MemWrite_ex;
    wire RegWrite_ex;
    wire MemtoReg_ex;
    wire Jump_ex;
    wire JumpAddrSrc_ex;
    wire [2:0] DataMemOutOp_ex;
    wire WriteBackRegSrc_ex;
    wire [1:0] ALUOp_mux_ex;
    wire ALUSrc_mux_ex;
    wire Branch_mux_ex;
    wire MemRead_mux_ex;
    wire MemWrite_mux_ex;
    wire RegWrite_mux_ex;
    wire MemtoReg_mux_ex;
    wire Jump_mux_ex;
    wire JumpAddrSrc_mux_ex;
    wire [2:0] DataMemOutOp_mux_ex;
    wire WriteBackRegSrc_mux_ex;
    
    // MEM stage
    wire Branch_mem;
    wire MemRead_mem;
    wire MemWrite_mem;
    wire RegWrite_mem;
    wire MemtoReg_mem;
    wire Jump_mem;
    wire [2:0] DataMemOutOp_mem;
    
    // WB stage
    wire RegWrite_wb;
    wire MemtoReg_wb;
    
// =====================================
// =          IF Stage Signals        =
// =====================================
    
    // PC
    wire [31:0] pc_in_if;
    wire [31:0] pc_out_if;

    // PC address adder
    wire [31:0] pc_adder_out_if;
    
    // Instruction memory & flush mux
    wire [31:0] instr_mux_if;
    wire [31:0] instr_if;
    
    
// =====================================
// =          ID Stage Signals        =
// =====================================
    
    // IF/ID input signals
    wire [31:0] instr_id;
    wire [31:0] pc_id;
    
    // Register file signals
    wire [4:0] read_register1_id = instr_id[19:15];
    wire [4:0] read_register2_id = instr_id[24:20];
    wire [31:0] read_data1_mux_id;
    wire [31:0] read_data1_id;
    wire [31:0] read_data2_id;
    
    // Instruction decode signals
    wire [9:0] funct_id = {instr_id[31:25], instr_id[14:12]}; // Combine funct7 and funct3
    wire [4:0] rd_id = instr_id[11:7];
    
    // Immediate value signals
    wire [31:0] imm_id; // Extended immediate value signal
    
// =====================================
// =          EX Stage Signals        =
// =====================================
    
    // ID/EX input signals
    wire [31:0] pc_ex;
    wire [31:0] read_data1_ex;
    wire [31:0] read_data2_ex;
    wire [31:0] imm_ex;
    wire [9:0] funct_ex;
    wire [4:0] rd_ex;
    
    // Forwarding unit signals
    wire [4:0] read_register1_ex;
    wire [4:0] read_register2_ex;
    wire [31:0] alu_operand1_fwd_ex;
    wire [31:0] alu_operand2_fwd_ex;
    wire [1:0] alu_operand1_sel_ex;
    wire [1:0] alu_operand2_sel_ex;
    wire [1:0] data_mem_write_data_sel_ex; // Control Data Memory write data selection
    wire [31:0] data_mem_write_data_ex;
    
    // Jump address adder
    wire [31:0] jump_address_ex; 
    wire [31:0] pc_minus_4_ex;
    wire [31:0] jump_base_addr_ex;
    
    // ALU signals
    wire [31:0] alu_operand2_ex; // ALU second operand
    wire [31:0] alu_result_ex; // ALU result signal
    wire alu_zero_ex; // ALU Zero signal
    
    // ALU output & wb register write back source mux signals
    wire [31:0] alu_result_mux_ex;
    wire [31:0] mem_data_ex;
    
    // ALU Control signals
    wire [5:0] alu_control_ex; // ALU control signal

// =====================================
// =          MEM Stage Signals       =
// =====================================
    
    // EX/MEM input signals
    wire alu_zero_mem;
    wire [31:0] mem_data_mem;
    wire [31:0] data_mem_write_data_mem;
    wire [4:0] rd_mem;
    
    // Data Memory signals
    wire [31:0] read_data_mem;
    
    // Data Memory Handler signals
    wire [31:0] processed_read_data_mem;
    wire [31:0] processed_write_data_mem;
    
// =====================================
// =          WB Stage Signals        =
// =====================================
    
    // MEM/WB input signals
    wire [31:0] read_data_wb;
    wire [31:0] data_wb;
	
	// Unused Signals
    wire _unused = &{uart_tx_done};
    
// *************************************
// ***           Instantiation       ***
// *************************************
// =====================================
// =       Memory Programming        =
// ===================================== 
    // Memory programmer
    // Data structure: 
    // Read/Write [11]: 1 for write packet / 0 for read packet
    // Packet type [10]: 1 for handshake packet / 0 for data packet
    // Target memory select [9]: 1 for instruction memory / 0 for data memory
    // Target address [8:0]: Supports up to 512
    // Data packet: First three bits are 0
    // Handshake packet: First bit is 0/1, second bit is 1, third bit is 0/1
    // Transmission method: tx sends a handshake packet, after rx recognizes it, receive the subsequent four data packets, extract the 32-bit data inside and send it to data_out, after completion set done high
    // Memory recognition: After the transmission is completed, the module sends out 32-bit data, 9-bit target memory address, and 1-bit target memory type, and sends a memory write request signal, if the data and instruction memory recognize that the enable signal is low and there is a memory write request, write the 32-bit data to the target memory address
    
    UART_Bytes_RX #(
        .BYTE_COUNT(BYTE_NUM),
        .DATA_BITS(DATA_BITS)
    ) mem_uart_rx_inst (
        .clk(clk),
        .reset(reset),
        .rx(uart_rx),
        .data_out(uart_rx_data_out),
        .done(write_mem_req),
        .target_addr(target_addr),
        .target_mem_type(target_mem_type),
        .rw_flag(rw_flag)
    );
    
    // Memory reader
    // Data structure: 
    // Read/Write [11]: 0 for read packet (return data)
    // Packet type [10]: 1 for handshake packet / 0 for data packet
    // Target memory select [9]: 1 for instruction memory / 0 for data memory
    // Target address [8:0]: Supports up to 512
    // Data packet: First three bits are 0
    // Handshake packet: First bit is 0/1, second bit is 1, third bit is 0/1
    // Transmission method: The host tx sends a handshake packet, after the slave rx recognizes it, perform memory read
    // Memory recognition: After the handshake packet transmission is completed, 9-bit target memory address, and 1-bit target memory type, and send a memory read request signal, if the data and instruction memory recognize that the enable signal is low and there is a memory read request, output the data of the corresponding target address to the slave tx
    // Data return: Return a handshake packet + four data packets, extract the 32-bit data inside and send it to the host rx, after completion set done high
    assign tx_ready = instr_mem_tx_data_ready || data_mem_tx_data_ready;
    wire [41:0] instr_uart_tx_data_out;
    wire [41:0] data_uart_tx_data_out;
    assign uart_tx_data_out = target_mem_type ? instr_uart_tx_data_out : data_uart_tx_data_out;
    // Instantiate uart_bytes_tx module
    UART_Bytes_TX #(
        .BYTE_COUNT(BYTE_NUM),       // Number of bytes to send
        .DATA_BITS(DATA_BITS)        // Number of data bits per byte
    ) mem_uart_tx_inst (
        .clk(clk),
        .reset(reset),
        .start(tx_ready),
        .data_in(uart_tx_data_out),
        .tx(uart_tx),
        .done(uart_tx_done)
    );
    
// =====================================
// =         IF Stage Instantiation    =
// ===================================== 
    
    // Instantiate PC (Program Counter)
    PC pc_inst 
    (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .pc_in(pc_in_if),
        .pc_out(pc_out_if)
    );
    
    // Instantiate PC input selection multiplexer
    mux2to1 #( .WIDTH(32) ) pc_mux_inst
    (
        .in0(pc_adder_out_if),    // First input signal
        .in1(pc_jump_addr),       // Second input signal
        .sel(PCSrc),              // Select signal
        .out(pc_in_if)            // Output signal
    );
    
    // Instantiate PC address adder
    adder pc_adder_inst
    (
        .a(pc_out_if),            // First input signal to the adder
        .b(32'h00000004),         // Second input signal to the adder, assuming increment by 4 each time
        .sum(pc_adder_out_if)     // Output signal of the adder
    );

    // Instantiate instruction memory
    Instruction_Memory #( .DEPTH(INSTR_MEM_DEPTH) ) instr_mem_inst
    (
        .clk(clk),                  // Clock signal
        .reset(reset),              // Reset signal
        .PCSrc(PCSrc),              // Branch select signal
        .pc(pc_out_if),             // PC input
        .instr(instr_mux_if),       // Instruction output
        .enable(enable),            // Enable signal
        .write_mem_req(write_mem_req), // Memory write request signal
        .target_mem_type(target_mem_type), // Target memory type
        .target_addr(target_addr),  // Target memory address
        .uart_rx_data_in(uart_rx_data_out), // UART data input
        .rw_flag(rw_flag),             // Read/Write flag
        .uart_tx_data_out(instr_uart_tx_data_out), // UART data output
        .instr_mem_tx_data_ready(instr_mem_tx_data_ready)
    );

    
    // Instantiate instruction flush multiplexer in IF stage
    mux2to1 #( .WIDTH(32) ) instr_mux_if_inst
    (
        .in0(instr_mux_if),           // Normal instruction
        .in1(32'h00000013),           // Bubble instruction (nop)
        .sel(Flush),
        .out(instr_if)                // Output instruction
    );
    
    // Instantiate pipeline register IF/ID
    pipeline_register #( .WIDTH(64) ) if_id_reg
    (
        .clk(clk),                // Clock signal
        .reset(reset),            // Reset signal
        .d({instr_if, pc_out_if}),// Combined input instruction and PC
        .q({instr_id, pc_id})     // Combined output instruction and PC
    );
    
// =====================================
// =         ID Stage Instantiation    =
// =====================================  
    
    // Instantiate register file
    Register_File reg_file_inst
    (
        .clk(clk),                // Clock signal
        .reset(reset),            // Reset signal
        .read_register1(read_register1_id), // rs1 address
        .read_register2(read_register2_id), // rs2 address
        .write_register(write_register), // rd address
        .write_data(write_data),   // Data to be written
        .RegWrite(RegWrite_wb),    // Write enable
        .read_data1(read_data1_mux_id),   // Data read from rs1
        .read_data2(read_data2_id)    // Data read from rs2
    );

    // Instantiate immediate generator
    Immediate_Generator imm_gen_inst
    (
        .instr(instr_id),          // Instruction input
        .imm(imm_id)               // Immediate output
    );
    
    // Instantiate control unit in ID stage
    Control_Unit control_unit_inst
    (
        .instr(instr_id),
        .ALUOp(ALUOp_mux_id),
        .ALUSrc(ALUSrc_mux_id),
        .Branch(Branch_mux_id),
        .MemRead(MemRead_mux_id),
        .MemWrite(MemWrite_mux_id),
        .RegWrite(RegWrite_mux_id),
        .MemtoReg(MemtoReg_mux_id),
        .Jump(Jump_mux_id),
        .JumpAddrSrc(JumpAddrSrc_mux_id),
        .ImmLoad(ImmLoad_reg_mux_id),
        .DataMemOutOp(DataMemOutOp_mux_id),
        .WriteBackRegSrc(WriteBackRegSrc_mux_id)
    );
    
    // Instantiate rs1 output control multiplexer in ID stage
    mux2to1 #( .WIDTH(32) ) read_data_1_mux_id_inst
    (
        .in0(read_data1_mux_id),
        .in1(32'b0),
        .sel(ImmLoad_reg_id),
        .out(read_data1_id)
    );
    
    // Instantiate control signal flush multiplexer in ID stage
    mux2to1 #( .WIDTH(15) ) control_mux_id_inst
    (
        .in0({ALUOp_mux_id, ALUSrc_mux_id, Branch_mux_id, MemRead_mux_id, MemWrite_mux_id, RegWrite_mux_id, MemtoReg_mux_id, Jump_mux_id, JumpAddrSrc_mux_id, DataMemOutOp_mux_id, ImmLoad_reg_mux_id, WriteBackRegSrc_mux_id}),
        .in1(15'b0),
        .sel(Flush),
        .out({ALUOp_id, ALUSrc_id, Branch_id, MemRead_id, MemWrite_id, RegWrite_id, MemtoReg_id, Jump_id, JumpAddrSrc_id, DataMemOutOp_id, ImmLoad_reg_id, WriteBackRegSrc_id})
    );
    
    
    // Instantiate pipeline register ID/EX
    pipeline_register #( .WIDTH(153+14) ) id_ex_reg
    (
        .clk(clk),                // Clock signal
        .reset(reset),            // Reset signal
        .d({pc_id, read_data1_id, read_data2_id, imm_id, funct_id, read_register1_id, read_register2_id, rd_id, ALUOp_id, ALUSrc_id, Branch_id, MemRead_id, MemWrite_id, RegWrite_id, MemtoReg_id, Jump_id, JumpAddrSrc_id, DataMemOutOp_id, WriteBackRegSrc_id}), // Combined input signals
        .q({pc_ex, read_data1_ex, read_data2_ex, imm_ex, funct_ex, read_register1_ex, read_register2_ex, rd_ex, ALUOp_mux_ex, ALUSrc_mux_ex, Branch_mux_ex, MemRead_mux_ex, MemWrite_mux_ex, RegWrite_mux_ex, MemtoReg_mux_ex, Jump_mux_ex, JumpAddrSrc_mux_ex, DataMemOutOp_mux_ex, WriteBackRegSrc_mux_ex})  // Combined output signals
     );
    
// =====================================
// =         EX Stage Instantiation    =
// =====================================  
    
    // Instantiate control signal flush multiplexer in EX stage
    mux2to1 #( .WIDTH(14) ) control_mux_ex_inst
    (
        .in0({ALUOp_mux_ex, ALUSrc_mux_ex, Branch_mux_ex, MemRead_mux_ex, MemWrite_mux_ex, RegWrite_mux_ex, MemtoReg_mux_ex, Jump_mux_ex, JumpAddrSrc_mux_ex, DataMemOutOp_mux_ex, WriteBackRegSrc_mux_ex}),
        .in1(14'b0),
        .sel(Flush),
        .out({ALUOp_ex, ALUSrc_ex, Branch_ex, MemRead_ex, MemWrite_ex, RegWrite_ex, MemtoReg_ex, Jump_ex, JumpAddrSrc_ex, DataMemOutOp_ex, WriteBackRegSrc_ex})
    );
   
    // Instantiate jump address source selection multiplexer in EX stage
    mux2to1 #( .WIDTH(32) ) jump_src_mux_ex_inst
    (
        .in0(pc_ex),
        .in1(alu_operand1_fwd_ex),
        .sel(JumpAddrSrc_ex),
        .out(jump_base_addr_ex)
    );
    
    // Instantiate jump address adder
    assign pc_minus_4_ex = JumpAddrSrc_ex ? jump_base_addr_ex : jump_base_addr_ex - 32'h00000004;
    adder jump_addr_adder_inst
    (
        .a(pc_minus_4_ex),          // First input signal to the adder
        .b(imm_ex),                // Second input signal to the adder
        .sum(jump_address_ex)      // Output signal of the adder
    );
    
    // Instantiate ALU operand A forwarding multiplexer
    mux3to1 #( .WIDTH(32) ) alu_operand1_fwd_mux_inst
    (
        .in0(read_data1_ex),       // First input signal (normal input)
        .in1(write_data),          // Second input signal (forwarded from MEM/WB)
        .in2(mem_data_mem),        // Third input signal (forwarded from EX/MEM)
        .sel(alu_operand1_sel_ex), // Select signal
        .out(alu_operand1_fwd_ex)  // Output signal
    );
    
    // Instantiate ALU operand B immediate selection multiplexer
    mux2to1 #( .WIDTH(32) ) alu_operand2_mux_inst
    (
        .in0(read_data2_ex),       // First input signal
        .in1(imm_ex),              // Second input signal
        .sel(ALUSrc_ex),           // Select signal
        .out(alu_operand2_ex)      // Output signal
    );
    
    // Instantiate ALU operand B forwarding multiplexer
    mux3to1 #( .WIDTH(32) ) alu_operand2_fwd_mux_inst
    (
        .in0(alu_operand2_ex),     // First input signal (normal input)
        .in1(write_data),          // Second input signal (forwarded from MEM/WB)
        .in2(mem_data_mem),        // Third input signal (forwarded from EX/MEM)
        .sel(alu_operand2_sel_ex), // Select signal
        .out(alu_operand2_fwd_ex)  // Output signal
    );

    // Instantiate ALU Control unit
    ALU_Control alu_control_inst
    (
        .ALUOp(ALUOp_ex),           // ALU operation control signal
        .funct(funct_ex),           // funct signal
        .alu_control(alu_control_ex) // ALU control signal
    );

    // Instantiate ALU
    ALU alu_inst
    (
        .a(alu_operand1_fwd_ex),    // First operand
        .b(alu_operand2_fwd_ex),    // Second operand
        .alu_control(alu_control_ex), // ALU control signal
        .result(alu_result_mux_ex), // Calculation result
        .zero(alu_zero_ex)          // ZERO signal
    );
    
   
    // Instantiate ALU output selection multiplexer
    mux2to1 #( .WIDTH(32) ) alu_output_mux_inst
    (
        .in0(alu_result_mux_ex),    // First input signal
        .in1(pc_ex),                // Second input signal
        .sel(Jump_ex),              // Select signal
        .out(alu_result_ex)         // Output signal
    );
    
    // Instantiate memory stage data source selection multiplexer
    mux2to1 #( .WIDTH(32) ) mem_data_src_mux_inst
    (
        .in0(alu_result_ex),        // First input signal
        .in1(jump_address_ex),      // Second input signal
        .sel(WriteBackRegSrc_ex),   // Select signal
        .out(mem_data_ex)           // Output signal
    );
    
    // Instantiate forwarding unit
    Forwarding_Unit forwarding_unit_inst 
    (
        .RegisterRs1(read_register1_ex), // rs1 register number in EX stage
        .RegisterRs2(read_register2_ex), // rs2 register number in EX stage
        .RegisterRd_ex_mem(rd_mem),      // Rd register number in EX/MEM stage
        .RegisterRd_mem_wb(write_register), // Rd register number in MEM/WB stage
        .RegWrite_ex_mem(RegWrite_mem),  // Register write enable signal in EX/MEM stage
        .RegWrite_mem_wb(RegWrite_wb),   // Register write enable signal in MEM/WB stage
        .MemWrite_ex(MemWrite_ex),       // Memory write signal in EX stage, indicating sw
        .ALUSrc(ALUSrc_ex),              // ALU source selection signal, determining whether to use immediate value
        .ForwardA(alu_operand1_sel_ex),  // Select signal for ALU input A
        .ForwardB(alu_operand2_sel_ex),  // Select signal for ALU input B
        .ForwardDataMemWriteData(data_mem_write_data_sel_ex) // Select signal for data input to data memory
    );
    
     // Instantiate Data Memory input data selection multiplexer
    mux3to1 #( .WIDTH(32) ) data_mem_write_data_mux_inst
    (
        .in0(read_data2_ex),        // First input signal (normal input)             
        .in1(write_data),           // Second input signal (forwarded from MEM/WB)    
        .in2(mem_data_mem),         // Third input signal (forwarded from EX/MEM)  
        .sel(data_mem_write_data_sel_ex), // Select signal
        .out(data_mem_write_data_ex) // Output signal
    );
    
    // Instantiate pipeline register EX/MEM
    pipeline_register #( .WIDTH(102+9) ) ex_mem_reg
    (
        .clk(clk),                // Clock signal
        .reset(reset),            // Reset signal
        .d({jump_address_ex, alu_zero_ex, mem_data_ex, data_mem_write_data_ex, rd_ex, Branch_ex, MemRead_ex, MemWrite_ex, RegWrite_ex, MemtoReg_ex, Jump_ex, DataMemOutOp_ex}), // Combined input signals
        .q({pc_jump_addr, alu_zero_mem, mem_data_mem, data_mem_write_data_mem, rd_mem, Branch_mem, MemRead_mem, MemWrite_mem, RegWrite_mem, MemtoReg_mem, Jump_mem, DataMemOutOp_mem}) // Combined output signals
    );
    
// =====================================
// =         MEM Stage Instantiation   =
// =====================================
    
    // Instantiate data memory
    Data_Memory #( .DEPTH(DATA_MEM_DEPTH) ) data_mem_inst
    (
        .clk(clk),                     // Clock signal
        .reset(reset),                 // Reset signal
        .address(mem_data_mem),        // Address input
        .write_data(processed_write_data_mem), // Data to be written
        .MemWrite(MemWrite_mem),       // Memory write enable signal
        .MemRead(MemRead_mem),         // Memory read enable signal
        .read_data(read_data_mem),     // Data read out
        .enable(enable),               // Enable signal
        .write_mem_req(write_mem_req), // Memory write request signal
        .target_mem_type(target_mem_type), // Target memory type
        .target_addr(target_addr),     // Target memory address
        .uart_rx_data_in(uart_rx_data_out), // UART data input
        .rw_flag(rw_flag),             // Read/Write flag
        .uart_tx_data_out(data_uart_tx_data_out), // UART data output
        .data_mem_tx_data_ready(data_mem_tx_data_ready),
		.data_mem0(data_mem0)
    );
    
    // Instantiate data memory handler
    Data_Memory_Handler data_mem_handler_inst
    (
        .DataMemOutOp(DataMemOutOp_mem), // Memory operation signal
        .MemRead(MemRead_mem),           // Memory read enable signal
        .MemWrite(MemWrite_mem),         // Memory write enable signal
        .mem_data_in(read_data_mem),     // Data read from memory
        .write_data_in(data_mem_write_data_mem), // Data to be written to memory
        .mem_data_out(processed_read_data_mem), // Processed data output
        .write_data_out(processed_write_data_mem) // Processed data input
    );
    
    // Calculate PCSrc & Flush signals
    assign PCSrc = Jump_mem || (Branch_mem & alu_zero_mem);
    assign Flush = PCSrc;
    
    // Instantiate pipeline register MEM/WB
    pipeline_register #( .WIDTH(69+2) ) mem_wb_reg
    (
        .clk(clk),                // Clock signal
        .reset(reset),            // Reset signal
        .d({processed_read_data_mem, mem_data_mem, rd_mem, RegWrite_mem, MemtoReg_mem}), // Combined input signals
        .q({read_data_wb, data_wb, write_register, RegWrite_wb, MemtoReg_wb})     // Combined output signals
    );
    
// =====================================
// =         WB Stage Instantiation    =
// =====================================
    
    // Instantiate MemtoReg multiplexer
    mux2to1 #( .WIDTH(32) ) memtoreg_mux_inst
    (
        .in0(data_wb),      // First input signal
        .in1(read_data_wb), // Second input signal
        .sel(MemtoReg_wb),  // Select signal
        .out(write_data)    // Output signal
    );

    // Other internal connections and logic
    // Add other parts of your processor architecture here

endmodule
