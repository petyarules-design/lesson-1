//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module double_tokens_with_flow_control
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
  // Implement module double input signals (tokens). The module must use signals valid-ready for
  // transfer tokens. If the module receives more than 100 sequential tokens then it must set up_ready = 0;

    logic       active, data_r, dup_r, blocked;
    logic [7:0] cnt;

    wire up_hs   = up_valid && up_ready;
    wire down_hs = down_valid && down_ready;

    assign down_valid = active;
    assign down_data  = data_r;
    assign up_ready   = !active && !blocked;

    always_ff @(posedge clk)
        if (rst)
            active <= 0;
        else if (active && down_hs && !dup_r)
            active <= 0;
        else if (!active && up_hs)
            active <= 1;

    always_ff @(posedge clk)
        if (rst)
            data_r <= 0;
        else if (!active && up_hs)
            data_r <= up_token;

    always_ff @(posedge clk)
        if (rst)
            dup_r <= 0;
        else if (active && down_hs && dup_r)
            dup_r <= 0;
        else if (!active && up_hs)
            dup_r <= up_token;

    always_ff @(posedge clk)
        if (rst)
            cnt <= 0;
        else if (blocked && down_ready)
            cnt <= 0;
        else if (!blocked && up_hs)
            if (!up_token)
                cnt <= 0;
            else if (cnt < 8'd100)
                cnt <= cnt + 1;

    always_ff @(posedge clk)
        if (rst)
            blocked <= 0;
        else if (blocked && down_ready)
            blocked <= 0;
        else if (!blocked && up_hs && up_token && (cnt >= 8'd100))
            blocked <= 1;

endmodule
