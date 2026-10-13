//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4ac == b*b - 4*a*c
    //
    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    localparam [FLEN-1:0] four = 64'h4010_0000_0000_0000;

    enum logic [2:0]
    {
        st_idle       = 3'd0,
        st_wait_4a    = 3'd1,
        st_wait_ac    = 3'd2,
        st_wait_b2_ac = 3'd3,
        st_wait_sub   = 3'd4,
        st_done       = 3'd5
    }
    state, next_state;


    logic [FLEN-1:0] b2;
    logic [FLEN-1:0] four_a;
    logic [FLEN-1:0] four_ac;
    logic [FLEN-1:0] sub_res;

    logic b2_vld,  b2_err;
    logic fa_vld,  fa_err;
    logic fac_vld, fac_err;
    logic sub_vld, sub_err;

    logic b2_captured;
    logic fac_captured;

    logic start_b2, start_fa, start_fac, start_sub;


    always_comb
    begin
        next_state = state;
        start_b2   = 1'b0;
        start_fa   = 1'b0;
        start_fac  = 1'b0;
        start_sub  = 1'b0;

        case (state)
            st_idle:
                if (arg_vld) begin
                    start_b2   = 1'b1;
                    start_fa   = 1'b1;
                    next_state = st_wait_4a;
                end

            st_wait_4a:
                if (fa_vld) begin
                    start_fac  = 1'b1;
                    next_state = st_wait_ac;
                end

            st_wait_ac:
                if (fac_vld) begin
                    next_state = st_wait_b2_ac;
                end

            st_wait_b2_ac:
                if (b2_captured && fac_captured) begin
                    start_sub  = 1'b1;
                    next_state = st_wait_sub;
                end

            st_wait_sub:
                if (sub_vld)
                    next_state = st_done;

            st_done:
                next_state = st_idle;

            default:
                next_state = st_idle;
        endcase
    end

    always_ff @(posedge clk)
        if (rst) state <= st_idle;
        else     state <= next_state;

    always_ff @(posedge clk)
    begin
        if (rst) begin
            b2_captured  <= 1'b0;
            fac_captured <= 1'b0;
        end
        else begin
            if (b2_vld)  b2_captured  <= 1'b1;
            if (fac_vld) fac_captured <= 1'b1;
            if (start_sub) begin
                b2_captured  <= 1'b0;
                fac_captured <= 1'b0;
            end
        end
    end

    f_mult u_b2 (
        .clk        (clk),
        .rst        (rst),
        .a          (b),
        .b          (b),
        .up_valid   (start_b2),
        .res        (b2),
        .down_valid (b2_vld),
        .busy       (),
        .error      (b2_err)
    );

    f_mult u_four_a (
        .clk        (clk),
        .rst        (rst),
        .a          (four),
        .b          (a),
        .up_valid   (start_fa),
        .res        (four_a),
        .down_valid (fa_vld),
        .busy       (),
        .error      (fa_err)
    );

    f_mult u_four_ac (
        .clk        (clk),
        .rst        (rst),
        .a          (four_a),
        .b          (c),
        .up_valid   (start_fac),
        .res        (four_ac),
        .down_valid (fac_vld),
        .busy       (),
        .error      (fac_err)
    );

    f_sub u_sub (
        .clk        (clk),
        .rst        (rst),
        .a          (b2),
        .b          (four_ac),
        .up_valid   (start_sub),
        .res        (sub_res),
        .down_valid (sub_vld),
        .busy       (),
        .error      (sub_err)
    );

    assign res          = sub_res;
    assign res_vld      = (state == st_done);
    assign res_negative = sub_res[FLEN-1];
    assign err          = b2_err | fa_err | fac_err | sub_err;
    assign busy         = (state != st_idle);

endmodule