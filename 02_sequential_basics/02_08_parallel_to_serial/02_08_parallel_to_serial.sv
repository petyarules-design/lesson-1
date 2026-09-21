//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module parallel_to_serial
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      parallel_valid,
    input        [width - 1:0] parallel_data,

    output logic                    busy,
    output logic               serial_valid,
    output logic               serial_data
);
    // Task:
    // Implement a module that converts multi-bit parallel value to the single-bit serial data.
    //
    // The module should accept 'width' bit input parallel data when 'parallel_valid' input is asserted.
    // At the same clock cycle as 'parallel_valid' is asserted, the module should output
    // the least significant bit of the input data. In the following clock cycles the module
    // should output all the remaining bits of the parallel_data.
    // Together with providing correct 'serial_data' value, module should also assert the 'serial_valid' output.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

    logic [3:0]              counter;
    logic [7:0]        stored_data;  

    assign serial_valid = parallel_valid | busy;

 
    assign serial_data = (parallel_data[0] & parallel_valid & ~busy) | (stored_data[counter] & busy);

    always_ff @(posedge clk) begin
        if (rst) begin
            stored_data <= '0;      
            counter <= '0;
            busy <= '0;
        end
        else if (parallel_valid && !busy) begin
            stored_data <= parallel_data;   
            counter <= 1;               
            busy <= 1;       
        end
        else if (busy) begin
            if (counter == 7)       
                busy <= 0;             
            else
                counter <= counter + 1;     
        end
    end

endmodule
