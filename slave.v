module slave #(parameter ADDR = 8, DATA_WIDTH = 8, ADDR_WIDTH = $clog2(ADDR), RAM_SIZE = 20) (
  input PCLK, PRESETn,   
  input PSEL1, PENABLE, PWRITE,
  input [ADDR_WIDTH -1: 0]PADDR,
  input [DATA_WIDTH -1: 0]PWDATA, 
  output reg [DATA_WIDTH -1: 0]PRDATA,
  output PREADY,
  output reg PSLVERR
);
  
  localparam IDEAL = 2'b00, SETUP = 2'b01, ACCESS = 2'b10;
  reg [1:0] cur, nxt;
  integer i;
  
  //memory initialization
  reg [DATA_WIDTH - 1: 0] mem[0:RAM_SIZE-1];

  always @(posedge PCLK or negedge PRESETn) begin
    if (~PRESETn) begin
      cur <= IDEAL; 
      PRDATA <= {DATA_WIDTH{1'b0}};
      for(i=0;i<RAM_SIZE;i=i+1) begin
        mem[i] = {DATA_WIDTH{1'b0}};
      end
    end
    else begin
      cur <= nxt;
    end
  end
  
  always @(*) begin
    case (cur) 
      IDEAL:  nxt = (PSEL1==1 && PENABLE== 0) ? SETUP : IDEAL;
      SETUP:  nxt = ACCESS;
      ACCESS: begin
        		if(PSEL1 ==0 && PENABLE== 0) begin
        		  nxt = IDEAL;
        		end
        		else if(PSEL1 ==1 && PENABLE== 0) begin
        		  nxt = SETUP;
        		end
        		else
        		  nxt = ACCESS;
     		 end
      default: nxt = IDEAL;
    endcase
  end
  always @(cur) begin
    PSLVERR = 1'b0;
    case (cur)
      IDEAL: begin 
       PRDATA  = PRDATA;
      end
            
      SETUP: begin 
        PRDATA  = PRDATA;
      end       

      ACCESS: begin 
        if(PWRITE) begin
          if(PADDR < ADDR) begin
            PSLVERR = 0;
            mem[PADDR] = PWDATA;
          end
          else
            PSLVERR = 1;
        end
        else begin
          
          if(PADDR < ADDR) begin
            PSLVERR = 0;
            PRDATA  = mem[PADDR];
          end
          else
            PSLVERR = 1;
        end
      end
      default: nxt = IDEAL;
    endcase        
  end
  
  
  assign PREADY = (cur == ACCESS);
  
 endmodule
