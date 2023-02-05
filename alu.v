// 32-bit alu
// data input width: 2 32-bit
// data output width: 1 32-bit and one "zero" output
// control: 4-bit
// zero: output 1 if all bits of data output is 0
`timescale 1ns/1ps

module alu (input [31:0] in_a,input [31:0] in_b, input [3:0] control, output reg [31:0] alu_out, output reg zero);
	always @ (control or in_a or in_b)
	begin
		case (control)
		4'b0000: zero = 0; alu_out = in_a+in_b;     	                           // A ADD B
		4'b1000: if(in_a==in_b) zero = 1; else zero = 0; alu_out = in_a-in_b; end  // A SUB B
		4'b0001: zero = 0; alu_out = in_a << in_b[4:0];                  //sll of rs1 by the shift amount held in the lower 5 bits of register rs2
		4'b0010: zero = 0; alu_out = ($signed(in_a)<$signed(in_b))?1:0; // Set Less Than Signed  (slt)
		4'b0011: zero = 0; alu_out = (in_a<in_b)?1:0;   		          //Set Less Than Unsigned (sltu)
		4'b0100: zero = 0; alu_out = in_a ^ in_b;                               //xor
		4'b0101: zero = 0; alu_out = in_a>>in_b[4:0]; 								   // Shift Right Logical
		4'b1101: zero = 0; alu_out = $signed(in_a)>>>in_b[4:0]; 		            // Shift Right Arithmetic
		4'b0110: zero = 0; alu_out = in_a|in_b; 		       						   // A OR B		
		4'b0111: zero = 0; alu_out = in_a&in_b; 										   // A AND B
		
		default: zero = 0; alu_out = in_a; 
		endcase
	end
endmodule