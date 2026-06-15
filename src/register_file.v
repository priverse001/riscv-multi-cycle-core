`timescale 1ns / 1ps


module register_file(
    write_en,clk,
    read_reg1,
    read_reg2 , 
    write_reg , 
    write_data , 
    read_data1 , 
    read_data2);
    
input write_en , clk;
input [4:0] read_reg1 , read_reg2 , write_reg; //5 bits enough for 32 bit addr
input [31:0] write_data;
output reg [31:0] read_data1 , read_data2 ;

reg [31:0] reg_data [31:0];

always @(*)
    begin
        read_data1 = (read_reg1 == 5'b0 )? 32'b0 : reg_data[read_reg1];
        read_data2 = (read_reg2 == 5'b0 )? 32'b0 : reg_data[read_reg2];
     end 
always @(posedge clk)
    begin
      if(write_en && (write_reg != 5'b0))
            begin
            reg_data[write_reg] <= write_data;
            end   
     
        
    end

endmodule
