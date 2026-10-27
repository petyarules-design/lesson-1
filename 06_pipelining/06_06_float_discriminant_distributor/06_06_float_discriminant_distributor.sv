module float_discriminant_distributor (
    input                           clk,
    input                           rst,

    input                           arg_vld,
    input        [FLEN - 1:0]       a,
    input        [FLEN - 1:0]       b,
    input        [FLEN - 1:0]       c,

    output logic                    res_vld,
    output logic [FLEN - 1:0]       res,
    output logic                    res_negative,
    output logic                    err,

    output logic                    busy
);

    // Task:
    //
    // Implement a module that will calculate the discriminant based
    // on the triplet of input number a, b, c. The module must be pipelined.
    // It should be able to accept a new triple of arguments on each clock cycle
    // and also, after some time, provide the result on each clock cycle.
    // The idea of the task is similar to the task 04_11. The main difference is
    // in the underlying module 03_08 instead of formula modules.
    //
    // Note 1:
    // Reuse your file "03_08_float_discriminant.sv" from the Homework 03.
    //
    // Note 2:
    // Latency of the module "float_discriminant" should be clarified from the waveform.

    localparam NUM_BLOCKS = 60;

    logic [FLEN-1:0] a_in  [NUM_BLOCKS];
    logic [FLEN-1:0] b_in  [NUM_BLOCKS];
    logic [FLEN-1:0] c_in  [NUM_BLOCKS];
    logic            vld_in [NUM_BLOCKS];

    logic [FLEN-1:0] res_out [NUM_BLOCKS];
    logic            res_vld_out [NUM_BLOCKS];
    logic            res_neg_out [NUM_BLOCKS];
    logic            err_out [NUM_BLOCKS];
    logic            busy_out [NUM_BLOCKS];

    logic [7:0] idx; 

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
            for (int i = 0; i < NUM_BLOCKS; i++) vld_in[i] <= 1'b0;
            
            if (arg_vld) begin
                a_in[idx]   <= a;
                b_in[idx]   <= b;
                c_in[idx]   <= c;
                vld_in[idx] <= 1'b1;

                if (idx == NUM_BLOCKS - 1) idx <= 0;
                else                       idx <= idx + 1;
            end
        end
    end

    generate
        for (genvar i = 0; i < NUM_BLOCKS; i++) begin : gen_workers
            float_discriminant worker (
                .clk(clk), .rst(rst), .arg_vld(vld_in[i]),
                .a(a_in[i]), .b(b_in[i]), .c(c_in[i]),
                .res_vld(res_vld_out[i]), .res(res_out[i]),
                .res_negative(res_neg_out[i]), .err(err_out[i]), .busy(busy_out[i])
            );
        end
    endgenerate

    logic            res_vld_c;
    logic [FLEN-1:0] res_c;
    logic            res_neg_c;
    logic            err_c;

    always_comb begin
        logic found;
        found = 1'b0;
        res_vld_c = 1'b0; res_c = '0; res_neg_c = 1'b0; err_c = 1'b0;
        
        for (int i = 0; i < NUM_BLOCKS; i++) begin
            if (res_vld_out[i] && !found) begin
                found = 1'b1;
                res_vld_c = 1'b1;
                res_c = res_out[i];
                res_neg_c = res_neg_out[i];
                err_c = err_out[i];
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            res_vld      <= 1'b0;
            res          <= '0;
            res_negative <= 1'b0;
            err          <= 1'b0;
        end
        else begin
            res_vld      <= res_vld_c;
            res          <= res_c;
            res_negative <= res_neg_c;
            err          <= err_c;
        end
    end

    assign busy = 1'b0; 

endmodule
