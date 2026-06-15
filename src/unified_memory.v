`timescale 1ns / 1ps


module unified_memory#(
        parameter DEPTH = 128*4)
        (clk , 
        rst , 
        read_data ,
        write_data ,
        address,
        write_enable);

input clk , rst , write_enable;
input [31:0] write_data;
output reg [31:0] read_data;
input [31:0] address;

reg [7:0] mem_content [0: DEPTH -1];

initial begin
    $readmemh("memory_content.hex" , mem_content);
    end

always @(posedge clk)
    begin
        if(write_enable)
            begin
                   mem_content[address+3] <= write_data[31:24];
                   mem_content[address+2] <= write_data[23:16];
                   mem_content[address+1] <= write_data[15:8];
                   mem_content[address]  <= write_data[7:0];
            end
            read_data <= {mem_content[address+3] ,
                           mem_content[address+2] ,
                           mem_content[address+1] ,
                           mem_content[address]} ;
     end   
        

endmodule
