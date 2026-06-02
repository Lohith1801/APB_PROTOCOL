module ABP4_MUX #(parameter ADDR = 3, DATA_WIDTH = 8)
  
  (input sel,
    input MST_PSEL, SLV_PREADY0, SLV_PREADY1, SLVERR0, SLVERR1,
   output MST_PREADY, 
   input [DATA_WIDTH -1: 0]SLV_PRDATA0, SLV_PRDATA1, 
   output SLV_PSEL0, SLV_PSEL1 ,SLVERR,
   output [DATA_WIDTH -1: 0]MST_PRDATA
  );
  
  assign SLV_PSEL0 = (~sel)?MST_PSEL:1'b0;
  assign SLV_PSEL1 = (sel)?MST_PSEL:1'b0;
  assign MST_PREADY = (~sel)?SLV_PREADY0:SLV_PREADY1;
  assign MST_PRDATA = (~sel)?SLV_PRDATA0:SLV_PRDATA1;
  assign SLVERR = (~sel)?SLVERR0:SLVERR1;
  
endmodule
  
  
