//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module convert_first_to_last_with_flow_control
# (
    parameter width = 8
)
(
    input                clock,
    input                reset,

    input                up_valid,
    output               up_ready,
    input                up_first,
    input  [width - 1:0] up_data,

    output               down_valid,
    input                down_ready,
    output               down_last,
    output [width - 1:0] down_data
);

    // Task:
    // Implement a module that converts 'first' input status signal
    // to the 'last' output status signal.
    //
    // The module should respect and set correct valid and ready signals
    // to control flow from the upstream and to the downstream.

    logic             reg_valid;
    logic [width-1:0] reg_data;

    assign up_ready   = !reg_valid || down_ready;

    assign down_valid = reg_valid && up_valid;
    assign down_data  = reg_data;

    assign down_last  = reg_valid && up_valid && up_first;

    always_ff @(posedge clock) begin
        if (reset) begin
            reg_valid <= 1'b0;
            reg_data  <= '0;
        end

        else if (up_valid && up_ready) begin
            reg_valid <= 1'b1;
            reg_data  <= up_data;
        end
        else if (down_valid && down_ready) begin
            reg_valid <= 1'b0;
        end
    end


endmodule
