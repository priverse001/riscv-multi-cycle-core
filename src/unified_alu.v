`timescale 1ns / 1ps

module unified_alu(alu_control , A , B , alu_result ,
                    zero_flag);

input [3:0] alu_control;
input [31:0] A;
input [31:0] B;
output reg [31:0] alu_result;
output reg zero_flag;

always @(*) //alu is always combinational
    begin 
        case(alu_control)
        4'b0000 : alu_result = A & B;   //AND
        4'b0001 : alu_result = A | B;   //Or
        4'b0010 : alu_result = A + B;   //ADD
        4'b0011 : alu_result = A ^ B;   //XOR
        4'b0100 : alu_result = A << B[4:0]; //Shift Left Logical 
        4'b0101 : alu_result = A >> B[4:0]; //Shift Right Logical
        4'b0110 : alu_result = A - B;   //Subtraction 
        4'b0111 : alu_result = $signed(A) < $signed(B); //Set Less Than (Signed) 
        4'b1000 : alu_result = A < B;   //Set Less Than Unsigned
        4'b1001 : alu_result = $signed(A) >>> B[4:0];   //Shift Right Arithmetic 
        
        default : alu_result = A + B;
        endcase
        
        if(alu_result == 32'b0)begin
            zero_flag = 1; end
        else
            zero_flag = 0;
    end
    
endmodule
