//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module generate_tokens_by_number_with_flow_control
#(
    WIDTH = 4
)
(
    input                 clk,
    input                 rst,

    input                 up_valid,
    output                up_ready,
    input  [WIDTH-1 : 0]  n_tokens,

    output                down_valid,
    input                 down_ready,
    output                down_token
);

    // Task:
    // Implement a module that recive an integer N_tokens and generate N_tokens pulses. The module must use signals valid-ready for
    // transfer tokens.

    logic [WIDTH-1 : 0] cnt = '0;

    assign up_ready   = (cnt == '0);
    assign down_valid = (cnt != '0);
    assign down_token = down_valid;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= '0;
        end
        else
        begin
            if (up_valid && up_ready)
            begin
                cnt <= n_tokens;
            end
            else if (down_ready && down_valid)
            begin
                cnt <= cnt - 1'b1;
            end
        end
    end

endmodule
