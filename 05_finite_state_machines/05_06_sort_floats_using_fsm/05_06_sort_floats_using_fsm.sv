//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_floats_using_fsm (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output                         busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order using FSM.
    //
    // Requirements:
    // The solution must have latency equal to the three clock cycles.
    // The solution should use the inputs and outputs to the single "f_less_or_equal" module.
    // The solution should NOT create instances of any modules.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res1
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.
    enum logic [1:0]
    {
        st_idle  = 2'd0,
        st_comp2 = 2'd1,
        st_comp3 = 2'd2,
        st_done  = 2'd3
    }
    state, new_state;

    logic [FLEN-1:0] x, y, z;

    wire [3*FLEN-1:0] uflat = unsorted;
    wire [FLEN-1:0]   u0 = uflat[3*FLEN-1 -: FLEN];
    wire [FLEN-1:0]   u1 = uflat[2*FLEN-1 -: FLEN];
    wire [FLEN-1:0]   u2 = uflat[FLEN-1   -: FLEN];

    wire comparing = (state == st_idle && valid_in)
                  || (state == st_comp2)
                  || (state == st_comp3);

    wire error_detected = f_le_err && comparing;



    always_comb
    begin
        new_state = state;
        f_le_a    = 'x;
        f_le_b    = 'x;

        case (state)
            st_idle:
            begin
                if (valid_in)
                begin
                    f_le_a = u0;
                    f_le_b = u1;
                    if (f_le_err)
                        new_state = st_done;
                    else
                        new_state = st_comp2;
                end
            end

            st_comp2:
            begin
                f_le_a = x;
                f_le_b = z;
                if (f_le_err)
                    new_state = st_done;
                else
                    new_state = st_comp3;
            end

            st_comp3:
            begin
                f_le_a = y;
                f_le_b = z;
                new_state = st_done;
            end

            st_done:
                new_state = st_idle;

            default:
                new_state = st_idle;
        endcase
    end

    always_ff @(posedge clk)
    begin
        if (rst)
        begin
            state  <= st_idle;
            x      <= '0;
            y      <= '0;
            z      <= '0;
            sorted <= '0;
            err    <= 1'b0;
        end
        else
        begin
            state <= new_state;

            if (state == st_idle && valid_in)
            begin
                if (f_le_err || f_le_res)
                begin
                    x <= u0;
                    y <= u1;
                    z <= u2;
                end
                else
                begin
                    x <= u1;
                    y <= u0;
                    z <= u2;
                end
            end

            if (state == st_comp2 && ~f_le_err && ~f_le_res)
            begin
                x <= z;
                z <= x;
            end

            if (state == st_comp3 && ~f_le_err)
            begin
                sorted[0] <= x;
                if (f_le_res)
                begin
                    sorted[1] <= y;
                    sorted[2] <= z;
                end
                else
                begin
                    sorted[1] <= z;
                    sorted[2] <= y;
                end
            end

            if (error_detected)
                err <= 1'b1;
            else if (state == st_idle)
                err <= 1'b0;
        end
    end

    assign valid_out = (state == st_done);
    assign busy      = (state != st_idle);

endmodule