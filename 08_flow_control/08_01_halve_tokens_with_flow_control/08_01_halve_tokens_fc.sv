//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module halve_tokens_with_flow_control
(
    input  clk,
    input  rst,

    input        up_valid,
    output logic up_ready,
    input        up_token,

    output logic down_valid,
    input        down_ready,
    output logic down_data
);

    // Task:
    // Implement a serial module that reduces amount of incoming '1' tokens by half.
    // The module must use the ready-valid protocol.
    //
    //  Expected behavior of the module
    //  1) When the input signals are up_token and up_valid is high, the signal (token) is processed.
    //  2) Every second signal received for processing is sent to the output of the module.
    //  3) When the module cannot process the signal, it sets the up_ready signal to a low level.
    //
    // Example:
    // down_ready     ->   1111_1111_1111_0000
    // up_token       ->   1101_0100_1111_1111
    // up_valid       ->   1111_1111_0101_1111
    // down_valid     ->   1111_1111_1111_1000
    // down_data      ->   0100_0100_0001_0000
    // up_ready       ->   1111_1111_0101_1000

    logic parity;
    logic buf_valid;
    logic buf_data;
    logic filtered;
    logic in_fire;

    assign filtered   = up_token & parity;
    assign up_ready   = ~buf_valid & up_valid & (down_ready | ~filtered);

    assign in_fire    = up_valid & up_ready;
    assign down_valid = buf_valid | in_fire;
    assign down_data  = buf_valid ? buf_data : (in_fire ? filtered : 1'b0);

    always_ff @(posedge clk) begin
        if (rst) begin
            parity    <= 1'b0;
            buf_valid <= 1'b0;
            buf_data  <= 1'b0;
        end
        else begin
            if (in_fire & up_token)
                parity <= ~parity;

            if (buf_valid) begin
                if (down_ready)
                    buf_valid <= 1'b0;
            end
            else if (in_fire & ~down_ready) begin
                buf_valid <= 1'b1;
                buf_data  <= filtered;
            end
        end
    end

endmodule
