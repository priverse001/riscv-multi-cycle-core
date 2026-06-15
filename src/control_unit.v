`timescale 1ns / 1ps

module control_unit(clk ,rst ,
                     opcode , pc_write , adr_src,
                     mem_write , reg_write , ir_write,
                     result_src , alu_src_A , alu_src_B,
                     imm_src , alu_control,
                     zero_flag,
                     funct3,
                     funct7_5
                     );
                     
input clk , rst , funct7_5 , zero_flag;
input [6:0] opcode ;
input [2:0] funct3;
output reg pc_write , adr_src , mem_write , reg_write , ir_write;
output reg [1:0] result_src , alu_src_A , alu_src_B;
output reg [3:0] alu_control;
output reg [2:0] imm_src;


reg [3:0] current_state , next_state;


//FSM Encoding
localparam FETCH = 4'd0;
localparam DECODE = 4'd1;
localparam MEMORY_ADRESS = 4'd2;
localparam MEMORY_READ = 4'd3;
localparam MEMORY_WRITE_BACK = 4'd4;
localparam MEMORY_WRITE = 4'd5;
localparam EXECUTE = 4'd6;
localparam ALU_WRITE_BACK = 4'd7; 
localparam BRANCH = 4'd8;
localparam JUMP = 4'd9;

//opcode encodingns
localparam OP_LW    = 7'b0000011;
localparam OP_SW    = 7'b0100011;
localparam OP_RTYPE = 7'b0110011;
localparam OP_ITYPE = 7'b0010011;
localparam OP_BEQ   = 7'b1100011;
localparam OP_JAL   = 7'b1101111;

always @(posedge clk)
    begin 
        if(rst)
        current_state <= FETCH; 
        else 
        current_state <= next_state;
    end 

//Next State Logic
always @(*)
    begin
        case(current_state)
               
        FETCH :
            next_state = DECODE;
        DECODE :
            case(opcode)
            OP_LW : next_state = MEMORY_ADRESS;
            OP_SW : next_state = MEMORY_ADRESS;
            OP_RTYPE : next_state = EXECUTE;
            OP_ITYPE : next_state = EXECUTE;
            OP_BEQ : next_state = BRANCH;
            OP_JAL : next_state = JUMP;
            default : next_state = DECODE;
            endcase
            
        MEMORY_ADRESS:
            case(opcode)
            OP_LW : next_state = MEMORY_READ;
            OP_SW : next_state = MEMORY_WRITE;
            default : next_state = MEMORY_ADRESS;
            endcase
            
        MEMORY_READ:
            next_state = MEMORY_WRITE_BACK;
            
        MEMORY_WRITE_BACK:
            next_state = FETCH;
            
        MEMORY_WRITE: 
            next_state = FETCH;
            
        EXECUTE :
            next_state = ALU_WRITE_BACK;
            
        ALU_WRITE_BACK:
            next_state = FETCH;
            
        BRANCH:
            next_state = FETCH;
            
        JUMP:
            next_state = FETCH;
            
        default:
            next_state = FETCH;
                       
        endcase     
    end
    
 //Output Logic
 
 always @(*)
    begin
    
    pc_write    = 0;
    adr_src     = 0;
    mem_write   = 0;
    reg_write   = 0;
    ir_write    = 0;
    result_src  = 2'b00;
    alu_src_A   = 2'b00;
    alu_src_B   = 2'b00;
    alu_control = 4'b0000;
    
    //for initializing imm_src
    case(opcode)
        OP_LW, OP_ITYPE : imm_src = 3'b000; // I Type
        OP_SW           : imm_src = 3'b001; // S Type
        OP_BEQ          : imm_src = 3'b010; // B Type
        OP_JAL          : imm_src = 3'b100; // J Type 
        default         : imm_src = 3'b000;
    endcase
    
    case(current_state)
    
    FETCH : begin
        adr_src = 1'b0;
        ir_write = 1'b1;       //read pc and save to instr reg 
    
        alu_src_A = 2'b00;   // A = pc 
        alu_src_B = 2'b10;   // B = 4;
        alu_control = 4'b0010; //add  
        result_src = 2'b10;   // Mux selects ALU Result directly (bypasses ALUOut register)      
        pc_write = 1'b1;
        end
        
    DECODE : begin  //calc of branch address
        alu_src_A = 2'b01; //pc
        alu_src_B = 2'b01; //immediate
        alu_control = 4'b0010; //add  
        end 
        
    MEMORY_ADRESS : begin   
        alu_src_A = 2'b10; //regA 
        alu_src_B = 2'b01; //imm
        alu_control = 4'b0010; //add  
        end 
        
    MEMORY_READ : begin
        adr_src = 1'b1; //adress from alu
        end 
        
    MEMORY_WRITE_BACK : begin
        reg_write = 1'b1;
        result_src = 2'b01; //data from mem 
        end 
        
    MEMORY_WRITE : begin
        mem_write = 1'b1;
        adr_src = 1'b1; 
        end
        
    EXECUTE : begin
        alu_src_A = 2'b10;
        alu_src_B = (opcode == OP_RTYPE) ? 2'b00 : 2'b01; //imm for itype
        
        if (opcode == OP_RTYPE) begin
            case(funct3)
                3'b000: alu_control = (funct7_5) ? 4'b0110 : 4'b0010; // SUB if funct7_5 is 1, else ADD
                3'b111: alu_control = 4'b0000; // AND
                3'b110: alu_control = 4'b0001; // OR
                3'b001: alu_control = 4'b0100; // SLL (Shift Left Logical)
                3'b101: alu_control = (funct7_5) ? 4'b1001 : 4'b0101; // SRA if funct7_5 is 1, else SRL
                3'b010: alu_control = 4'b0111; // SLT (Set Less Than Signed)
                3'b011: alu_control = 4'b1000; // SLTU (Set Less Than Unsigned)
                3'b100: alu_control = 4'b0011; // XOR
                default: alu_control = 4'b0010;
            endcase
        end 
        else if (opcode == OP_ITYPE) begin
            case(funct3)
                3'b000: alu_control = 4'b0010; // ADDI
                3'b111: alu_control = 4'b0000; // ANDI
                3'b110: alu_control = 4'b0001; // ORI
                3'b001: alu_control = 4'b0100; // SLLI
                3'b101: alu_control = (funct7_5) ? 4'b1001 : 4'b0101; // SRAI / SRLI
                3'b010: alu_control = 4'b0111; // SLTI
                3'b011: alu_control = 4'b1000; // SLTIU
                3'b100: alu_control = 4'b0011; // XORI
                default: alu_control = 4'b0010;
            endcase
        end
        end
        
    ALU_WRITE_BACK : begin 
        result_src = 2'b00;
        reg_write = 1'b1;
        end
    
    BRANCH : begin 
        alu_src_A = 2'b10; //regA 
        alu_src_B = 2'b00; //regB 
        alu_control = 4'b0110; //sub 
        
        result_src = 2'b00; //aluOut reg ;
        if(zero_flag)
        pc_write = 1'b1;
        end 
    
    JUMP : begin
        result_src = 2'b00;
        reg_write = 1'b1;
        pc_write = 1'b1;
        end       
            
    endcase 
    end 
endmodule