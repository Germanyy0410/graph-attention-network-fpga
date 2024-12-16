
  integer spmm_file, dmvm_file, coef_file, alpha_file, dividend_file, divisor_file, sm_num_node_file, exp_alpha_file, status;
  integer spmm_value, dmvm_value, coef_value, dividend_value, divisor_value, sm_num_node_value;
  real    alpha_value, exp_alpha_value;

  initial begin
    spmm_file = $fopen("D:/VLSI/Capstone/tb/outputs/SPMM/WH.txt", "r");
    for (int i = 0; i < TOTAL_NODES*NUM_FEATURE_OUT; i++) begin
      status = $fscanf(spmm_file, "%d\n", spmm_value);
      golden_spmm[i] = spmm_value;
    end
    $fclose(spmm_file);
  end

  initial begin
    dmvm_file = $fopen("D:/VLSI/Capstone/tb/outputs/DMVM/DMVM.txt", "r");
    for (int i = 0; i < TOTAL_NODES; i++) begin
      status = $fscanf(dmvm_file, "%d\n", dmvm_value);
      golden_dmvm[i] = dmvm_value;
    end
    $fclose(dmvm_file);
  end

  initial begin
    coef_file = $fopen("D:/VLSI/Capstone/tb/outputs/DMVM/COEF.txt", "r");
    for (int i = 0; i < TOTAL_NODES; i++) begin
      status = $fscanf(coef_file, "%d\n", coef_value);
      golden_coef[i] = coef_value;
    end
    $fclose(coef_file);
  end

  initial begin
    alpha_file = $fopen("D:/VLSI/Capstone/tb/outputs/softmax/ALPHA.txt", "r");
    for (int i = 0; i < TOTAL_NODES; i++) begin
      status = $fscanf(alpha_file, "%f\n", alpha_value);
      golden_alpha[i] = alpha_value;
    end
    $fclose(alpha_file);
  end

  initial begin
    dividend_file = $fopen("D:/VLSI/Capstone/tb/outputs/softmax/DIVIDEND.txt", "r");
    for (int i = 0; i < TOTAL_NODES; i++) begin
      status = $fscanf(dividend_file, "%f\n", dividend_value);
      golden_dividend[i] = dividend_value;
    end
    $fclose(dividend_file);
  end

  initial begin
    divisor_file = $fopen("D:/VLSI/Capstone/tb/outputs/softmax/DIVISOR.txt", "r");
    for (int i = 0; i < TOTAL_NODES; i++) begin
      status = $fscanf(divisor_file, "%f\n", divisor_value);
      golden_divisor[i] = divisor_value;
    end
    $fclose(divisor_file);
  end

  initial begin
    sm_num_node_file = $fopen("D:/VLSI/Capstone/tb/outputs/softmax/NUM_NODE.txt", "r");
    for (int i = 0; i < TOTAL_NODES; i++) begin
      status = $fscanf(sm_num_node_file, "%f\n", sm_num_node_value);
      golden_sm_num_node[i] = sm_num_node_value;
    end
    $fclose(sm_num_node_file);
  end

  initial begin
    exp_alpha_file = $fopen("D:/VLSI/Capstone/tb/outputs/softmax/EXP_ALPHA.txt", "r");
    for (int i = 0; i < TOTAL_NODES; i++) begin
      status = $fscanf(exp_alpha_file, "%f\n", exp_alpha_value);
      golden_exp_alpha[i] = exp_alpha_value;
    end
    $fclose(exp_alpha_file);
  end