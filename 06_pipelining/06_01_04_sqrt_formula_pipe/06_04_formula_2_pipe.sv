//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe
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
    // Implement a pipelined module formula_2_pipe that computes the result
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
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.org/fsm#state_0

    logic         c_sqrt_vld, b_sqrt_vld;
    logic [15:0 ] c_sqrt, bc_sqrt;
    logic [31:0]  b_delayed;
    logic         b_delayed_vld;
    logic [31:0]  a_delayed;
    logic         a_delayed_vld;
    logic [31:0]  bc_sum_reg;
    logic         bc_vld_reg;
    logic [31:0]  bc_sum;
    logic [31:0]  abc_sum;
    logic [31:0]  abc_sum_reg;
    logic         abc_vld_reg;


    isqrt isqrt_c (
    .clk   (clk),
    .rst   (rst),
    .x_vld (arg_vld),      
    .x     (c),          
    .y_vld (c_sqrt_vld), 
    .y     (c_sqrt)      
    );

    shift_register_with_valid #(
        .width (32),
        .depth (16)       
    ) shift_reg_b (
        .clk      (clk),
        .rst      (rst),
        .in_vld   (arg_vld), 
        .in_data  (b), 
        .out_vld  (b_delayed_vld),
        .out_data (b_delayed)
    );

    shift_register_with_valid #(
        .width (32),
        .depth (33)       
    ) shift_reg_a (
        .clk      (clk),
        .rst      (rst),
        .in_vld   (arg_vld), 
        .in_data  (a), 
        .out_vld  (a_delayed_vld),
        .out_data (a_delayed)
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            bc_sum_reg <= '0;
            bc_vld_reg <= '0;
        end
        else 
        if(b_delayed_vld & c_sqrt_vld) 
        begin
            bc_sum_reg <= bc_sum;
            bc_vld_reg <= '1;
        end
        else 
        bc_vld_reg <= '0;
    end
    
    assign bc_sum = b_delayed + c_sqrt;

    isqrt isqrt_bc (
    .clk   (clk),
    .rst   (rst),
    .x_vld (bc_vld_reg),      
    .x     (bc_sum_reg),          
    .y_vld (b_sqrt_vld), 
    .y     (bc_sqrt)      
    );

    always_ff @(posedge clk) begin
        if(rst) begin
            abc_sum_reg <= '0;
            abc_vld_reg <= '0;
        end
        else
        if (b_sqrt_vld & a_delayed_vld) begin
            abc_sum_reg <= abc_sum;
            abc_vld_reg <= '1;
        end
        else 
        abc_vld_reg <= '0;
    end

    assign abc_sum = a_delayed + bc_sqrt;

    isqrt isqrt_abc (
    .clk   (clk),
    .rst   (rst),
    .x_vld (abc_vld_reg),      
    .x     (abc_sum_reg),          
    .y_vld (res_vld), 
    .y     (res)      
    );




endmodule
