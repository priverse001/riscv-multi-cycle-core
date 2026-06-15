`timescale 1ns / 1ps


module tb_processor();

reg clk;
reg rst;
integer cycle_count; // To track clock cycles

//DUT instantiation 
processor DUT(
    .clk(clk),
    .rst(rst)
    );

always #5 clk = ~clk; //1ns tp -> 100mhz  

// Latch cycle count on posedge clk
always @(posedge clk) begin
    if (rst)
        cycle_count <= 0;
    else
        cycle_count <= cycle_count + 1;
end

//initial reset for clearing 
initial begin 
    clk = 0;
    rst = 1;
    #12 rst = 0;
    
    #800 //800ns simulation time for multi-cycle execution
    $display("Simulation Complete");
    
    //Correctness Check 
    $display(" CORRECTNESS CHECK ");

if(DUT.reg_file_inst.reg_data[1] == -5 &&
    DUT.reg_file_inst.reg_data[2] == 5 &&
    DUT.reg_file_inst.reg_data[3] == 0 &&
    DUT.reg_file_inst.reg_data[4] == 10 &&
    DUT.reg_file_inst.reg_data[5] == 1 &&
    DUT.reg_file_inst.reg_data[6] == 0 &&
    DUT.reg_file_inst.reg_data[7] == 160 &&
    DUT.reg_file_inst.reg_data[8] == 5 &&
    DUT.reg_file_inst.reg_data[9] == -1 &&
    DUT.reg_file_inst.reg_data[10] == 10 &&
    DUT.reg_file_inst.reg_data[11] == 77 &&
    {DUT.mem_inst.mem_content[3] , 
        DUT.mem_inst.mem_content[2], 
        DUT.mem_inst.mem_content[1], 
        DUT.mem_inst.mem_content[0]} == 10) begin 
        
        $display(" All Instructions Successfull");
        end
        
    
 if (DUT.reg_file_inst.reg_data[1] != -5)
                $display("addi negative Unsuccessful: Expected -5, got %d", DUT.reg_file_inst.reg_data[1]);
            else
                $display("addi negative Successful");    
        
 if (DUT.reg_file_inst.reg_data[2] != 5)
                $display("addi positive Unsuccessful: Expected 5, got %d", DUT.reg_file_inst.reg_data[2]);
            else
                $display("addi positive Successful");

 if (DUT.reg_file_inst.reg_data[3] != 0)
                $display("add Unsuccessful: Expected 0, got %d", DUT.reg_file_inst.reg_data[3]);
            else
                $display("add Successful");
                
if (DUT.reg_file_inst.reg_data[4] != 10)
                $display("sub Unsuccessful: Expected 10, got %d", DUT.reg_file_inst.reg_data[4]);
            else
                $display("sub Successful");          

if (DUT.reg_file_inst.reg_data[5] != 1)
                $display("slt (signed) Unsuccessful: Expected 1, got %d", DUT.reg_file_inst.reg_data[5]);
            else
                $display("slt (signed) Successful");

if (DUT.reg_file_inst.reg_data[6] != 0)
                $display("sltu (unsigned) Unsuccessful: Expected 0, got %d", DUT.reg_file_inst.reg_data[6]);
            else
                $display("sltu (unsigned) Successful");

if (DUT.reg_file_inst.reg_data[7] != 160)
                $display("sll Unsuccessful: Expected 160, got %d", DUT.reg_file_inst.reg_data[7]);
            else
                $display("sll Successful");

if (DUT.reg_file_inst.reg_data[8] != 5)
                $display("srl Unsuccessful: Expected 5, got %d", DUT.reg_file_inst.reg_data[8]);
            else
                $display("srl Successful");

if (DUT.reg_file_inst.reg_data[9] != -1)
                $display("sra Unsuccessful: Expected -1, got %d", DUT.reg_file_inst.reg_data[9]);
            else
                $display("sra Successful");

if ({DUT.mem_inst.mem_content[3], 
        DUT.mem_inst.mem_content[2], 
        DUT.mem_inst.mem_content[1], 
        DUT.mem_inst.mem_content[0]} != 10)
                $display("sw Unsuccessful: Expected 10, got %d", {DUT.mem_inst.mem_content[3], DUT.mem_inst.mem_content[2], DUT.mem_inst.mem_content[1], DUT.mem_inst.mem_content[0]});
            else
                $display("sw Successful");

if (DUT.reg_file_inst.reg_data[10] != 10)
                $display("lw/branch Unsuccessful: Expected 10 (branch skipped addi x10, 99 and addi x10, 88), got %d", DUT.reg_file_inst.reg_data[10]);
            else
                $display("lw and branch/jump Successful");

if (DUT.reg_file_inst.reg_data[11] != 77)
                $display("End of execution Unsuccessful: Expected 77, got %d", DUT.reg_file_inst.reg_data[11]);
            else
                $display("End of execution Successful");
    
    $display("Total cycles taken: %d", cycle_count);
    $finish;
    end
    
//logger 

always @(negedge clk) begin 
    if(!rst) begin
        $display("Time :%t , PC : %h , Instr: %h",
                    
                    $time,
                    DUT.pc_out,
                    DUT.instr);
              end
          end    
    


endmodule             
