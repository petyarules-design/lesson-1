//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module gearbox_2_to_1_fc
# (
    parameter width = 8
)
(
    input                    clk,
    input                    rst,

    input                    up_valid,
    output                   up_ready,
    input   [ 2*width - 1:0] up_data,

    output                   down_valid,
    input                    down_ready,
    output  [   width - 1:0] down_data
);

    // Task:
    // Implement a module that generates tokens from of one token.
    // Example:
    // "0110" => "01", "10"
    //
    // The module must use signals valid-ready for transfer tokens.

    logic               valid;
    logic               half;
    logic [2*width-1:0] buf_data;

    assign up_ready   = !valid || (down_ready && half);
    assign down_valid = valid;
    assign down_data  = half ? buf_data[width-1:0] : buf_data[2*width-1:width];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            valid    <= 1'b0;
            half     <= 1'b0;
            buf_data <= '0;
        end
        else begin
            if (up_valid && up_ready) begin
                buf_data <= up_data;
                valid    <= 1'b1;
                half     <= 1'b0;
            end
            else if (down_valid && down_ready) begin
                if (half)
                    valid <= 1'b0;
                else
                    half  <= 1'b1;
            end
        end
    end

endmodule
