//=============================================================
//
// Digital Phase-Locked Loop (DPLL)
//
// Author      : Aadi Khandekar
//
// Description:
//
// Educational implementation of a Digital Phase-Locked Loop
// using a phase accumulator based Numerically Controlled
// Oscillator (NCO).
//
// Features
// --------
// • Square-wave NCO
// • Digital phase detector
// • Configurable loop gain
// • Optional frequency tracking
// • Glitch-free phase correction
//
//=============================================================

`default_nettype	none

module	DPLL #(

		parameter		PHASE_BITS = 32,
		parameter	[0:0]	OPT_TRACK_FREQUENCY = 1'b1,
		parameter	[PHASE_BITS-1:0]	INITIAL_PHASE_STEP = 0,
		parameter	[0:0]	OPT_GLITCHLESS = 1'b1,
		localparam	MSB=PHASE_BITS-1

	) (
	
		input	wire			i_clk,
		//
		input	wire			i_ld,
		input	wire	[(MSB-1):0]	i_step,
		//
		input	wire			i_ce,
		input	wire			i_input,	// Input clock
	input	wire	[4:0]		i_lgcoeff,	// Logarithm of the gain coeffecient
		output	wire	[PHASE_BITS-1:0] o_phase,
		output	reg	[1:0]		o_err
	);

	// Signal declarations

	reg		agreed_output, lead;	// lag
	wire		phase_err;
	reg	[MSB:0]	ctr, phase_correction, freq_correction, r_step;


	// agreed_output -->  = 1 when both clocks are aligned.
	
	initial	agreed_output = 0;
	always @(posedge i_clk)
	if (i_ce)
	begin
		if ((i_input)&&(ctr[MSB]))
			agreed_output <= 1'b1;
		else if ((!i_input)&&(!ctr[MSB]))
			agreed_output <= 1'b0;
	end


	// lead --. tells if PLL/generated clock is ahead if lead = 1; behind if lead = 0

	always @(*)
	if (agreed_output)
		// We were last high.  Lead is true now
		// if the counter goes low before the input
		lead = (!ctr[MSB])&&(i_input);
	else
		// The last time we agreed, both the counter
		// and the input were low.   This will be
		// true if the counter goes high before the input
		lead = (ctr[MSB])&&(!i_input);

	// phase_err
	// Any disagreement between the high order counter bit and the input
	assign	phase_err = (ctr[MSB] != i_input);

	// phase_correction
	initial	phase_correction = 0;
	always @(posedge i_clk)
		phase_correction <= {1'b1,{(MSB){1'b0}}} >> i_lgcoeff;

	// ctr
	// Finally, apply a correction
	initial	ctr = 0;
	always @(posedge i_clk)
	if (i_ce)
	begin
		if (!phase_err)
			ctr <= ctr + r_step;

		// Otherwise we don't match.  We need to adjust our counter based upon how far off we are.
		else if (lead)
		begin
			if (!OPT_GLITCHLESS || r_step > phase_correction)
				ctr <= ctr + r_step - phase_correction;
		end
		else // if (lag)
			ctr <= ctr + r_step + phase_correction;
	end

	// o_phase (== ctr)
	assign	o_phase = ctr;

	// freq_correction
	initial	freq_correction = 0;
	always @(posedge i_clk)
		freq_correction <= { 3'b001, {(MSB-2){1'b0}} } >> (2*i_lgcoeff);

	// r_step -- frequency tracking
	initial	r_step = INITIAL_PHASE_STEP;
	always @(posedge i_clk)
	if (i_ld)
		r_step <= { 1'b0, i_step };
	else if ((i_ce)&&(OPT_TRACK_FREQUENCY)&&(phase_err))
	begin
		if (lead)
			r_step <= r_step - freq_correction;
		else
			r_step <= r_step + freq_correction;
	end
	// }}}

	// o_err
	// Output an error signal 
	initial	o_err = 2'h0;
	always @(posedge i_clk)
	if (i_ce)
		o_err <= (!phase_err) ? 2'b00 : ((lead) ? 2'b11 : 2'b01);

endmodule
