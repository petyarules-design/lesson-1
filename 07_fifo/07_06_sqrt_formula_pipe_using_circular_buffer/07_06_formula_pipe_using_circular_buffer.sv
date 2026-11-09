//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe_using_circular
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);

    // Task:
    //
    // Implement a pipelined module formula_2_pipe_using_circular
    // that computes the result of the formula defined in the file formula_2_fn.svh.
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
    // 3. Your solution should use circular buffers instead of shift registers
    // which were used in 06_04_formula_2_pipe.sv.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.org/fsm#state_0

    localparam int L = 16;

    wire        sqrt_c_vld;
    wire [15:0] sqrt_c;

    isqrt u_isqrt_1 (
        .clk   (clk       ),
        .rst   (rst       ),
        .x_vld (arg_vld   ),
        .x     (c         ),
        .y_vld (sqrt_c_vld),
        .y     (sqrt_c    )
    );


    wire        b_d_vld;
    wire [31:0] b_d;

    circular_buffer_with_valid #(.width(32), .depth(L)) buf_b (
        .clk       (clk    ),
        .rst       (rst    ),
        .in_valid  (arg_vld),
        .in_data   (b      ),
        .out_valid (b_d_vld),
        .out_data  (b_d    )
    );

    wire [31:0] sum1     = b_d + {16'b0, sqrt_c};
    wire        sum1_vld = b_d_vld & sqrt_c_vld;

    wire        sqrt_sum1_vld;
    wire [15:0] sqrt_sum1;

    isqrt u_isqrt_2 (
        .clk   (clk          ),
        .rst   (rst          ),
        .x_vld (sum1_vld     ),
        .x     (sum1         ),
        .y_vld (sqrt_sum1_vld),
        .y     (sqrt_sum1    )
    );

    wire        a_d_vld;
    wire [31:0] a_d;

    circular_buffer_with_valid #(.width(32), .depth(2*L)) buf_a (
        .clk       (clk    ),
        .rst       (rst    ),
        .in_valid  (arg_vld),
        .in_data   (a      ),
        .out_valid (a_d_vld),
        .out_data  (a_d    )
    );

    wire [31:0] sum2     = a_d + {16'b0, sqrt_sum1};
    wire        sum2_vld = a_d_vld & sqrt_sum1_vld;

    wire        res_sqrt_vld;
    wire [15:0] res_sqrt;

    isqrt u_isqrt_3 (
        .clk   (clk         ),
        .rst   (rst         ),
        .x_vld (sum2_vld    ),
        .x     (sum2        ),
        .y_vld (res_sqrt_vld),
        .y     (res_sqrt    )
    );

    wire res_vld_d;

    circular_buffer_with_valid #(.width(1), .depth(3*L)) buf_vld (
        .clk       (clk      ),
        .rst       (rst      ),
        .in_valid  (1'b1     ),
        .in_data   (arg_vld  ),
        .out_valid (         ),
        .out_data  (res_vld_d)
    );

    assign res_vld = res_vld_d;
    assign res     = {16'b0, res_sqrt};

    logic _unused_ok = res_sqrt_vld;


endmodule
