`include "./../others/pkgs/params_pkg.sv"

module mem_ctrl import params_pkg::*;
(
  input                             clk                         ,
  input                             rst_n                       ,

  input   [COL_IDX_WIDTH-1:0]       H_col_idx_BRAM_din          ,
  input                             H_col_idx_BRAM_ena          ,
  input   [COL_IDX_ADDR_W-1:0]      H_col_idx_BRAM_addra        ,
  input   [COL_IDX_ADDR_W-1:0]      H_col_idx_BRAM_addrb        ,
  output  [COL_IDX_WIDTH-1:0]       H_col_idx_BRAM_dout         ,
  input                             H_col_idx_BRAM_load_done    ,

  input   [VALUE_WIDTH-1:0]         H_value_BRAM_din            ,
  input                             H_value_BRAM_ena            ,
  input   [VALUE_ADDR_W-1:0]        H_value_BRAM_addra          ,
  input   [VALUE_ADDR_W-1:0]        H_value_BRAM_addrb          ,
  output  [VALUE_WIDTH-1:0]         H_value_BRAM_dout           ,
  input                             H_value_BRAM_load_done      ,

  input   [NODE_INFO_WIDTH-1:0]     H_node_info_BRAM_din        ,
  input                             H_node_info_BRAM_ena        ,
  input   [NODE_INFO_ADDR_W-1:0]    H_node_info_BRAM_addra      ,
  input   [NODE_INFO_ADDR_W-1:0]    H_node_info_BRAM_addrb      ,
  output  [NODE_INFO_WIDTH-1:0]     H_node_info_BRAM_dout       ,
  output  [NODE_INFO_WIDTH-1:0]     H_node_info_BRAM_dout_nxt   ,
  input                             H_node_info_BRAM_load_done  ,

  input   [DATA_WIDTH-1:0]          Weight_BRAM_din             ,
  input                             Weight_BRAM_ena             ,
  input   [WEIGHT_ADDR_W-1:0]       Weight_BRAM_addra           ,
  input   [WEIGHT_ADDR_W-1:0]       Weight_BRAM_addrb           ,
  output  [DATA_WIDTH-1:0]          Weight_BRAM_dout            ,
  input                             Weight_BRAM_load_done       ,

  input   [DATA_WIDTH-1:0]          a_BRAM_din                  ,
  input                             a_BRAM_ena                  ,
  input   [A_ADDR_W-1:0]            a_BRAM_addra                ,
  input   [A_ADDR_W-1:0]            a_BRAM_addrb                ,
  output  [DATA_WIDTH-1:0]          a_BRAM_dout                 ,
  input                             a_BRAM_load_done            ,

  input   [WH_WIDTH-1:0]            WH_1_BRAM_din               ,
  input                             WH_1_BRAM_ena               ,
  input   [WH_1_ADDR_W-1:0]         WH_1_BRAM_addra             ,
  output  [WH_WIDTH-1:0]            WH_1_BRAM_dout              ,
  input   [WH_1_ADDR_W-1:0]         WH_1_BRAM_addrb             ,

  input   [WH_WIDTH-1:0]            WH_2_BRAM_din               ,
  input                             WH_2_BRAM_ena               ,
  input   [WH_2_ADDR_W-1:0]         WH_2_BRAM_addra             ,
  output  [WH_WIDTH-1:0]            WH_2_BRAM_dout              ,
  input   [WH_2_ADDR_W-1:0]         WH_2_BRAM_addrb             ,

  input   [AGGR_WIDTH-1:0]          aggr_BRAM_din               ,
  input                             aggr_BRAM_ena               ,
  input   [AGGR_ADDR_W-1:0]         aggr_BRAM_addra             ,
  output  [AGGR_WIDTH-1:0]          aggr_BRAM_dout              ,
  input   [AGGR_ADDR_W-1:0]         aggr_BRAM_addrb             ,

  input   [SOFTMAX_WIDTH-1:0]       softmax_FIFO_din            ,
  output  [SOFTMAX_WIDTH-1:0]       softmax_FIFO_dout           ,
  input                             softmax_FIFO_wr_valid       ,
  input                             softmax_FIFO_rd_valid       ,
  output                            softmax_FIFO_empty          ,
  output                            softmax_FIFO_full           ,

  input   [AGGR_WIDTH-1:0]          aggr_FIFO_din               ,
  output  [AGGR_WIDTH-1:0]          aggr_FIFO_dout              ,
  input                             aggr_FIFO_wr_valid          ,
  input                             aggr_FIFO_rd_valid          ,
  output                            aggr_FIFO_empty             ,
  output                            aggr_FIFO_full
);

  //* ========================= MEMORY =========================
  (* dont_touch = "yes" *)
  BRAM #(
    .DATA_WIDTH   (COL_IDX_WIDTH        ),
    .DEPTH        (COL_IDX_DEPTH        ),
    .CLK_LATENCY  (1                    )
  ) u_H_col_idx_BRAM (
    .clk          (clk                  ),
    .rst_n        (rst_n                ),
    .din          (H_col_idx_BRAM_din   ),
    .addra        (H_col_idx_BRAM_addra ),
    .ena          (H_col_idx_BRAM_ena   ),
    .addrb        (H_col_idx_BRAM_addrb ),
    .dout         (H_col_idx_BRAM_dout  )
  );

  (* dont_touch = "yes" *)
  BRAM #(
    .DATA_WIDTH   (VALUE_WIDTH          ),
    .DEPTH        (VALUE_DEPTH          ),
    .CLK_LATENCY  (1                    )
  ) u_H_value_BRAM (
    .clk          (clk                  ),
    .rst_n        (rst_n                ),
    .din          (H_value_BRAM_din     ),
    .addra        (H_value_BRAM_addra   ),
    .ena          (H_value_BRAM_ena     ),
    .addrb        (H_value_BRAM_addrb   ),
    .dout         (H_value_BRAM_dout    )
  );

  (* dont_touch = "yes" *)
  modified_BRAM #(
    .DATA_WIDTH   (NODE_INFO_WIDTH            ),
    .DEPTH        (NODE_INFO_DEPTH            ),
    .CLK_LATENCY  (1                          )
  ) u_H_node_info_BRAM (
    .clk          (clk                        ),
    .rst_n        (rst_n                      ),
    .din          (H_node_info_BRAM_din       ),
    .addra        (H_node_info_BRAM_addra     ),
    .ena          (H_node_info_BRAM_ena       ),
    .addrb        (H_node_info_BRAM_addrb     ),
    .dout         (H_node_info_BRAM_dout      ),
    .dout_nxt     (H_node_info_BRAM_dout_nxt  )
  );

  (* dont_touch = "yes" *)
  BRAM #(
    .DATA_WIDTH   (DATA_WIDTH           ),
    .DEPTH        (WEIGHT_DEPTH         ),
    .CLK_LATENCY  (1                    )
  ) u_Weight_BRAM (
    .clk          (clk                  ),
    .rst_n        (rst_n                ),
    .din          (Weight_BRAM_din      ),
    .addra        (Weight_BRAM_addra    ),
    .ena          (Weight_BRAM_ena      ),
    .addrb        (Weight_BRAM_addrb    ),
    .dout         (Weight_BRAM_dout     )
  );

  (* dont_touch = "yes" *)
  BRAM #(
    .DATA_WIDTH   (WH_WIDTH             ),
    .DEPTH        (WH_1_DEPTH           ),
    .CLK_LATENCY  (1                    )
  ) u_WH_1_BRAM (
    .clk          (clk                  ),
    .rst_n        (rst_n                ),
    .din          (WH_1_BRAM_din        ),
    .addra        (WH_1_BRAM_addra      ),
    .ena          (WH_1_BRAM_ena        ),
    .addrb        (WH_1_BRAM_addrb      ),
    .dout         (WH_1_BRAM_dout       )
  );

  (* dont_touch = "yes" *)
  BRAM #(
    .DATA_WIDTH   (WH_WIDTH             ),
    .DEPTH        (WH_2_DEPTH           ),
    .CLK_LATENCY  (1                    )
  ) u_WH_2_BRAM (
    .clk          (clk                  ),
    .rst_n        (rst_n                ),
    .din          (WH_2_BRAM_din        ),
    .addra        (WH_2_BRAM_addra      ),
    .ena          (WH_2_BRAM_ena        ),
    .addrb        (WH_2_BRAM_addrb      ),
    .dout         (WH_2_BRAM_dout       )
  );

  (* dont_touch = "yes" *)
  BRAM #(
    .DATA_WIDTH   (DATA_WIDTH           ),
    .DEPTH        (A_DEPTH              ),
    .CLK_LATENCY  (1                    )
  ) u_a_BRAM (
    .clk          (clk                  ),
    .rst_n        (rst_n                ),
    .din          (a_BRAM_din           ),
    .addra        (a_BRAM_addra         ),
    .ena          (a_BRAM_ena           ),
    .addrb        (a_BRAM_addrb         ),
    .dout         (a_BRAM_dout          )
  );

  (* dont_touch = "yes" *)
  fifo #(
    .DATA_WIDTH (SOFTMAX_WIDTH          ),
    .FIFO_DEPTH (20                     )
  ) u_softmax_FIFO (
    .clk        (clk                    ),
    .rst_n      (rst_n                  ),
    .data_i     (softmax_FIFO_din       ),
    .data_o     (softmax_FIFO_dout      ),
    .wr_valid_i (softmax_FIFO_wr_valid  ),
    .rd_valid_i (softmax_FIFO_rd_valid  ),
    .empty_o    (softmax_FIFO_empty     ),
    .full_o     (softmax_FIFO_full      )
  );

  (* dont_touch = "yes" *)
  fifo #(
    .DATA_WIDTH (AGGR_WIDTH             ),
    .FIFO_DEPTH (20                     )
  ) u_aggregator_FIFO (
    .clk        (clk                    ),
    .rst_n      (rst_n                  ),
    .data_i     (aggr_FIFO_din          ),
    .data_o     (aggr_FIFO_dout         ),
    .wr_valid_i (aggr_FIFO_wr_valid     ),
    .rd_valid_i (aggr_FIFO_rd_valid     ),
    .empty_o    (aggr_FIFO_empty        ),
    .full_o     (aggr_FIFO_full         )
  );
  //* ==========================================================
endmodule