//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
    // Task:
    // Implement a module that converts single-bit serial data to the multi-bit parallel value.
    //
    // The module should accept one-bit values with valid interface in a serial manner.
    // After accumulating 'width' bits and receiving last 'serial_valid' input,
    // the module should assert the 'parallel_valid' at the same clock cycle
    // and output 'parallel_data' value.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

    logic [3:0] counter;
    logic [7:0] parallel_data_1;

    assign parallel_data = {serial_data, parallel_data_1[7:1]};

    always_comb begin 
        if (counter == 7 & serial_valid)
            parallel_valid = 1'b1;
        else 
            parallel_valid = 1'b0;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            parallel_data_1 <= '0;
            counter <= '0;
        end
        else if (serial_valid) begin
            parallel_data_1 <= {serial_data, parallel_data_1[7:1]};
            if (counter == 7) 
                counter <= '0;
            else 
            counter <= counter + 1;
    end
    end


endmodule
