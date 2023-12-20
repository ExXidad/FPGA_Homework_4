module NCO(clk,
           rst,
           step,
           out);
    // Parameters
    parameter STEP_INTEGER_PART_WIDTH    = 8;
    parameter STEP_FRACTIONAL_PART_WIDTH = 8;
    localparam STEP_WIDTH                = STEP_INTEGER_PART_WIDTH + STEP_FRACTIONAL_PART_WIDTH;
    
    parameter LUT_ADDR_WIDTH = 8;
    parameter LUT_DATA_WIDTH = 10;
    localparam LUT_DATA_AMP  = 2**LUT_DATA_WIDTH;
    localparam LUT_SIZE      = 2**LUT_ADDR_WIDTH;
    localparam PERIOD        = 4*LUT_SIZE;
    localparam PERIOD_WIDTH  = LUT_ADDR_WIDTH+2;
    localparam PERIOD_1_2    = 2*LUT_SIZE;
    localparam PERIOD_1_4    = LUT_SIZE;

    // Inputs
    input clk;
    input rst;
    input [STEP_WIDTH-1:0] step;

    // Outputs
    output [LUT_DATA_WIDTH-1+1:0] out;

    // Code
    // Instantiate LFSR
    localparam LFSR_OUT_SIZE = STEP_FRACTIONAL_PART_WIDTH;
    wire [LFSR_OUT_SIZE-1:0] lfsr_out;
    lfsr #(.OUT_SIZE(LFSR_OUT_SIZE)) lfsr_module(.clk(clk),.rst(rst),.out(lfsr_out));

    // Generate LUT
    reg unsigned [LUT_DATA_WIDTH-1:0] LUT [LUT_SIZE-1:0];
    initial begin
        static real pi = $atan(1)*4.0;
        integer phase_index;
        $display("Generating LUT. LUT size is %d. LUT data width is %d",LUT_SIZE,LUT_DATA_WIDTH);
        for (phase_index = 0; phase_index < LUT_SIZE; phase_index = phase_index + 1) begin
            LUT[phase_index] = $floor($sin(2*pi*phase_index/LUT_SIZE/4)*(LUT_DATA_AMP-1));
//            $display(LUT[phase_index]);
        end
    end

    // Update phase
    reg [PERIOD_WIDTH+STEP_FRACTIONAL_PART_WIDTH-1:0] phase_accumulator;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            phase_accumulator <= 0;
        end
        else begin
            phase_accumulator <= phase_accumulator + step;
        end
    end
    wire [PERIOD_WIDTH+STEP_FRACTIONAL_PART_WIDTH-1:0] phase;
    assign phase = phase_accumulator + lfsr_out;

    // Update address
    wire [PERIOD_WIDTH-1:0] period_address;
    assign period_address = phase[PERIOD_WIDTH+STEP_FRACTIONAL_PART_WIDTH-1:STEP_FRACTIONAL_PART_WIDTH];

    wire sign;
    assign sign = period_address <= PERIOD_1_2;
    wire reverse;
    assign reverse = ((PERIOD_1_4<=period_address)&&(period_address<PERIOD_1_2))||(((PERIOD_1_4+PERIOD_1_2)<=period_address)&&(period_address<PERIOD));

    wire [1:0] quarter_period_idx = {!sign, reverse};
    wire [LUT_ADDR_WIDTH-1:0] quarter_period_address;
    assign quarter_period_address = period_address-quarter_period_idx*PERIOD_1_4;

    wire [LUT_ADDR_WIDTH-1:0] LUT_address;
    assign LUT_address = (reverse?(PERIOD_1_4-1-quarter_period_address):(quarter_period_address));

    // Write to out
//    assign out = (sign);
    assign out = LUT_DATA_AMP+1 + (sign?1:-1)*LUT[LUT_address];
// проставить -1
endmodule
