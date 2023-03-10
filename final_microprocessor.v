module final_microprocessor (
	input clk, reset,
	input [3:0] i_pins,
	output [3:0] o_reg,
	output [7:0] pm_data,
	output [7:0] pc, ir, pm_address,
	output [7:0] from_PS, from_ID,
	output NOPC8, NOPCF, NOPD8, NOPDF,
	output [8:0] register_enables,
	output [7:0] from_CU,
	output [3:0] x0, x1, y0, y1, r, m, i,
	
	output reg f1, f2, f3, //flags
	output reg interrupt,
	
	output zero_flag,
	output [3:0] LS_nibble_ir, source_select, data_mem_addr, data_bus, dm 
);

	wire jump, conditional_jump;
	wire i_mux_select, x_reg_select, y_reg_select; // ixy_mux_selects
	reg sync_reset;


always @ (posedge clk)
	sync_reset <= reset;

// ************************** Program Sequencer ************************** 
	program_sequencer prog_sequencer(
		.clk(clk),
		.sync_reset(sync_reset),
		.pm_addr(pm_address),
		.jmp(jump),
		.jmp_nz(conditional_jump),
		.jmp_addr(LS_nibble_ir),
		.dont_jmp(zero_flag),

		.NOPC8(NOPC8),
		.NOPCF(NOPCF),
		.NOPD8(NOPD8),
		.NOPDF(NOPDF),

		.pc(pc),
		.from_PS(from_PS)
	);

// ************************** Computational Unit ************************** 
	computational_unit comp_unit(
		.clk(clk),
		.sync_reset(sync_reset),
		.r_eq_0(zero_flag),
		.i_pins(i_pins),

		.nibble_ir(LS_nibble_ir),
		.i_sel(i_mux_select),
		.x_sel(x_reg_select),
		.y_sel(y_reg_select),
		.source_sel(source_select),
		.reg_en(register_enables),

		.i(i),
		.data_bus(data_bus),
		.dm(dm),
		.o_reg(o_reg),

		.x0(x0),
		.x1(x1),
		.y0(y0),
		.y1(y1),
		.r(r),
		.m(m),

		.NOPC8(NOPC8),
		.NOPCF(NOPCF),
		.NOPD8(NOPD8),
		.NOPDF(NOPDF),

		.from_CU(from_CU)
	);

// ************************** Instruction Decoder ************************** 
	instruction_decoder intr_decoder(
		.clk(clk),
		.sync_reset(sync_reset),

		.next_instr(pm_data),

		.jmp(jump),
		.jmp_nz(conditional_jump),
		
		.ir_nibble(LS_nibble_ir),
		.i_sel(i_mux_select),
		.y_sel(y_reg_select),
		.x_sel(x_reg_select),
		.source_sel(source_select),
		.reg_en(register_enables),
		.ir(ir),

		.interrupt(interrupt),
		.f1(f1),
		.f2(f2),
		.f3(f3),
		
		.NOPC8(NOPC8),
		.NOPCF(NOPCF),
		.NOPD8(NOPD8),
		.NOPDF(NOPDF),

		.from_ID(from_ID)
	);

// ************************** Data_Memory RAM ************************** 
	data_memory data_mem(
		.clock(~clk),
		.address(i),

		.data(data_bus),
		.q(dm),
		.wren(register_enables[7])
	);

// ************************** Program Memory ************************** 
	program_memory prog_mem(
		.clock(~clk),
		.address(pm_address),
		.q(pm_data)
	);

endmodule