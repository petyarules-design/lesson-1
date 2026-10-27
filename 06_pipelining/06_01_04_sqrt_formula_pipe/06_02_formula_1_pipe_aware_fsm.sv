//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
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

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);

    // Task:
    //
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    //
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    //
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    //
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    //
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    //
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    //
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.org/fsm#state_0

    enum logic[4:0] {
        st_idle,
        st_a,
        st_b,
        st_c,
        st_a_res,
        st_b_res,
        st_c_res,
        st_done
    }
    state, new_state;

    logic [15:0] a_sqrt, b_sqrt, c_sqrt;

    always_comb
    begin
        new_state = state;
        isqrt_x_vld = '0;
        isqrt_x     = '0;
        res_vld     = '0;
        res         = '0;

        case(state)
            st_idle:
            begin
                if(arg_vld)
                begin
                    new_state = st_a;
                end
            end

            st_a:
            begin
                isqrt_x_vld = '1;
                isqrt_x     = a;
                new_state   = st_b;
            end

            st_b:
            begin
                isqrt_x_vld = '1;
                isqrt_x     = b;
                new_state   = st_c;
            end

            st_c:
            begin
                isqrt_x_vld = '1;
                isqrt_x     = c;
                new_state   = st_a_res;
            end

            st_a_res:
            begin
                if(isqrt_y_vld)
                begin
                    new_state = st_b_res;
                end
            end

            st_b_res:
            begin
                if(isqrt_y_vld)
                begin
                    new_state = st_c_res;
                end
            end
            
            st_c_res:
            begin
                if(isqrt_y_vld)
                begin
                    new_state = st_done;
                end
            end

            st_done:
            begin
                res_vld = 1'b1;
                res     = 32'(a_sqrt) + 32'(b_sqrt) + 32'(c_sqrt);
                if (arg_vld)
                    new_state = st_a;
                else
                    new_state = st_idle;
            end
    endcase
    end
    

    always_ff @(posedge clk) begin
        if (rst)
            state <= st_idle;
        else 
            state <= new_state;
    end

    always_ff @(posedge clk) begin
        if (rst)
        begin
            a_sqrt <= '0;
            b_sqrt <= '0;
            c_sqrt <= '0;
        end
        else 
        begin
            if (state == st_a_res && isqrt_y_vld)
                a_sqrt <= isqrt_y;

            if (state == st_b_res && isqrt_y_vld)
                b_sqrt <= isqrt_y;

            if (state == st_c_res && isqrt_y_vld)
                c_sqrt <= isqrt_y;

        end
    end





endmodule
