module \$_MUX_ (
    output Y,
    input A,
    input B,
    input S
    );
  sky130_fd_sc_hd__mux2_2 _TECHMAP_MUX (
      .X(Y),
      .A0(A),
      .A1(B),
      .S(S)
  );
endmodule