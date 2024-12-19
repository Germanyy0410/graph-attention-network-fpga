`timescale 1ns / 1ps

	localparam string ROOT_PATH = "d:/VLSI/Capstone";

`include "comparator.sv"

module top_tb import params_pkg::*;
  ();

  logic                             clk                         ;
  logic                             rst_n                       ;

  logic   [H_DATA_WIDTH-1:0]        H_data_BRAM_din             ;
  logic                             H_data_BRAM_ena             ;
  logic   [H_DATA_ADDR_W-1:0]       H_data_BRAM_addra           ;
  logic                             H_data_BRAM_enb             ;
  logic   [H_DATA_ADDR_W-1:0]       H_data_BRAM_addrb           ;
  logic                             H_data_BRAM_load_done       ;

  logic   [NODE_INFO_WIDTH-1:0]     H_node_info_BRAM_din        ;
  logic                             H_node_info_BRAM_ena        ;
  logic   [NODE_INFO_ADDR_W-1:0]    H_node_info_BRAM_addra      ;
  logic                             H_node_info_BRAM_enb        ;
  logic   [NODE_INFO_ADDR_W-1:0]    H_node_info_BRAM_addrb      ;
  logic                             H_node_info_BRAM_load_done  ;

  logic   [DATA_WIDTH-1:0]          Weight_BRAM_din             ;
  logic                             Weight_BRAM_ena             ;
  logic   [WEIGHT_ADDR_W-1:0]       Weight_BRAM_addra           ;
  logic                             Weight_BRAM_enb             ;
  logic   [WEIGHT_ADDR_W-1:0]       Weight_BRAM_addrb           ;
  logic                             Weight_BRAM_load_done       ;

  logic   [DATA_WIDTH-1:0]          a_BRAM_din                  ;
  logic                             a_BRAM_ena                  ;
  logic   [A_ADDR_W-1:0]            a_BRAM_addra                ;
  logic                             a_BRAM_enb                  ;
  logic   [A_ADDR_W-1:0]            a_BRAM_addrb                ;
  logic                             a_BRAM_load_done            ;

  top dut (.*);

  ///////////////////////////////////////////////////////////////////
  always #5 clk = ~clk;
  initial begin
    clk   = 1'b1;
    rst_n = 1'b0;
    #15.01;
    rst_n = 1'b1;
  end
  ///////////////////////////////////////////////////////////////////


  ///////////////////////////////////////////////////////////////////
  longint start_time, end_time;
  longint lat_start_time, lat_end_time;

  `include "./helper/helper.sv"
  `include "./loader/input_loader.sv"
  `include "./loader/output_loader.sv"

  OutputComparator #(int, WH_DATA_WIDTH, TOTAL_NODES, NUM_FEATURE_OUT) spmm         = new("WH         ", WH_DATA_WIDTH, 0, 1);

  OutputComparator #(int, DMVM_DATA_WIDTH, TOTAL_NODES)                dmvm         = new("DMVM       ", DMVM_DATA_WIDTH, 0, 1);
  OutputComparator #(int, DATA_WIDTH, TOTAL_NODES)                     coef         = new("COEF       ", DATA_WIDTH, 0, 1);

  OutputComparator #(int, SM_DATA_WIDTH, TOTAL_NODES)                  dividend     = new("Dividend   ", SM_DATA_WIDTH, 0, 0);
  OutputComparator #(int, SM_SUM_DATA_WIDTH, NUM_SUBGRAPHS)            divisor      = new("Divisor    ", SM_SUM_DATA_WIDTH, 0, 0);
  OutputComparator #(int, NUM_NODE_WIDTH, NUM_SUBGRAPHS)               sm_num_nodes = new("SM_NUM_NODE", NUM_NODE_WIDTH, 0, 0);
  OutputComparator #(real, ALPHA_DATA_WIDTH, TOTAL_NODES)              alpha        = new("Alpha      ", WOI, WOF, 0);
  OutputComparator #(real, ALPHA_DATA_WIDTH, TOTAL_NODES)              exp_alpha    = new("Exp_Alpha  ", WOI, WOF, 0);

  initial begin
    spmm.monitor_path         = "/SPMM/wh.txt";
    dmvm.monitor_path         = "/DMVM/dmvm.txt";
    coef.monitor_path         = "/DMVM/coef.txt";
    dividend.monitor_path     = "/softmax/dividend.txt";
    divisor.monitor_path      = "/softmax/divisor.txt";
    sm_num_nodes.monitor_path = "/softmax/num_nodes.txt";
    alpha.monitor_path        = "/softmax/alpha.txt";
  end

  always_comb begin
    spmm.dut_ready              = dut.u_SPMM.spmm_ready_o;
    spmm.dut_spmm_output        = dut.u_SPMM.result;
    spmm.golden_spmm_output     = golden_spmm;
  end

  always_comb begin
    dmvm.dut_ready              = dut.u_DMVM.valid_shift_reg[COEF_DELAY_LENGTH-1];
    dmvm.dut_output             = dut.u_DMVM.pipe_product_reg[NUM_STAGES][0];
    dmvm.golden_output          = golden_dmvm;

    coef.dut_ready              = dut.u_DMVM.dmvm_ready_o;
    coef.dut_output             = dut.u_DMVM.coef_FIFO_din;
    coef.golden_output          = golden_coef;
  end

  always_comb begin
    dividend.dut_ready          = dut.u_softmax.dividend_FIFO_rd_vld;
    dividend.dut_output         = dut.u_softmax.dividend_FIFO_dout;
    dividend.golden_output      = golden_dividend;

    divisor.dut_ready           = dut.u_softmax.divisor_FIFO_wr_vld;
    divisor.dut_output          = dut.u_softmax.divisor_FIFO_din.divisor;
    divisor.golden_output       = golden_divisor;

    sm_num_nodes.dut_ready      = dut.u_softmax.divisor_FIFO_wr_vld;
    sm_num_nodes.dut_output     = dut.u_softmax.divisor_FIFO_din.num_of_nodes;
    sm_num_nodes.golden_output  = golden_sm_num_node;

    alpha.dut_ready             = dut.u_softmax.sm_ready_o;
    alpha.dut_output            = dut.u_softmax.alpha_FIFO_din;
    alpha.golden_output         = golden_alpha;

    exp_alpha.dut_ready         = dut.u_softmax.sm_ready_o;
    exp_alpha.dut_output        = dut.u_softmax.alpha_FIFO_din;
    exp_alpha.golden_output     = golden_exp_alpha;
  end

  initial begin
    fork
      spmm.spmm_checker();
      dmvm.output_checker();
      coef.output_checker();
      dividend.output_checker();
      divisor.output_checker();
      sm_num_nodes.output_checker();
      alpha.output_checker(0.005);
      exp_alpha.output_checker(0.1);
    join
  end

  initial begin
    #0.1;
    wait(dut.u_SPMM.spmm_valid_i == 1'b1);
    start_time      = $time;
    lat_start_time  = $time;
    for (int i = 0; i < TOTAL_NODES; i++) begin
      #10.01;
      wait(dut.u_softmax.sm_ready_o == 1'b1);
      if (i == 0) begin
        lat_end_time = $time;
      end
    end
    end_time = $time;

    begin_section;

    spmm.base_monitor();

    dmvm.base_monitor();
    coef.base_monitor();

    dividend.base_monitor();
    sm_num_nodes.base_monitor();
    divisor.base_monitor();
    alpha.base_monitor();
    // exp_alpha.base_monitor();

    summary_section;

    $display("\n  SPMM:");
    spmm.base_scoreboard();

    $display("\n  DMVM:");
    dmvm.base_scoreboard();
    coef.base_scoreboard();

    $display("\n  SOFTMAX:");
    dividend.base_scoreboard();
    divisor.base_scoreboard();
    sm_num_nodes.base_scoreboard();
    alpha.base_scoreboard();
    // exp_alpha.base_scoreboard();

    end_section;

    #20000;
    $finish();
  end
endmodule



