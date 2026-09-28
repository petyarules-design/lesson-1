//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module gearbox_1_to_2
# (
    parameter width = 0
)
(
    input                    clk,
    input                    rst,

    input                    up_vld,    // upstream
    input  [    width - 1:0] up_data,

    output                   down_vld,  // downstream
    output [2 * width - 1:0] down_data
);
    // Task:
    // Implement a module that transforms a stream of data
    // from 'width' to the 2*'width' data width.
    //
    // The module should be capable to accept new data at each
    // clock cycle and produce concatenated 'down_data'
    // at each second clock cycle.
    //
    // The module should work properly with reset 'rst'
    // and valid 'vld' signals
    logic sig;
    logic [width - 1:0] b_ff;

    assign down_vld = up_vld & sig;
    assign down_data = down_vld ? {b_ff , up_data} : 0;

    always_ff @( posedge clk ) begin 
        if (rst) begin
            b_ff <= 0;
            sig <= 0;
        end
        else if (up_vld & ~sig) begin
            b_ff <= up_data;
            sig <= 1;
        end
        else if (up_vld & sig) 
            sig <=0; 
    end



endmodule
