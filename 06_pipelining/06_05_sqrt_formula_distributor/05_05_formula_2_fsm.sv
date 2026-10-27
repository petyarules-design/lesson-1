//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_fsm
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
    // Implement a module that calculates the formula from the `formula_2_fn.svh` file
    // using only one instance of the isqrt module.
    //
    // Design the FSM to calculate answer step-by-step and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.org/fsm#state_0

    enum logic [2:0] {
        st_idle,
        st_wait_c,
        st_wait_b,
        st_wait_a,
        st_done
    } state, new_state;

    always_comb begin
        new_state = state;
        isqrt_x_vld = 1'b0;
        isqrt_x = 'x;

        case(state)
            st_idle: begin
                if (arg_vld) begin
                    isqrt_x = c;            
                    isqrt_x_vld = 1'b1;
                    new_state = st_wait_c;
                end
            end
            st_wait_c: begin
                if (isqrt_y_vld) begin
                    isqrt_x = b + 32'(isqrt_y); 
                    isqrt_x_vld = 1'b1;
                    new_state = st_wait_b;
                end
            end
            st_wait_b: begin
                if (isqrt_y_vld) begin
                    isqrt_x = a + 32'(isqrt_y); 
                    isqrt_x_vld = 1'b1;
                    new_state = st_wait_a;
                end
            end
            st_wait_a: begin
                if (isqrt_y_vld) begin
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
            res_vld <= (state == st_wait_a) && isqrt_y_vld;
            
            if (state == st_wait_a && isqrt_y_vld) begin
                res <= 32'(isqrt_y); 
            end
        end
    end

endmodule
