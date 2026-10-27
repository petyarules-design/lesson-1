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

    localparam [FLEN-1:0] FOUR = 64'h4010_0000_0000_0000;

    logic m1_vld, m1_dvld, m1_err;
    logic [FLEN-1:0] m1_res;

    logic m2_vld, m2_dvld, m2_err;
    logic [FLEN-1:0] m2_res;

    logic m3_vld, m3_dvld, m3_err;
    logic [FLEN-1:0] m3_res;

    logic s_vld, s_dvld, s_err;
    logic [FLEN-1:0] s_res;

    enum logic [2:0] { 
        st_idle, 
        st_wait_m1_m2, 
        st_wait_m3, 
        st_wait_sub, 
        st_done 
    } state, next_state;

    always_ff @(posedge clk) begin
        if (rst) state <= st_idle;
        else     state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            st_idle:       if (arg_vld) next_state = st_wait_m1_m2;
            st_wait_m1_m2: if (m1_dvld && m2_dvld) next_state = st_wait_m3;
            st_wait_m3:    if (m3_dvld) next_state = st_wait_sub;
            st_wait_sub:   if (s_dvld)  next_state = st_done;
            st_done:       next_state = st_idle;
            default:       next_state = st_idle;
        endcase
    end

    always_comb begin
        m1_vld = 1'b0; m2_vld = 1'b0; m3_vld = 1'b0; s_vld = 1'b0;
        
        if (state == st_idle && arg_vld) begin
            m1_vld = 1'b1; 
            m2_vld = 1'b1; 
        end
        if (state == st_wait_m1_m2 && m1_dvld && m2_dvld) begin
            m3_vld = 1'b1; 
        end
        if (state == st_wait_m3 && m3_dvld) begin
            s_vld = 1'b1;  
        end
    end

    f_mult u_m1 (
        .clk(clk), .rst(rst), .a(b), .b(b), 
        .up_valid(m1_vld), .res(m1_res), .down_valid(m1_dvld), .busy(), .error(m1_err)
    );
    f_mult u_m2 (
        .clk(clk), .rst(rst), .a(FOUR), .b(a), 
        .up_valid(m2_vld), .res(m2_res), .down_valid(m2_dvld), .busy(), .error(m2_err)
    );
    f_mult u_m3 (
        .clk(clk), .rst(rst), .a(m2_res), .b(c), 
        .up_valid(m3_vld), .res(m3_res), .down_valid(m3_dvld), .busy(), .error(m3_err)
    );
    f_sub u_sub (
        .clk(clk), .rst(rst), .a(m1_res), .b(m3_res), 
        .up_valid(s_vld), .res(s_res), .down_valid(s_dvld), .busy(), .error(s_err)
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            res_vld <= 1'b0;
            res     <= '0;
            err     <= 1'b0;
        end else begin
            res_vld <= (state == st_done);
            if (state == st_done) res <= s_res;

            if (state == st_idle) err <= 1'b0;
            else if (m1_err || m2_err || m3_err || s_err) err <= 1'b1;
        end
    end

    assign res_negative = res[FLEN-1];
    assign busy         = (state != st_idle);


endmodule
