//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module sort_two_floats_ab (
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,

    output logic [FLEN - 1:0] res0,
    output logic [FLEN - 1:0] res1,
    output                    err
);

    logic a_less_or_equal_b;

    f_less_or_equal i_floe (
        .a   ( a                 ),
        .b   ( b                 ),
        .res ( a_less_or_equal_b ),
        .err ( err               )
    );

    always_comb begin : a_b_compare
        if ( a_less_or_equal_b ) begin
            res0 = a;
            res1 = b;
        end
        else
        begin
            res0 = b;
            res1 = a;
        end
    end

endmodule

//----------------------------------------------------------------------------
// Example - different style
//----------------------------------------------------------------------------

module sort_two_floats_array
(
    input        [0:1][FLEN - 1:0] unsorted,
    output logic [0:1][FLEN - 1:0] sorted,
    output                         err
);

    logic u0_less_or_equal_u1;

    f_less_or_equal i_floe
    (
        .a   ( unsorted [0]        ),
        .b   ( unsorted [1]        ),
        .res ( u0_less_or_equal_u1 ),
        .err ( err                 )
    );

    always_comb
        if (u0_less_or_equal_u1)
            sorted = unsorted;
        else
              {   sorted [0],   sorted [1] }
            = { unsorted [1], unsorted [0] };

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_three_floats (
    input        [0:2][FLEN - 1:0] unsorted,
    output logic [0:2][FLEN - 1:0] sorted,
    output                         err
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order.
    // The module should be combinational with zero latency.
    // The solution can use up to three instances of the "f_less_or_equal" module.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res2
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.
    logic le01, le12, le01_2;
    logic err0, err1, err2;
    logic [FLEN - 1:0] min01, max01, min12, max12;

    f_less_or_equal i0 (
        .a   (unsorted[0]),
        .b   (unsorted[1]),
        .res (le01),
        .err (err0)
    );

    assign min01 = le01 ? unsorted[0] : unsorted[1];
    assign max01 = le01 ? unsorted[1] : unsorted[0];

    f_less_or_equal i1 (
        .a   (max01),
        .b   (unsorted[2]),
        .res (le12),
        .err (err1)
    );

    assign min12 = le12 ? max01 : unsorted[2];
    assign max12 = le12 ? unsorted[2] : max01;

    f_less_or_equal i2 (
        .a   (min01),
        .b   (min12),
        .res (le01_2),
        .err (err2)
    );

    assign sorted[0] = le01_2 ? min01 : min12;
    assign sorted[1] = le01_2 ? min12 : min01;
    assign sorted[2] = max12;

    assign err = err0 | err1 | err2;



endmodule
