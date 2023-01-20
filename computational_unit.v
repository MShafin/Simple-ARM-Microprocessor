module computational_unit(
	input clk, sync_reset,		
	input i_sel, y_sel, x_sel,							// iyx_mux_selects
	input [3:0] source_sel, nibble_ir, i_pins, dm,		// source_select, LS_nibble_ir, i_pins, dm
	input [8:0] reg_en,									// reg_enables

	input NOPC8, NOPCF, NOPD8, NOPDF,

	output reg r_eq_0,									// zero_flag
	output reg [3:0] o_reg, i, data_bus,				//o_reg, data_mem_addr, data_bus
	output reg [3:0] x0, x1, y0, y1, m, r,

	output reg [7:0] from_CU					
);

reg [3:0] pm_data; 										// 4 bit primary data

always @ (*)
	from_CU <= 8'H00;
	//from_CU <= {x1, x0};

always @ (*)
	pm_data <= nibble_ir;

// ************************** x0 ************************** 
always @ (posedge clk)
if (reg_en[0] == 1'b1)
	x0 <= data_bus;
else
	x0 <= x0;

// ************************** x1 ************************** 
always @ (posedge clk)
if (reg_en[1] == 1'b1)
	x1 <= data_bus;
else
	x1 <= x1;

// ************************** y0 **************************
always @ (posedge clk)
if (reg_en[2] == 1'b1)
	y0 <= data_bus;
else
	y0 <= y0;

// ************************** y1 **************************
always @ (posedge clk)
if (reg_en[3] == 1'b1)
	y1 <= data_bus;
else
	y1 <= y1;

// ************************** m **************************
always @ (posedge clk)
if (reg_en[5] == 1'b1)
	m <= data_bus;
else
	m <= m;

// ************************** i **************************
always @ (posedge clk)
if (reg_en[6] == 1'b1)
	if (i_sel == 1'b0) 
		i <= data_bus;
	else 
		i <= i + m;
else
	i <= i;

// ************************** o_reg **************************
always @ (posedge clk)
if (reg_en[8]==1'b1)
	o_reg <= data_bus;
else
	o_reg <= o_reg;

// ************************** data_bus **************************
always @ (*)
	case(source_sel)
	// data registers
		4'd00: data_bus <= x0;		
		4'b01: data_bus <= x1;		
		4'd02: data_bus <= y0;		
		4'd03: data_bus <= y1;	
	// result registers
		4'd04: data_bus <= r;
	// data registers
		4'd05: data_bus <= m;			
		4'd06: data_bus <= i;	
	// data memory input	
		4'd07: data_bus <= dm;		
		4'd08: data_bus <= pm_data;	
		4'd09: data_bus <= i_pins;	
		default: data_bus <= 4'h0;	
	endcase

// ************************** ALU instruction **************************
reg [2:0] alu_func;
reg [3:0] alu_out;  
reg [3:0] x, y;
reg [7:0] x_mul_y; 

always @ (*)
	alu_func <= nibble_ir[2:0];

always @ (*)
	if (x_sel == 1'b0) 
		x <= x0;
	else x <= x1;

always @ (*)
	if(y_sel == 1'b0)
		y <= y0;
	else y <= y1;

always @ (*)
	x_mul_y <= x * y;

always @ (*)
	if (sync_reset == 1'b1)
		alu_out <= 4'b0;				
	//2's compliment of x 
	else if ((alu_func == 3'b0) && (nibble_ir[3] == 1'b0))
		alu_out <= -x;			
	// r=x-y	
	else if (alu_func == 3'b001)
		alu_out <= x - y;		
	// r=x+y	
	else if (alu_func == 3'b010)
		alu_out <= x + y;		
	// r=x*y	
	else if (alu_func == 3'b011)
		alu_out <= x_mul_y[7:4];	
	else if (alu_func == 3'b100)
		alu_out <= x_mul_y[3:0];
	// r=x^y
	else if (alu_func == 3'b101)
		alu_out <= x ^ y;			
	// r=x&y	
	else if (alu_func == 3'b110)
		alu_out <= x & y;			
	// 1's compliment of x
	else if ((alu_func == 3'b111) && (nibble_ir[3] == 1'b0))
		alu_out <= ~x;					
	else if ((alu_func == 3'b000) && (nibble_ir[3] == 1'b1))
		alu_out <= r;		// NOP instr
	else if ((alu_func == 3'b111) && (nibble_ir[3] == 1'b1))
		alu_out <= r;		// NOP instr
	else
		alu_out <= r;


// ************************** r **************************
always @ (posedge clk)
	if (sync_reset == 1'b1)
		r <= 4'd0;
	else if (reg_en[4] == 1'b1)
		r <= alu_out;
	else
		r <= r;

always @ (posedge clk)
	if (sync_reset == 1'b1)
		r_eq_0 <= 1'b1;
	else if ((reg_en[4] == 1'b1) && (alu_out == 4'd0))
		r_eq_0 <= 1'b1;
	else if ((reg_en[4] == 1'b1) && (alu_out != 4'd0))
		r_eq_0 <= 1'b0;
	else
		r_eq_0 <= r_eq_0;

endmodule
