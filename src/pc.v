`timescale 1ns / 1ps

module pc(clk , rst , pc_next , pc_out , pc_write);
input clk,rst,pc_write;
input [31:0] pc_next;
output reg [31:0] pc_out;

always @(posedge clk)
    begin
        if(rst) begin
            pc_out <= 0;
            end
        else if(pc_write) begin   
        pc_out <= pc_next;
        end
    end
    endmodule        
            
