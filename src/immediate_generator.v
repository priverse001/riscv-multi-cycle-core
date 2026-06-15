`timescale 1ns / 1ps

module immediate_generator(
    imm_src , 
    instr,
    imm_ext);
    
input [31:0] instr;
input [2:0] imm_src; // I Used Control Unit based approach instead of Opcode based!
// 0 for I-Type 
// 1 for S-Type 
// 2 for B-Type 
// 3 for U-Type 
// 4 for J-Type 
output reg [31:0] imm_ext;

always @(*)
    begin
        case(imm_src)
        3'b000 : imm_ext = {{20{instr[31]}} , instr[31:20]};
        3'b001 : imm_ext = {{20{instr[31]}} , instr[31:25] , instr[11:7]};
        3'b010 : imm_ext = {{19{instr[31]}} , instr[31] , instr[7] , instr[30:25] ,instr[11:8], 1'b0};
        3'b011 : imm_ext = {instr[31:12] , {12{1'b0}}};
        3'b100 : imm_ext = {{11{instr[31]}} , instr[31] , instr[19:12] , instr[20] , instr[30:21] , 1'b0};
        default : imm_ext = 32'b0;
        endcase
    end
    

endmodule
