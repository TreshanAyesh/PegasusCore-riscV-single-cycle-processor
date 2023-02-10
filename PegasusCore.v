module PegasusCore(
	input clk,
	input reset,
	output reg [31:0] instr, //stores the current progam counter value
	output reg [31:0] pc,    //program counter 
	output     [31:0] x31
);
	reg  [3:0]  we;         //write enable
	reg         wer;        //write enable register
	wire [31:0] regdata_R, regdata_I;
	wire [31:0] regdata_L, instr_val;
	wire [3:0]  we_S;
	wire [31:0] instruc;   // instruction from instruction memory
	reg  [31:0] daddr;  // address to data memory
	wire [31:0] drdata;  // data read from data memory reg [31:0] dwdata, // data to be written to data memory reg [4:0] rd,rs1,rs2, reg signed [31:0] imm,
	wire [31:0] rv1, rv2;
	reg  [31:0] regdata;
	reg  [31:0] dwdata; // data to be written to data memory
	reg  [4:0]  rd,rs1,rs2;
	reg signed [31:0] imm;
	reg zero_flag;
	wire [3:0] alu_control;

	wire [31:0] in_a, in_b;
	reg  [31:0] alu_out;
	

    always@(posedge clk)
    begin
        if(reset)       //set the program counter to be zero
            instr = 0;
			zero_flag = 0;
        else
            instr = pc;
    end 

    //Instantiating Imem, dmem and reg file
    imem im2(.instr(instr), .idata(instruc));
    dmem d1(clk,daddr,dwdata,we,drdata);
    regfile reg1(clk,rs1,rs2,rd,regdata,wer,rv1,rv2,x31);
	 
    always@(*)     
    begin
			
		//checking the opcode for type of instruction
        case(instruc[6:0])
		  
			//R type instructions
            7'b0110011:      
            begin
                rd = instruc[11:7];    //write register
                rs1 = instruc[19:15];  //source register 1
                rs2 = instruc[24:20];  //source register 2
                wer = 1;               //write enabled to regiters
				we = 4'b0;
                alu_control = {instruc[30],instruc[14:12]}; // alu control sognals
                in_a = rv1;
				in_b = rv2;
				regdata = alu_out; //data to be written to registers
				pc = instr+4;

            end
				
			//I type instructions
            7'b0010011:     
            begin
                rd = instruc[11:7];
                rs1 = instruc[19:15]; 
                imm = {{20{instruc[31]}},instruc[31:20]};//sign extending immediate to 32bits   
                wer=1;
				we = 4'b0;
				alu_control= {1'b0,instruc[14:12]};
				if ((alu_control == 4'b0101) and (instruc[30] == 1'b1)) //for srai instruction
					alu_control = 4'b1101;
					
				in_a = rv1;
				in_b = imm;			
                regdata = alu_out;
				pc = instr+4;
            end
				
			
			
			//Load instructions (encoded as I type instructions)
			7'b0000011:     
            begin
                rd = instruc[11:7];
                rs1 = instruc[19:15]; 
                imm = {{20{instruc[31]}},instruc[31:20]};
                wer=1;
                we=4'b0;
				alu_control = 4'b0000;
				in_a = rv1;
				in_b = imm;
				daddr = alu_out;       //memory address
                regdata = regdata_L;   //data to be written to rd
				pc = instr+4;
            end
				
				
			//S type instructions
            7'b0100011:     
            begin
                rs1 = instruc[19:15];
                rs2 = instruc[24:20];
                imm = {{20{instruc[31]}},instruc[31:25],instruc[11:7]};
                wer=0;
				alu_control = 4'b0000;
				in_a = rv1;
				in_b = imm;
                daddr = alu_out;   //adding imm and base register 

				case(instruc[14:12])
				3'b000: dwdata = {rv2[7:0],rv2[7:0],rv2[7:0],rv2[7:0]}; //sb
				3'b001: dwdata = {rv2[15:0],rv2[15:0]};                 //sh
				3'b010: dwdata = rv2;                                   //sw
				endcase
				we = we_S;
				pc = instr+4;
            end
				
			7'b1100011:		//B type instructions
			begin
				rs1 = instruc[19:15];
				rs2 = instruc[24:20];
				imm = {{19{instruc[31]}},instruc[31],instruc[7],instruc[30:25],instruc[11:8],1'b0};
				wer=0;
				we=4'b0;
				pc = instr_val;
			end
			
			7'b1100111:		//JALR instruction
			begin
				rs1 = instruc[19:15];
				rd = instruc[11:7];
				imm = {{20{instruc[31]}},instruc[31:20]};
				wer = 1;
				we = 4'b0;
				regdata = instr+4;
				pc = (rv1+imm)&32'hfffffffe;
			end
			7'b1101111:		//JAL instruction
			begin
				rd = instruc[11:7];
				imm = {{11{instruc[31]}},instruc[31],instruc[19:12],instruc[20],instruc[30:21],1'b0};
				pc = (instr+imm);
				wer = 1;
				we = 4'b0;
				regdata = instr+4;
			end
			7'b0010111:		//AUIPC
			begin
				rd = instruc[11:7];
				imm = {instruc[31:12],12'b0};
				wer = 1;
				we = 4'b0;
				regdata = instr+imm;
				pc = instr+4;
			end
			7'b0110111:		//LUI
			begin
				rd = instruc[11:7];
				imm = {instruc[31:12],12'b0};
				wer=1;
				we=4'b0;
				regdata = imm;
				pc = instr+4;
			end
			endcase
    end

	 
	 
	 
	 
    //Instantiating modules from the computational block
	alu ins1(.in_a(in_a), .in_b(in_b), .control(alu_control), .alu_out(alu_out), .zero(zero_flag));
	Loads l1(.instr(instruc),.drdata(drdata), .out(regdata_L)); 
	 
	 
	 
	 
	 
//    R_type r1(idata,rv1,rv2,regdata_R);
//    I_type i1(idata,rv1,imm,regdata_I);
//    L_type l1(idata, daddr, drdata, regdata_L);
//    S_type s1(idata,daddr,we_S);
//	B_type b1(idata, instr, imm, rv1, rv2, instr_val);
	
endmodule
	