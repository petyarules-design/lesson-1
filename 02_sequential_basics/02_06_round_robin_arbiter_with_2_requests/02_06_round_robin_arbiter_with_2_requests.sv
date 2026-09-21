//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module round_robin_arbiter_with_2_requests
(
    input        clk,
    input        rst,
    input  [1:0] requests,
    output logic [1:0] grants
);
    // Task:
    // Implement a "arbiter" module that accepts up to two requests
    // and grants one of them to operate in a round-robin manner.
    //
    // The module should maintain an internal register
    // to keep track of which requester is next in line for a grant.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // requests -> 01 00 10 11 11 00 11 00 11 11
    // grants   -> 01 00 10 01 10 00 01 00 10 01

    logic prior;

    always_comb
    case (requests)
        2'b00: grants = 2'b00;
        2'b01: grants = 2'b01;
        2'b10: grants = 2'b10;
        2'b11: grants = prior ? 2'b10 : 2'b01;
    endcase

    always_ff @(posedge clk)
    if (rst)
        prior <= 1'b0;
    else
        case (requests)
            2'b00: prior <= prior;   
            2'b01: prior <= 1'b1;
            2'b10: prior <= 1'b0;
            2'b11: prior <= ~prior;
        endcase
endmodule

