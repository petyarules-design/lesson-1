//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module halve_tokens
(
    input  clk,
    input  rst,
    input  a,
    output logic b
);
    // Task:
    // Implement a serial module that reduces amount of incoming '1' tokens by half.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 110_011_101_000_1111
    // b -> 010_001_001_000_0101 
    logic chng;

    assign b = a & chng;

    always_ff @(posedge clk) 
        if(rst)
            chng <= 0;
        else 
        if (a)
            chng <= ~ chng;

endmodule
