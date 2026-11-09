//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module gearbox_1_to_2_fc
# (
    parameter width = 8
)
(
    input                   clk,
    input                   rst,
    input                   up_valid,
    output                  up_ready,
    input  [   width - 1:0] up_data,
    output                  down_valid,
    output [ 2*width - 1:0] down_data,
    input                   down_ready
);

    // Task:
    // Implement a module that generates one token from of two tokens.
    // Example:
    // "01", "10" => "0110"
    //
    // The module must use signals valid-ready for transfer tokens.

    logic               cnt;
    logic [width-1:0]   buf_data;
    logic               out_valid;
    logic [2*width-1:0] out_data;

    assign up_ready   = !out_valid || down_ready;

    assign down_valid = out_valid;
    assign down_data  = out_data;

    wire up_hs   = up_valid && up_ready;
    wire down_hs = down_valid && down_ready;

    always_ff @(posedge clk) begin
        if (rst) begin
            cnt       <= 1'b0;
            buf_data  <= '0;
            out_valid <= 1'b0;
            out_data  <= '0;
        end
        else
        begin
            if (up_hs)
            begin
                if (!cnt) begin
                    buf_data <= up_data;
                end
                else begin
                    out_data <= {buf_data, up_data};
                end
                cnt <= ~cnt;
            end

            if (up_hs && cnt) begin
                out_valid <= 1'b1;
            end
            else if (down_hs)
            begin
                out_valid <= 1'b0;
            end
        end
    end

endmodule
