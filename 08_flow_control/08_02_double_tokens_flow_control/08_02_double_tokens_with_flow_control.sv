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

    wire up_hs   = up_valid & up_ready;
    wire down_hs = down_valid & down_ready;

    assign down_valid = active;
    assign down_data  = data_r;
    assign up_ready   = !active & !blocked;

    always_ff @(posedge clk) begin
        if (rst) begin
            active  <= 0;
            data_r  <= 0;
            dup_r   <= 0;
            cnt     <= 0;
            blocked <= 0;
        end
        else
        begin
            if (blocked)
            begin
                if (down_ready)
                begin
                    blocked <= 0;
                    cnt <= 0;
                end
            end
            else if (up_hs)
            begin
                if (!up_token)
                    cnt <= 0;
                else if (cnt >= 8'd100)
                    blocked <= 1;
                else
                    cnt <= cnt + 1;
            end

            if (active)
            begin
                if (down_hs)
                begin
                    if (dup_r)
                        dup_r  <= 0;
                    else
                        active <= 0;
                end
            end
            else if (up_hs)
            begin
                active <= 1;
                data_r <= up_token;
                dup_r  <= up_token;
            end
        end
    end

endmodule
