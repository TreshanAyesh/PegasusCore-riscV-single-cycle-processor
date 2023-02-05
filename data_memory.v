/*
Data Memory
            args:
                inputs : ALU_result(32bit),
                         clk(1bit),
                         MemWrite(1bit) --> Control Signal
                outputs: WriteData (32bit),
                         ReadData (32bit)

The Data Memory is has 64, 32bit memory locations
word align ?????
*/

module data_memory(ALU_result,clk,MemWrite,WriteData,ReadData);
    input [31:0] ALU_result,WriteData;
    input clk,MemWrite;
    output [31:0] ReadData;

    reg [31:0] DMemory [63:0];      // 64 memory locations of 32bit length

    assign ReadData = DMemory[ALU_result];  
    //word align???
    //assign ReadData = DMemory[ALU_result[31:2]];  

    //always_ff??
	 always @(posedge clk)    //on rising edge, when (MemWrite == 1)
        if(MemWrite)
            DMemory[ALU_result] <= WriteData;
            //word align??
            //DMemory[ALU_result[31:2]] <= WriteData;

endmodule