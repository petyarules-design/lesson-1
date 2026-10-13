//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_impl_2_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_1_x_vld,
    output logic [31:0] isqrt_1_x,

    input               isqrt_1_y_vld,
    input        [15:0] isqrt_1_y,

    output logic        isqrt_2_x_vld,
    output logic [31:0] isqrt_2_x,

    input               isqrt_2_y_vld,
    input        [15:0] isqrt_2_y
);

    // Task:
    // Implement a module that calculates the formula from the `formula_1_fn.svh` file
    // using two instances of the isqrt module in parallel.
    //
    // Design the FSM to calculate an answer and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.org/fsm#state_0
    enum logic [1:0]
    {
        st_idle    = 2'd0,
        st_wait_ab = 2'd1,
        st_wait_c  = 2'd2
    }
    state, next_state;

    always_comb
    begin
        next_state    = state;
        isqrt_1_x_vld = '0;
        isqrt_1_x     = 'x;
        isqrt_2_x_vld = '0;
        isqrt_2_x     = 'x;


        case (state)
        st_idle:
        begin
            isqrt_1_x = a;
            isqrt_2_x = b;
            if (arg_vld) begin
                isqrt_1_x_vld = 1'b1;  
                isqrt_2_x_vld = 1'b1;   
                next_state    = st_wait_ab;
            end
        end

        st_wait_ab:
        begin
            isqrt_1_x = c;              
            if (isqrt_1_y_vld & isqrt_2_y_vld) begin
                isqrt_1_x_vld = 1'b1;    
                next_state    = st_wait_c;
            end
        end

        st_wait_c:
        begin
            if (isqrt_1_y_vld)
                next_state = st_idle;
        end
        endcase

    end

    always_ff @(posedge clk)
        if (rst) state <= st_idle;
        else     state <= next_state;

    always_ff @(posedge clk)
        if (rst) res_vld <= '0;
        else     res_vld <= (state == st_wait_c) & isqrt_1_y_vld;


    always_ff @(posedge clk)
        if (state == st_idle)
            res <= '0;
        else if ((state == st_wait_ab) & isqrt_1_y_vld & isqrt_2_y_vld)
            res <= 32'(isqrt_1_y) + 32'(isqrt_2_y);  
        else if ((state == st_wait_c) & isqrt_1_y_vld)
            res <= res + 32'(isqrt_1_y);             
endmodule

