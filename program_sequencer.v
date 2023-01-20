module program_sequencer(
	input clk, sync_reset,
	input jmp, jmp_nz, dont_jmp,
	input [3:0] jmp_addr,

	input NOPC8, NOPCF, NOPD8, NOPDF,		
	
	output reg [7:0] pm_addr, pc,
	output reg [7:0] from_PS			// made specifically for final exam scrambler
);

always @ *
	from_PS = 8'H00;  
	//from_PS = pc;  

// ************************** pc Instructions ************************** 
always @ (posedge clk)
	pc <= pm_addr;

// ************************** pm_addr Instructions ************************** 
always @ (*)
	if (sync_reset == 1'd1)
		pm_addr = 8'H00;
	else if (jmp == 1'd1)
		pm_addr = { jmp_addr, 4'H0 };
	else if (jmp_nz == 1'd1 && dont_jmp == 1'd0)
		pm_addr = { jmp_addr, 4'H0 };
	else
		pm_addr = pc+ 8'H01;

endmodule
