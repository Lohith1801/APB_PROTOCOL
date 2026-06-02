module Master #(parameter ADDR = 8, DATA_WIDTH = 8, ADDR_WIDTH = $clog2(ADDR)) (
  input PCLK, PRESETn, transfer, READ_WRITE, PREADY,  
  input [ADDR_WIDTH -1: 0] apb_write_paddr, apb_read_paddr,
  input [DATA_WIDTH -1 :0] apb_write_data, 
  output reg [DATA_WIDTH-1:0] apb_read_data,
  input [DATA_WIDTH -1 :0] PRDATA,
  input SLVERR,
  output reg PSEL1, PENABLE, PWRITE,
  output reg [ADDR_WIDTH -1: 0] PADDR,
  output reg [DATA_WIDTH -1: 0] PWDATA
);
  
  localparam IDEAL = 2'b00, SETUP = 2'b01, ACCESS = 2'b10;
  reg [1:0] cur, nxt;
  
  
  always @(posedge PCLK or negedge PRESETn) begin
    if (~PRESETn) begin
      cur <= IDEAL; 
      apb_read_data <= 0;
    end
    else begin
      cur <= nxt;
    end
  end

  always @(*) begin
    case (cur) 
      IDEAL:  nxt = (transfer) ? SETUP : IDEAL;
      SETUP:  nxt = ACCESS;
      ACCESS: nxt = (PREADY) ? ((transfer) ? SETUP : IDEAL) : ACCESS;
      default: nxt = IDEAL;
    endcase
  end
  
  
  always @(*) begin
    
    PSEL1   = 1'b0;
    PENABLE = 1'b0;
    PWRITE  = 1'b0;
    PADDR   = {ADDR_WIDTH{1'b0}};
    PWDATA  = {DATA_WIDTH{1'b0}};
    apb_read_data = PRDATA;
    
    case (cur)
      IDEAL: begin 
        PSEL1   = 1'b0;
        PENABLE = 1'b0;
      end
            
      SETUP: begin 
        PSEL1   = 1'b1;
        PENABLE = 1'b0;
        PWRITE  = READ_WRITE;
        PADDR   = (READ_WRITE) ? apb_write_paddr : apb_read_paddr;
        PWDATA  = (READ_WRITE) ? apb_write_data : {DATA_WIDTH{1'b0}};
      end       

      ACCESS: begin 
        PSEL1   = 1'b1;
        PENABLE = 1'b1;
        PWRITE  = READ_WRITE;
        PADDR   = (READ_WRITE) ? apb_write_paddr : apb_read_paddr;
        PWDATA  = (READ_WRITE) ? apb_write_data : {DATA_WIDTH{1'b0}};
      end 

      default: begin 
        PSEL1   = 1'b0;
        PENABLE = 1'b0;
      end
    endcase        
  end

endmodule
