/*
Instruction Memory
            args:
                inputs : read_addr(32bit) and reset(1bit)
                outputs : instruction (32bit)

The instruction Memory is has 64, 32bit memory locations
Instructions need to be manually written (can be improved to take instructions from a file) 
*/


module instruction_memory(read_addr,reset,instruction);
    input [31:0] read_addr;   ///////////////// Change this according to the instruction count used
    input reset;                    //reset=1 Ins memory is initialized, reset=0 Read Ins memory
    output [31:0] instruction;      // 32 bit instructions

    reg [31:0] IMemory [63:0];      // 64 memory locations of 32bit length

    /// Memory in this case is addressed by word, not by byte
    assign instruction = IMemory[read_addr];

    always @(reset)
    begin
        if(reset == 1)       // Initializing Memory
        begin
            /* 
            Add the instructions here
            format:
                IMemory[0] = 32'b00100000000010000000000000100000;
                IMemory[1] = 32'b00100000000010010000000000110111; 

            */
            IMemory[0] = 32'b00100000000010000000000000100000;

        end
    end
endmodule