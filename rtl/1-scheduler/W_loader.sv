module W_loader #(
  //* ========== parameter ===========
  parameter DATA_WIDTH          = 8,
  parameter W_NUM_OF_ROWS       = 1433,
  parameter W_NUM_OF_COLS       = 16,

  parameter WEIGHT_ADDR_W       = $clog2(W_NUM_OF_ROWS * W_NUM_OF_COLS),
  parameter MULT_WEIGHT_ADDR_W  = $clog2(W_NUM_OF_ROWS),

  parameter W_ROW_WIDTH         = $clog2(W_NUM_OF_ROWS),
  parameter W_COL_WIDTH         = $clog2(W_NUM_OF_COLS)
)(
  input clk,
  input rst_n,

  input                             w_valid_i                                           ,
  output                            w_ready_o                                           ,

  input   [DATA_WIDTH-1:0]          Weight_BRAM_dout                                    ,
  output                            Weight_BRAM_enb                                     ,
  output  [WEIGHT_ADDR_W-1:0]       Weight_BRAM_addrb                                   ,

  output  [DATA_WIDTH-1:0]          mult_weight_dout              [0:W_NUM_OF_COLS-1]   ,
  input   [MULT_WEIGHT_ADDR_W-1:0]  mult_weight_addrb             [0:W_NUM_OF_COLS-1]
);

  //* ========== wire declaration ===========
  wire [WEIGHT_ADDR_W:0]        addr                                                    ;
  wire                          w_ready                                                 ;

  wire [DATA_WIDTH-1:0]         mult_weight_din               [0:W_NUM_OF_COLS-1]       ;
  wire [MULT_WEIGHT_ADDR_W-1:0] mult_weight_addra             [0:W_NUM_OF_COLS-1]       ;
  wire                          mult_weight_ena               [0:W_NUM_OF_COLS-1]       ;
  //* =======================================


  //* =========== reg declaration ===========
  reg                         w_ready_reg                                             ;
  reg [WEIGHT_ADDR_W-1:0]     addr_reg                                                ;
  reg [W_ROW_WIDTH-1:0]       row_idx                                                 ;
  reg [W_ROW_WIDTH-1:0]       row_idx_reg                                             ;
  reg [W_COL_WIDTH-1:0]       col_idx                                                 ;
  reg [W_COL_WIDTH-1:0]       col_idx_reg                                             ;
  reg                         w_valid_q1                                              ;
  reg                         w_valid_q2                                              ;
  //* =======================================


  //* ======== internal declaration =========
  genvar i, k;
  //* =======================================


  //* ============ BRAM instance ============
  generate
    for (i = 0; i < W_NUM_OF_COLS; i = i + 1) begin
      BRAM #(
        .DATA_WIDTH   (DATA_WIDTH     ),
        .DEPTH        (W_NUM_OF_ROWS  ),
        .CLK_LATENCY  (0              )
      ) u_mult_weight_BRAM (
        .clk          (clk                  ),
        .rst_n        (rst_n                ),
        .din          (mult_weight_din[i]   ),
        .addra        (mult_weight_addra[i] ),
        .ena          (mult_weight_ena[i]   ),
        .addrb        (mult_weight_addrb[i] ),
        .dout         (mult_weight_dout[i]  )
      );
    end
  endgenerate
  //* =======================================


  //* ========== output assignment ==========
  assign Weight_BRAM_addrb = addr_reg;
  assign Weight_BRAM_enb   = ~((row_idx_reg == W_NUM_OF_ROWS - 1) && (col_idx_reg == W_NUM_OF_COLS - 1)) && w_valid_i && ~w_ready_o;
  assign w_ready_o         = w_ready_reg;
  //* =======================================


  //* ====== 2 cycles delay from BRAM =======
  always @(posedge clk) begin
    w_valid_q1 <= w_valid_i;
    w_valid_q2 <= w_valid_q1;
  end
  //* =======================================


  //* ====== Generate mul-weight BRAM =======
  assign addr = (w_valid_i && addr_reg < W_NUM_OF_COLS * W_NUM_OF_ROWS) ? (addr_reg + 1) : addr_reg;
  assign col_idx = (~w_valid_q1) ? col_idx_reg : ((col_idx_reg == W_NUM_OF_COLS - 1) ? 0 : (col_idx_reg + 1));
  assign row_idx = (w_valid_q1 && col_idx_reg == W_NUM_OF_COLS - 1)
                    ? ((row_idx_reg == W_NUM_OF_ROWS - 1)
                        ? 0
                        : (row_idx_reg + 1))
                    : row_idx_reg;

  generate
    for (i = 0; i < W_NUM_OF_COLS; i = i + 1) begin
      assign mult_weight_addra[i] = row_idx_reg;
      assign mult_weight_din[i]   = Weight_BRAM_dout;
      assign mult_weight_ena[i]   = (i == col_idx_reg && ~w_ready_reg) ? 1'b1 : 1'b0;
    end
  endgenerate

  always @(posedge clk) begin
    if (!rst_n) begin
      addr_reg    <= 0;
      row_idx_reg <= 0;
      col_idx_reg <= 0;
    end else begin
      addr_reg    <= addr;
      row_idx_reg <= row_idx;
      col_idx_reg <= col_idx;
    end
  end
  //* =======================================


  //* ============= [w_ready] ===============
  assign w_ready = (row_idx_reg == W_NUM_OF_ROWS - 1) && (col_idx_reg == W_NUM_OF_COLS - 1) ? 1'b1 : w_ready_reg;

  always @(posedge clk) begin
    if (~rst_n) begin
      w_ready_reg <= 1'b0;
    end else begin
      w_ready_reg <= w_ready;
    end
  end
  //* =======================================
endmodule