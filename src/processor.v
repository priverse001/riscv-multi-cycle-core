`timescale 1ns / 1ps


module processor( input clk,
        input rst,
        output [31:0] test_out );
        
//Wires for Program counter 
wire [31:0] pc_next;
wire [31:0] pc_out;

//address mux wire for memory 
wire [31:0] address;

//Wires for Register File 
wire [31:0] read_data1;
wire [31:0] read_data2;
//write_data_back is the result wire in instantiation

//Wires for Extend Immediate 
wire [31:0] imm_ext;

//Wires for ALU module 
reg [31:0] src_a;
reg [31:0] src_b;
wire [31:0] alu_result;
wire zero_flag;

//Wires for control Unit
wire pc_write; 
wire adr_src;
wire ir_write;  
wire reg_write;
wire [1:0] alu_src_A;
wire [1:0] alu_src_B;
wire mem_write;
wire mem_read;
wire [1:0] result_src;
wire [3:0] alu_control;
wire [2:0] imm_src;

//wire for result
reg [31:0] result;

//wire for unified mem output  
wire [31:0] read_data;
    
//registers after each stage 

reg [31:0] old_pc;
reg [31:0] instr;

reg [31:0] data;

reg [31:0] reg_A;
reg [31:0] reg_B;

reg [31:0] alu_out;

//logic for storing in state registers 

always @(posedge clk) begin
    if (rst) begin
        old_pc  <= 32'b0;
        instr   <= 32'b0;
        data    <= 32'b0;
        reg_A   <= 32'b0;
        reg_B   <= 32'b0;
        alu_out <= 32'b0;
        end 
    else begin
        if (ir_write) begin
            instr  <= read_data; // Get instruction from memory
            old_pc <= pc_out;    // Save PC address for branch calculation
        end
        data    <= read_data;    // Load data from memory
        reg_A   <= read_data1;   // Latch Register File output rs1
        reg_B   <= read_data2;   // Latch Register File output rs2
        alu_out <= alu_result;   // Latch ALU output
    end
end

//Muxes 
//1.Adress mux 
    assign address = adr_src ? result : pc_out;
//2.Mux for alu_src_A
    always @(*) begin
    case(alu_src_A)
    2'b00 : src_a = pc_out;
    2'b01 : src_a = old_pc;
    2'b10 : src_a = reg_A;
    2'b11 : src_a = 32'b0;
    endcase
    end
//3.Mux for alu_src_B 
    always @(*) begin
    case(alu_src_B)
    2'b00 : src_b = reg_B;
    2'b01 : src_b = imm_ext;
    2'b10 : src_b = 32'd4;
    2'b11 : src_b = 32'b0;
    endcase
    end
//4.Mux for Result 
    always @(*) begin 
    case(result_src)
    2'b00 : result = alu_out;
    2'b01 : result = data; //data register after memory
    2'b10 : result = alu_result;
    2'b11 : result = 32'b0;
    endcase
    end

//for JAL
assign pc_next = (instr[6:0] == 7'b1101111) ? alu_out : result;

//Program Counter Instantiation
pc pc_inst (
    .clk(clk),
    .rst(rst),
    .pc_write(pc_write),
    .pc_next(pc_next), 
    .pc_out(pc_out)
);


    // Control Unit 
control_unit control_unit_inst (
    .clk(clk),
    .rst(rst),
    .opcode(instr[6:0]),
    .funct3(instr[14:12]),
    .funct7_5(instr[30]),
    .zero_flag(zero_flag),
    .pc_write(pc_write),
    .adr_src(adr_src),
    .mem_write(mem_write),
    .reg_write(reg_write),
    .ir_write(ir_write),
    .result_src(result_src),
    .alu_src_A(alu_src_A),
    .alu_src_B(alu_src_B),
    .imm_src(imm_src),
    .alu_control(alu_control)
);
    // Register File
register_file reg_file_inst (
    .write_en(reg_write),
    .clk(clk),
    .read_reg1(instr[19:15]),
    .read_reg2(instr[24:20]),
    .write_reg(instr[11:7]),
    .write_data(result),
    .read_data1(read_data1),
    .read_data2(read_data2)
);
    // Immediate Generator
immediate_generator imm_gen_inst (
    .imm_src(imm_src),
    .instr(instr),
    .imm_ext(imm_ext)
);
    // Arithmetic Logic Unit (ALU)
unified_alu alu_inst (
    .alu_control(alu_control),
    .A(src_a),
    .B(src_b),
    .alu_result(alu_result),
    .zero_flag(zero_flag)
);

unified_memory #(
    .DEPTH(128*4)
) mem_inst (
    .clk(clk),
    .rst(rst),
    .address(address),
    .write_enable(mem_write),
    .write_data(reg_B),
    .read_data(read_data)
);

assign test_out = pc_out;

endmodule

