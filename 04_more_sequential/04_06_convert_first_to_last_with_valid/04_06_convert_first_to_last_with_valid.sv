//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module conv_first_to_last_no_ready
# (
    parameter width = 8
)
(
    input                clock,
    input                reset,

    input                up_valid,
    input                up_first,
    input  [width - 1:0] up_data,

    output               down_valid,
    output               down_last,
    output [width - 1:0] down_data
);
    // Task:
    // Implement a module that converts 'first' input status signal
    // to the 'last' output status signal.
    //
    // See README for full description of the task with timing diagram.
    logic               valid_reg;
    logic [width - 1:0] data_reg;
    logic               last_reg;

    assign down_valid = valid_reg;
    assign down_data  = data_reg;
    assign down_last  = up_valid ? up_first : last_reg;

    always_ff @(posedge clock) begin
        if (reset) begin
            valid_reg <= 1'b0;
            data_reg  <= '0;
            last_reg  <= 1'b0;
        end
        else begin
            valid_reg <= up_valid;
            data_reg  <= up_data;
            if (up_valid)
                last_reg <= up_first;
        end
    end

endmodule
