//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux
(
  input  d0, d1,
  input  sel,
  output y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module or_gate_using_mux
(
    input  a,
    input  b,
    output o
);

  // Task:

  // Implement or gate using instance(s) of mux,
  // constants 0 and 1, and wire connections
  logic d0 = 1'b0;
  logic d1 = 1'b1;
  wire y1;

  
  mux or1(
    .d0(b),
    .d1(d1),
    .sel(a),
    .y(y1)
  );

  mux or2(
    .d0(y1),
    .d1(d1),
    .sel(b),
    .y(o)
  );



endmodule
