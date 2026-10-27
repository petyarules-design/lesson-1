//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe
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
    // Implement a pipelined module formula_1_pipe that computes the result
    // of the formula defined in the file formula_1_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_1_pipe has to be pipelined.
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
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.org/fsm#state_0
    
    logic [15:0] a_sqrt, b_sqrt, c_sqrt;
    logic a_sqrt_vld, b_sqrt_vld, c_sqrt_vld;

    isqrt isqrt_a (
    .clk   (clk),
    .rst   (rst),
    .x_vld (arg_vld),      
    .x     (a),          
    .y_vld (a_sqrt_vld), 
    .y     (a_sqrt)      
    );

    isqrt isqrt_b (
    .clk   (clk),
    .rst   (rst),
    .x_vld (arg_vld),      
    .x     (b),          
    .y_vld (b_sqrt_vld), 
    .y     (b_sqrt)      
    );

    isqrt isqrt_c (
    .clk   (clk),
    .rst   (rst),
    .x_vld (arg_vld),      
    .x     (c),          
    .y_vld (c_sqrt_vld), 
    .y     (c_sqrt)      
    );

    always_ff @( posedge clk ) begin 
        if (rst) begin
            res_vld <= '0;
            res     <= '0;
        end
        else if (a_sqrt_vld & b_sqrt_vld & c_sqrt_vld) begin
            res     <= {16'b0, a_sqrt} + {16'b0, b_sqrt} + {16'b0, c_sqrt};
            res_vld <= '1;
        end
        else 
            res_vld <= '0;
    end


endmodule
