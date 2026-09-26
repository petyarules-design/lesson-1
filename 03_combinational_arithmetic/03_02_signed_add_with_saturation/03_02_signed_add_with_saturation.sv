//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add
(
  input  [3:0] a, b,
  output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module signed_add_with_saturation
(
  input  [3:0] a, b,
  output logic [3:0] sum
);

  // Task:
  //
  // Implement a module that adds two signed numbers with saturation.
  //
  // "Adding with saturation" means:
  //
  // When the result does not fit into 4 bits,
  // and the arguments are positive,
  // the sum should be set to the maximum positive number.
  //
  // When the result does not fit into 4 bits,
  // and the arguments are negative,
  // the sum should be set to the minimum negative number.

  logic [3:0] sum_check;
  assign sum_check = a + b;

  logic overflow;

  assign  overflow = (a[3]&b[3]&(~sum_check[3]))|(~a[3]&~b[3]&sum_check[3]) ? 1'b1 : 1'b0;

  always_comb 
    case(overflow)
      1'b1: if (a[3]&b[3]) sum = 4'b1000; else sum = 4'b0111;
      default: sum = a + b;
    endcase




endmodule
