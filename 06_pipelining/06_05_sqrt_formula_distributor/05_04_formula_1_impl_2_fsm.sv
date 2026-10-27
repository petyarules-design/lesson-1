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


    enum logic [1:0] {
        st_idle,
        st_wait_ab,
        st_wait_c,
        st_done
    } state, new_state;

    always_comb begin
        new_state = state;
        isqrt_1_x_vld = 1'b0;
        isqrt_1_x = 'x;
        isqrt_2_x_vld = 1'b0;
        isqrt_2_x = 'x;

        case(state)
            st_idle: begin
                if (arg_vld) begin
                    isqrt_1_x = a;          
                    isqrt_1_x_vld = 1'b1;
                    isqrt_2_x = b;          
                    isqrt_2_x_vld = 1'b1;
                    new_state = st_wait_ab;
                end
            end
            st_wait_ab: begin
                if (isqrt_1_y_vld && isqrt_2_y_vld) begin
                    isqrt_1_x = c;          
                    isqrt_1_x_vld = 1'b1;
                    new_state = st_wait_c;
                end
            end
            st_wait_c: begin
                if (isqrt_1_y_vld) begin
                    new_state = st_done;
                end
            end
            st_done: begin
                new_state = st_idle;
            end
            default: new_state = st_idle;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= st_idle;
            res <= '0;
            res_vld <= 1'b0;
        end else begin
            state <= new_state;
            res_vld <= (state == st_wait_c) && isqrt_1_y_vld;
            
            if (state == st_idle) begin
                res <= '0;
            end
            else if (state == st_wait_ab && isqrt_1_y_vld && isqrt_2_y_vld) begin
                res <= 32'(isqrt_1_y) + 32'(isqrt_2_y); 
            end
            else if (state == st_wait_c && isqrt_1_y_vld) begin
                res <= res + 32'(isqrt_1_y);           
            end
        end
    end

endmodule
