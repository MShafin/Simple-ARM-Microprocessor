module instruction_decoder(
	input [7:0] next_instr, 		// the next instruction
	input clk, sync_reset, 			// the clock the syncronous reset
	output reg [3:0] ir_nibble,			// the instruction register nibble 
	output reg [8:0] reg_en, 			// the register enable
	output reg [3:0] source_sel, 		// the source select
	output reg i_sel, x_sel, y_sel, 	// the i, x, y select
	output reg jmp, jmp_nz, 			// the jump and conditional jump

	output reg [7:0] ir,				// made an output for exam (was internal before)
	output reg [7:0] from_ID,			// made for final exam scrambler
	output reg NOPC8, NOPCF, NOPD8, NOPDF	// made for final exam scrambler
);

always @ (*)
	from_ID = 8'H00;				// during exam
	//from_ID = reg_en[7:0]; 			// for debugging prior to exam (reg_en[8] is for o_reg)

// ************************** NOP Instructions ************************** 
// Flags for if NOP instruction detected
always @ (*)
	if (ir == 8'hC8)
		NOPC8 <= 1'b1;
	else
		NOPC8 <= 1'b0;

always @ (*)	
	if (ir == 8'hCF)
		NOPCF <= 1'b1;
	else
		NOPCF <= 1'b0;

always @ (*)
	if (ir == 8'hD8)
		NOPD8 <= 1'b1;
	else
		NOPD8 <= 1'b0;
	
always @ (*)
	if (ir == 8'hDF)
		NOPDF <= 1'b1;
	else
		NOPDF <= 1'b0;

// ************************** load instruction register ************************** 
// syncronously sets the value of the instruction register as the next instruction
always @ (posedge clk)
	ir <= next_instr;

// ************************** instruction register nibble ************************** 
always @ (*)
	ir_nibble <= ir[3:0]; // the least significant bits of the instruction register
	
// ************************** jump ************************** 
always @ (*)
	if (sync_reset == 1'b1) // set jump as 0 if sync reset is active 
		jmp <= 1'b0; 
	else if (ir[7:4] == 4'b1110) // conditions to set jump as 1
		jmp <= 1'b1;
	else // anything else will set jump as 0
		jmp <= 1'b0;

// ************************** conditional jump ************************** 
always @ (*)
	if (sync_reset == 1'b1) // set conditional jump as 0 if sync reset is active 
		jmp_nz <= 1'b0; 
	else if (ir[7:4] == 4'b1111) // conditions to set conditional jump as 1
		jmp_nz <= 1'b1;
	else // anything else will set conditional jump as 0
		jmp_nz <= 1'b0;
		

// ************************** i Select ************************** 
always @ (*)
	if (sync_reset == 1'b1) // set i_sel as 0 if sync reset is active 
		i_sel <= 1'b0;
	else if ((ir[7:4] == 4'b0110) || (ir[7:3] == 5'b10110)) // conditions to set i_sel as 0 
	// if theres a destination register involved
		i_sel <= 1'b0;
	else // anything else will set i_sel as 1
		i_sel <= 1'b1;

// ************************** x Select ************************** 
always @ (*)
	if (sync_reset == 1'b1)
		x_sel <= 1'b0;
	else
		x_sel <= ir[4];

// ************************** y Select ************************** 
always @ (*)
	if (sync_reset == 1'b1)
		y_sel <= 1'b0;
	else
		y_sel <= ir[3];

// ************************** Source Select ************************** 
always @ (*)
	if (sync_reset == 1'b1) 
		source_sel = 4'd10;
	else if (ir[7] == 1'b0)
		//	load; data_bus = ir_nibble 
		source_sel = 4'd8;
	else if ( (ir[7:6] == 2'b10) && (ir[5:3] == ir[2:0]) && (ir[2:0] == 3'd4) )
		// mov; data_bus = r (moving to o_reg)
		source_sel = 4'd4;
	else if ( (ir[7:6] == 2'b10) && (ir[5:3] == ir[2:0]) )
		// mov; data_bus = i_pins
		source_sel = 4'd9;
	else if ( (ir[7:6] == 2'b10) )
		// mov; data_bus = src (0-7, data registers)
		source_sel = {1'b0, ir[2:0]};  // concat, to make 4-bit
	else
		source_sel = {1'b0, ir[2:0]};

// ************************** Register Enables ************************** 
// for x0 enable
always @ (*)
	if (sync_reset == 1'b1)
		reg_en[0] <= 1'b1;
	else if (ir[7:4] == 4'b0000) // load to x0
		reg_en[0] <= 1'b1;
	else if (ir[7:3] == 5'b10000) // move to x0
		reg_en[0] <= 1'b1;
	else
		reg_en[0] <= 1'b0;

// for x1 enable
always @ (*)
   if (sync_reset == 1'b1)
		reg_en[1] <= 1'b1;
	else if (ir[7:4] == 4'b0001) // load to x1
		reg_en[1] <= 1'b1;
	else if (ir[7:3] == 5'b10001) // move to x1
		reg_en[1] <= 1'b1;
	else
		reg_en[1] <= 1'b0;	

// for y0 enable
always @ (*)
	if (sync_reset == 1'b1)
		reg_en[2] <= 1'b1;
	else if (ir[7:4] == 4'b0010) // load to y0
		reg_en[2] <= 1'b1;
	else if (ir[7:3] == 5'b10010) // move to y0
		reg_en[2] <= 1'b1;
	else
		reg_en[2] <= 1'b0;	

// for y1 enable
always @ (*)
	if (sync_reset == 1'b1)
		reg_en[3] <= 1'b1;
	else if (ir[7:4] == 4'b0011) // load to y1
		reg_en[3] <= 1'b1;
	else if (ir[7:3] == 5'b10011) // move to y1
		reg_en[3] <= 1'b1;
	else
		reg_en[3] <= 1'b0;	

// for r enable
always @ (*)
	if (sync_reset == 1'b1)
		reg_en[4] <= 1'b1;
	else if (ir[7:5] == 3'b110) // ALU logic
		reg_en[4] <= 1'b1;
	else
		reg_en[4] <= 1'b0;	

// for m enable
always @ (*)
	if (sync_reset == 1'b1)
		reg_en[5] <= 1'b1;
	else if (ir[7:4] == 4'b0101) // load to m
		reg_en[5] <= 1'b1;
	else if (ir[7:3] == 5'b10101) // move to m
		reg_en[5] <= 1'b1;
	else
		reg_en[5] <= 1'b0;	

// for i enable
always @ (*)
	if (sync_reset == 1'b1)
		reg_en[6] <= 1'b1;
	else if (ir[7:4] == 4'b0110) // load to i
		reg_en[6] <= 1'b1;
	else if (ir[7:3] == 5'b10110) // move to i
		reg_en[6] <= 1'b1;
	else if (ir[7:4] == 4'b0111) // load to dm
		reg_en[6] <= 1'b1;
	else if (ir[7:3] == 5'b10111) // move to dm
		reg_en[6] <= 1'b1;	
	else if ((ir[7:6] == 2'b10) && (ir[2:0] == 3'b111)) // move instruction where dm is source
		reg_en[6] <= 1'b1;
	else
		reg_en[6] <= 1'b0;	

// for dm enable
always @ (*)
	if (sync_reset == 1'b1)
		reg_en[7] <= 1'b1;
	else if (ir[7:4] == 4'b0111) // load to dm
		reg_en[7] <= 1'b1;
	else if (ir[7:3] == 5'b10111) // move to dm
		reg_en[7] <= 1'b1;
	else
		reg_en[7] <= 1'b0;	

// for o_reg enable
always @ (*)
	if (sync_reset == 1'b1)
		reg_en[8] <= 1'b1;
	else if (ir[7:4] == 4'b0100) // load to o_reg
		reg_en[8] <= 1'b1;
	else if (ir[7:3] == 5'b10100) // move to o_reg
		reg_en[8] <= 1'b1;
	else
		reg_en[8] <= 1'b0;	
		
endmodule
