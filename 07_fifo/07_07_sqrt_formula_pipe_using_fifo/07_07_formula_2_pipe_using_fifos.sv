//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe_using_fifos
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output logic        res_vld,
    output logic [31:0] res
);
    // Task:
    //
    // Implement a pipelined module formula_2_pipe_using_fifos that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should use FIFOs instead of shift registers
    // which were used in 06_04_formula_2_pipe.sv.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.org/fsm#state_0

    localparam L = 16;

    logic        sqrt_c_vld;
    logic [15:0] sqrt_c;
    logic [31:0] c_masked;

    assign c_masked = arg_vld ? c : 32'b0;

    isqrt u_isqrt_1 (
        .clk   (clk       ),
        .rst   (rst       ),
        .x_vld (arg_vld   ),
        .x     (c_masked  ),
        .y_vld (sqrt_c_vld),
        .y     (sqrt_c    )
    );

    logic        b_fifo_full;
    logic        b_fifo_empty_dummy;
    logic [32:0] b_fifo_out;
    logic        b_d_vld;
    logic [31:0] b_d;

    flip_flop_fifo_with_counter #(
        .width (33),
        .depth (L)
    ) fifo_b (
        .clk        (clk               ),
        .rst        (rst               ),
        .push       (1'b1              ),
        .pop        (b_fifo_full       ),
        .write_data ({arg_vld, b}      ),
        .read_data  (b_fifo_out        ),
        .empty      (b_fifo_empty_dummy),
        .full       (b_fifo_full       )
    );

    assign b_d_vld = b_fifo_full & b_fifo_out[32];
    assign b_d     = b_fifo_full ? b_fifo_out[31:0] : 32'b0;

    logic [31:0] sum1;
    logic        sum1_vld;

    always_comb begin
        sum1     = b_d + {16'b0, sqrt_c};
        sum1_vld = b_d_vld & sqrt_c_vld;
    end

    logic        sqrt_sum1_vld;
    logic [15:0] sqrt_sum1;

    isqrt u_isqrt_2 (
        .clk   (clk          ),
        .rst   (rst          ),
        .x_vld (sum1_vld     ),
        .x     (sum1         ),
        .y_vld (sqrt_sum1_vld),
        .y     (sqrt_sum1    )
    );

    logic        a_fifo_full;
    logic        a_fifo_empty_dummy;
    logic [32:0] a_fifo_out;
    logic        a_d_vld;
    logic [31:0] a_d;

    flip_flop_fifo_with_counter #(
        .width (33),
        .depth (2 * L)
    ) fifo_a (
        .clk        (clk               ),
        .rst        (rst               ),
        .push       (1'b1              ),
        .pop        (a_fifo_full       ),
        .write_data ({arg_vld, a}      ),
        .read_data  (a_fifo_out        ),
        .empty      (a_fifo_empty_dummy),
        .full       (a_fifo_full       )
    );

    assign a_d_vld = a_fifo_full & a_fifo_out[32];
    assign a_d     = a_fifo_full ? a_fifo_out[31:0] : 32'b0;

    logic [31:0] sum2;
    logic        sum2_vld;

    always_comb begin
        sum2     = a_d + {16'b0, sqrt_sum1};
        sum2_vld = a_d_vld & sqrt_sum1_vld;
    end

    logic        res_sqrt_vld;
    logic [15:0] res_sqrt;

    isqrt u_isqrt_3 (
        .clk   (clk         ),
        .rst   (rst         ),
        .x_vld (sum2_vld    ),
        .x     (sum2        ),
        .y_vld (res_sqrt_vld),
        .y     (res_sqrt    )
    );

    logic vld_fifo_full;
    logic vld_fifo_empty_dummy;
    logic vld_fifo_out;

    flip_flop_fifo_with_counter #(
        .width (1),
        .depth (3 * L)
    ) fifo_vld (
        .clk        (clk                 ),
        .rst        (rst                 ),
        .push       (1'b1                ),
        .pop        (vld_fifo_full       ),
        .write_data (arg_vld             ),
        .read_data  (vld_fifo_out        ),
        .empty      (vld_fifo_empty_dummy),
        .full       (vld_fifo_full       )
    );

    assign res_vld = vld_fifo_full & vld_fifo_out;
    assign res     = {16'b0, res_sqrt};

endmodule
