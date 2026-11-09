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

    output logic              down_valid,
    output logic             down_last,
    output logic [width - 1:0] down_data
);
    // Task:
    // Implement a module that converts 'first' input status signal
    // to the 'last' output status signal.
    //
    // See README for full description of the task with timing diagram.

    logic [width - 1:0] data_buf;
    logic               valid_buf;

    always @(posedge clock) begin
        if (reset) begin
            data_buf  <= 0;
            valid_buf <= 0;

            down_valid <= 0;
            down_last  <= 0;
            down_data  <= 0;
        end
        else begin

            down_valid <= valid_buf && up_valid;

            if (valid_buf && up_valid) begin
                down_data <= data_buf;
                down_last <= up_first;
            end
            else begin
                down_last <= 0;
            end

            if (up_valid) begin
                data_buf  <= up_data;
                valid_buf <= 1;
            end
        end
    end
endmodule
