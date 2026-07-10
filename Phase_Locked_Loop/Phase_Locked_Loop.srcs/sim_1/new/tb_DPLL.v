//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 10.07.2026 12:44:32
//// Design Name: 
//// Module Name: tb_DPLL
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


//`timescale 1ns / 1ps

//module tb_DPLL;

//parameter PHASE_BITS = 32;

////--------------------------------------------------
//// Inputs
////--------------------------------------------------
//reg                     i_clk;
//reg                     i_ld;
//reg [PHASE_BITS-2:0]    i_step;
//reg                     i_ce;
//reg                     i_input;
//reg [4:0]               i_lgcoeff;

////--------------------------------------------------
//// Outputs
////--------------------------------------------------
//wire [PHASE_BITS-1:0]   o_phase;
//wire [1:0]              o_err;

////--------------------------------------------------
//// Instantiate DUT
////--------------------------------------------------
//DPLL #(
//    .PHASE_BITS(PHASE_BITS),
//    .OPT_TRACK_FREQUENCY(1'b1),
//    .INITIAL_PHASE_STEP(32'd0),
//    .OPT_GLITCHLESS(1'b1)
//)
//dut (
//    .i_clk(i_clk),
//    .i_ld(i_ld),
//    .i_step(i_step),
//    .i_ce(i_ce),
//    .i_input(i_input),
//    .i_lgcoeff(i_lgcoeff),
//    .o_phase(o_phase),
//    .o_err(o_err)
//);

////--------------------------------------------------
//// 100 MHz System Clock
////--------------------------------------------------
//always #5 i_clk = ~i_clk;

////--------------------------------------------------
//// Reference Clock (~6.25 MHz)
//// 160 ns period
////--------------------------------------------------
//always #80 i_input = ~i_input;

////--------------------------------------------------
//// Stimulus
////--------------------------------------------------
//initial begin

//    // Initialize
//    i_clk      = 0;
//    i_input    = 0;
//    i_ce       = 1'b1;
//    i_ld       = 1'b0;

//    // Moderate loop gain
//    i_lgcoeff  = 5'd6;

//    // Large initial phase step for visible operation
//   i_step = 31'h10000000;

//    // Wait a few clocks
//    #20;

//    // Load initial frequency word
//    i_ld = 1'b1;

//    #10;

//    i_ld = 1'b0;

//    // Let the PLL run
//    #20000;

//    $finish;

//end;

//endmodule
`timescale 1ns / 1ps

module tb_DPLL;

parameter PHASE_BITS = 32;

//--------------------------------------------------
// Inputs
//--------------------------------------------------
reg                     i_clk;
reg                     i_ld;
reg [PHASE_BITS-2:0]    i_step;
reg                     i_ce;
reg                     i_input;
reg [4:0]               i_lgcoeff;

//--------------------------------------------------
// Outputs
//--------------------------------------------------
wire [PHASE_BITS-1:0]   o_phase;
wire [1:0]              o_err;

//--------------------------------------------------
// DUT
//--------------------------------------------------
DPLL #(
    .PHASE_BITS(PHASE_BITS),
    .OPT_TRACK_FREQUENCY(1'b1),
    .INITIAL_PHASE_STEP(32'd0),
    .OPT_GLITCHLESS(1'b1)
)
dut(
    .i_clk(i_clk),
    .i_ld(i_ld),
    .i_step(i_step),
    .i_ce(i_ce),
    .i_input(i_input),
    .i_lgcoeff(i_lgcoeff),
    .o_phase(o_phase),
    .o_err(o_err)
);

//--------------------------------------------------
// 100 MHz System Clock
//--------------------------------------------------
always #5 i_clk = ~i_clk;

//--------------------------------------------------
// 6.25 MHz Reference Clock
//--------------------------------------------------
always #80 i_input = ~i_input;

//--------------------------------------------------
// Test Sequence
//--------------------------------------------------
initial begin

    i_clk = 0;
    i_input = 0;

    i_ce = 1;
    i_ld = 0;

    // Stronger corrections
    i_lgcoeff = 5'd4;

    //------------------------------------------------
    // CASE 1 : Near Lock
    //------------------------------------------------
    $display("CASE 1 : Near Lock");

    i_step = 31'h10000000;

    #20;
    i_ld = 1;
    #10;
    i_ld = 0;

    #5000;

    //------------------------------------------------
    // CASE 2 : Too Fast
    //------------------------------------------------
    $display("CASE 2 : Too Fast");

    i_step = 31'h18000000;

    #20;
    i_ld = 1;
    #10;
    i_ld = 0;

    #5000;

    //------------------------------------------------
    // CASE 3 : Too Slow
    //------------------------------------------------
    $display("CASE 3 : Too Slow");

    i_step = 31'h08000000;

    #20;
    i_ld = 1;
    #10;
    i_ld = 0;

    #5000;

    $finish;

end

endmodule