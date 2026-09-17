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

module and_gate_using_mux
(
    input  a,
    input  b,
    output o
);

  // Task:
  // Implement and gate using instance(s) of mux,
  // constants 0 and 1, and wire connections
  
  logic d0 = 1'b0;
  logic d1 = 1'b1;
  wire y1;

  
  mux and1(
    .d0(d0),
    .d1(b),
    .sel(a),
    .y(y1)
  );

  mux and2(
    .d0(d0),
    .d1(y1),
    .sel(b),
    .y(o)
  );


endmodule
