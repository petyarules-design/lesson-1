module sqrt_formula_distributor
# (
    parameter int formula = 1,
              impl    = 1
)
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output logic       res_vld,
    output logic [31:0] res
);

    // Task:
    //
    // Implement a module that will calculate formula 1 or formula 2
    // based on the parameter values. The module must be pipelined.
    // It should be able to accept new triple of arguments a, b, c arriving
    // at every clock cycle.
    //
    // The idea of the task is to implement hardware task distributor,
    // that will accept triplet of the arguments and assign the task
    // of the calculation formula 1 or formula 2 with these arguments
    // to the free FSM-based internal module.
    //
    // The first step to solve the task is to fill 03_04 and 03_05 files.
    //
    // Note 1:
    // Latency of the module "formula_1_isqrt" should be clarified from the corresponding waveform
    // or simply assumed to be equal 50 clock cycles.
    //
    // Note 2:
    // The task assumes idealized distributor (with 50 internal computational blocks),
    // because in practice engineers rarely use more than 10 modules at ones.
    // Usually people use 3-5 blocks and utilize stall in case of high load.
    //
    // Hint:
    // Instantiate sufficient number of "formula_1_impl_1_top", "formula_1_impl_2_top",
    // or "formula_2_top" modules to achieve desired performance.

    localparam NUM_BLOCKS = 50; 

    logic [31:0] a_in  [NUM_BLOCKS];
    logic [31:0] b_in  [NUM_BLOCKS];
    logic [31:0] c_in  [NUM_BLOCKS];
    logic        vld_in [NUM_BLOCKS];

    logic [31:0] res_out [NUM_BLOCKS];
    logic        vld_out [NUM_BLOCKS];

    logic [5:0] idx; 

    always_ff @(posedge clk) begin
        if (rst) begin
            idx <= 0;
            for (int i = 0; i < NUM_BLOCKS; i++) begin
                vld_in[i] <= 1'b0;
                a_in[i]   <= '0;
                b_in[i]   <= '0;
                c_in[i]   <= '0;
            end
        end
        else begin
            for (int i = 0; i < NUM_BLOCKS; i++) begin
                vld_in[i] <= 1'b0;
            end

            if (arg_vld) begin
                a_in[idx]   <= a;      
                b_in[idx]   <= b;       
                c_in[idx]   <= c;       
                vld_in[idx] <= 1'b1;

                if (idx == NUM_BLOCKS - 1)
                    idx <= 0;
                else
                    idx <= idx + 1;
            end
        end
    end

    generate
        if (formula == 1 && impl == 1) begin : gen_f1_impl_1
            for (genvar i = 0; i < NUM_BLOCKS; i++) begin : gen_workers
                formula_1_impl_1_top worker (
                    .clk(clk), .rst(rst), .arg_vld(vld_in[i]),
                    .a(a_in[i]), .b(b_in[i]), .c(c_in[i]),
                    .res_vld(vld_out[i]), .res(res_out[i])
                );
            end
        end
        else if (formula == 1 && impl == 2) begin : gen_f1_impl_2
            for (genvar i = 0; i < NUM_BLOCKS; i++) begin : gen_workers
                formula_1_impl_2_top worker (
                    .clk(clk), .rst(rst), .arg_vld(vld_in[i]),
                    .a(a_in[i]), .b(b_in[i]), .c(c_in[i]),
                    .res_vld(vld_out[i]), .res(res_out[i])
                );
            end
        end
        else begin : gen_f2
            for (genvar i = 0; i < NUM_BLOCKS; i++) begin : gen_workers
                formula_2_top worker (
                    .clk(clk), .rst(rst), .arg_vld(vld_in[i]),
                    .a(a_in[i]), .b(b_in[i]), .c(c_in[i]),
                    .res_vld(vld_out[i]), .res(res_out[i])
                );
            end
        end
    endgenerate
    
    logic        res_vld_c;
    logic [31:0] res_c;

    always_comb begin
        res_vld_c = 1'b0;
        res_c     = '0;

        for (int i = 0; i < NUM_BLOCKS; i++) begin
            if (vld_out[i] && !res_vld_c) begin 
                res_vld_c = 1'b1;
                res_c     = res_out[i];
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            res_vld <= 1'b0;
            res     <= '0;
        end
        else begin
            res_vld <= res_vld_c;
            res     <= res_c;
        end
    end

endmodule
