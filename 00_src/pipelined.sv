module pipelined(
  input  logic        i_clk, i_rst_n,
  output logic        stall, flush, clear,
  output logic [31:0] nextpcF,
  output logic [31:0] instF, instD,
  output logic [31:0] pcF, pcD, pcE, pcM, pcW,
  output logic [31:0] pc_fourF,  pc_fourD,  pc_fourE, pc_fourM,
  output logic [4:0]  rd_addrE,  rd_addrM, rd_addrW,
  output logic [31:0] rd_dataW,
  output logic        rd_wrenD,  rd_wrenE,  rd_wrenM, rd_wrenW,
  output logic        lsu_wrenD, lsu_wrenE, lsu_wrenM,
  output logic        lsu_rdenD, lsu_rdenE, lsu_rdenM, lsu_rdenW,
  output logic        is_jalD,    is_jalE,    is_jalM,
  output logic        is_jalrD,   is_jalrE,   is_jalrM,
  output logic        is_brD,     is_brE,
  output logic        opa_selD, opa_selE,
  output logic        opb_selD, opb_selE,
  output logic [3:0]  alu_opD,  alu_opE,
  output logic [31:0] rs1_dataD, rs1_dataE,
  output logic [31:0] rs2_dataD, rs2_dataE,
  output logic [31:0] immD, immE,
  output logic        branch_decisionE,
  output logic [31:0] fwd_rs1_dataE, fwd_rs2_dataE, fwd_rs2_dataM,
  output logic [1:0]  fwd_rs1_selE, fwd_rs2_selE,
  output logic [31:0] operand_aE, operand_bE,
  output logic [31:0] alu_dataE, alu_dataM,
  output logic [31:0] lsu_dataM, lsu_dataW,
  output logic [31:0] mem_dataM, mem_dataW,
  output logic [31:0] pc_debugW,
  output logic        mispredE, mispredM, mispredW,
  output logic        ctrlE, ctrlM, ctrlW,
  output logic        insn_vldD, insn_vldE, insn_vldM, insn_vldW,
  output logic [4:0]  rs1_addrE, rs2_addrE,
  output logic [2:0]  funct3E, funct3M

);
/************************************
             Next stage
*************************************/
  assign pc_fourF = pcF + 32'd4;
  assign nextpcF  = (is_jalE || is_jalrE ||(is_brE & branch_decisionE)) ? alu_dataE : pc_fourF;
/************************************
             IF stage
*************************************/
  program_counter pcunit(
    .i_clk(i_clk),
	 .i_rst_n(i_rst_n),
	 .i_stall(stall),
    .i_nextpc(nextpcF),
    .o_pc(pcF));

  instmemory imem(
    .addr(pcF[15:2]),
	 .i_clk(i_clk),
	 //.i_rden(~stall),
    .rdata(instF));
	 
  if_id flip_flop_FD(
    .i_clk(i_clk),
	 .i_rst_n(i_rst_n),
	 .i_clear(clear),
	 .i_stall(stall),
    .i_pcF(pcF),
	 .i_instF(instF),
	 .i_pc_fourF(pc_fourF),
    .o_pcD(pcD),
	 .o_instD(instD),
	 .o_pc_fourD(pc_fourD),
	 .o_insn_vldD(insn_vldD));
	 
/************************************
             ID stage
*************************************/
  control_unit control_module(
    .i_inst(instD),
	 .i_stall(stall),
	 .i_clear(clear),
    .o_rd_wren(rd_wrenD),
	 .o_lsu_wren(lsu_wrenD),
	 .o_lsu_rden(lsu_rdenD),
	 .o_jal(is_jalD),
	 .o_jalr(is_jalrD),
	 .o_branch(is_brD),
	 .o_opa_sel(opa_selD),
	 .o_opb_sel(opb_selD),
	 .o_alu_op(alu_opD));
  
  regfile registerfile(
    .i_clk(i_clk),
    .i_reset(~i_rst_n),
    .i_rs1_addr(instD[19:15]),
	 .i_rs2_addr(instD[24:20]),
    .i_rd_addr(rd_addrW), 
    .i_rd_data(rd_dataW),
    .i_rd_wren(rd_wrenW),
    .o_rs1_data(rs1_dataD),
	 .o_rs2_data(rs2_dataD));
  
  immgen immunit(
    .i_inst(instD),
    .o_imm(immD));
	 
  id_ex flip_flop_DE(
    .i_clk(i_clk),
	 .i_rst_n(i_rst_n),
    .i_pcD(pcD),
    .i_rs1_addrD(instD[19:15]),
    .i_rs2_addrD(instD[24:20]),
	 .i_rs1_dataD(rs1_dataD),
	 .i_rs2_dataD(rs2_dataD),
	 .i_immD(immD),
	 .i_pc_fourD(pc_fourD),
	 .i_rd_addrD(instD[11:7]),
    .i_funct3D(instD[14:12]),
	 .i_rd_wrenD(rd_wrenD),
	 .i_lsu_wrenD(lsu_wrenD),
	 .i_lsu_rdenD(lsu_rdenD),
	 .i_opa_selD(opa_selD),
	 .i_opb_selD(opb_selD),
	 .i_is_jalD(is_jalD),
	 .i_is_jalrD(is_jalrD),
	 .i_is_branchD(is_brD),
	 .i_alu_opD(alu_opD),
	 .i_insn_vldD(insn_vldD),
    .o_pcE(pcE),
    .o_rs1_addrE(rs1_addrE),
    .o_rs2_addrE(rs2_addrE),
	 .o_rs1_dataE(rs1_dataE),
	 .o_rs2_dataE(rs2_dataE),
	 .o_immE(immE),
	 .o_pc_fourE(pc_fourE),
	 .o_rd_addrE(rd_addrE),
    .o_funct3E(funct3E),
	 .o_rd_wrenE(rd_wrenE),
	 .o_lsu_wrenE(lsu_wrenE),
	 .o_lsu_rdenE(lsu_rdenE),
	 .o_opa_selE(opa_selE),
	 .o_opb_selE(opb_selE),
	 .o_is_jalE(is_jalE),
	 .o_is_jalrE(is_jalrE),
	 .o_is_branchE(is_brE),
	 .o_alu_opE(alu_opE),
	 .o_insn_vldE(insn_vldE));
	 
/************************************
             EX stage
*************************************/

  mux3to1 muxa_forward(
    .i_a(rs1_dataE),
	 .i_b(mem_dataM),
	 .i_c(rd_dataW),
    .i_sel(fwd_rs1_selE),	
    .o_y(fwd_rs1_dataE));
	 
  mux3to1 muxb_forward(
    .i_a(rs2_dataE),
	 .i_b(mem_dataM),  
	 .i_c(rd_dataW),
    .i_sel(fwd_rs2_selE),
    .o_y(fwd_rs2_dataE));
	 
 
  assign operand_aE = (opa_selE) ? pcE  : fwd_rs1_dataE;
  assign operand_bE = (opb_selE) ? immE : fwd_rs2_dataE;
  
  branch_comb compare_comb(
    .i_rd1(fwd_rs1_dataE),
	 .i_rd2(fwd_rs2_dataE),
    .i_funct3(funct3E),
    .o_branch_taken(branch_decisionE)
);
  
  
  alu alu_unit(
    .i_op_a(operand_aE),
	 .i_op_b(operand_bE),
    .i_alu_op(alu_opE),
    .o_alu_data(alu_dataE)
  );
  
  
  ex_mem flip_flop_EM(
    .i_clk(i_clk),           .i_rst_n(i_rst_n),
    .i_alu_dataE(alu_dataE), .i_fwd_rs2_dataE(fwd_rs2_dataE), .i_pc_fourE(pc_fourE), .i_pcE(pcE),
    .i_rd_addrE(rd_addrE),
    .i_funct3E(funct3E),
    .i_insn_vldE(insn_vldE), .i_mispredE(mispredE),           .i_ctrlE(ctrlE),
    .i_is_jalE(is_jalE),     .i_is_jalrE(is_jalrE),
    .i_rd_wrenE(rd_wrenE),   .i_lsu_wrenE(lsu_wrenE),         .i_lsu_rdenE(lsu_rdenE),
  //output
    .o_alu_dataM(alu_dataM), .o_fwd_rs2_dataM(fwd_rs2_dataM), .o_pc_fourM(pc_fourM), .o_pcM(pcM),
    .o_rd_addrM(rd_addrM),
    .o_funct3M(funct3M),
    .o_insn_vldM(insn_vldM), .o_mispredM(mispredM),           .o_ctrlM(ctrlM),
    .o_is_jalM(is_jalM),     .o_is_jalrM(is_jalrM),
    .o_rd_wrenM(rd_wrenM),   .o_lsu_wrenM(lsu_wrenM),         .o_lsu_rdenM(lsu_rdenM));

/************************************
             MEM stage
*************************************/
  
 /* lsu lsu_module(
    .i_clk(i_clk),
	 .i_rst_n(i_rst_n),
    .i_lsu_addr(alu_dataM),
	 .i_st_data(fwd_rs2_dataM),
    .i_lsu_wren(lsu_wrenM),
	 .i_funct3(i_funct3M),
    .o_lsu_data(lsu_dataM));
 */
  lsu_hao  lsu_unit(
    .i_clk(i_clk),
    .i_reset(~i_rst_n),
    .i_lsu_addr(alu_dataM),
    .i_st_data(fwd_rs2_dataM),
    .i_lsu_wren(lsu_wrenM),
    .i_io_sw(),
    .i_funct3(funct3M),
    .o_ld_data(lsu_dataM),
    .o_io_ledr(),
    .o_io_ledg(),
    .o_io_hex0(),
    .o_io_hex1(),
    .o_io_hex2(),
    .o_io_hex3(),
    .o_io_hex4(),
    .o_io_hex5(),
    .o_io_hex6(),
    .o_io_hex7());

  assign mem_dataM = (is_jalM || is_jalrM) ? pc_fourM : alu_dataM;


  mem_wb flip_flop_mw(
    .i_clk(i_clk)          , .i_rst_n(i_rst_n)      ,
    .i_lsu_dataM(lsu_dataM), .i_mem_dataM(mem_dataM),
    .i_rd_addrM(rd_addrM)  ,
    .i_pcM(pcM)            ,
    .i_insn_vldM(insn_vldM), .i_mispredM(mispredM)  , .i_ctrlM(ctrlM),
    .i_rd_wrenM(rd_wrenM)  , .i_lsu_rdenM(lsu_rdenM),
    .o_lsu_dataW(lsu_dataW), .o_mem_dataW(mem_dataW),
    .o_rd_addrW(rd_addrW)  ,
    .o_pcW(pcW)            ,
    .o_insn_vldW(insn_vldW), .o_mispredW(mispredW)  , .o_ctrlW(ctrlW),
    .o_rd_wrenW(rd_wrenW)  , .o_lsu_rdenW(lsu_rdenW)) ;
  
/************************************
             Writeback stage
*************************************/
  assign rd_dataW = (lsu_rdenW) ? lsu_dataW : mem_dataW;
  
/************************************
             Hazard
*************************************/
  hazard_unit hazard(
    .i_lsu_rden(lsu_rdenE),
    .i_rs1_addr(instD[19:15]),
	 .i_rs2_addr(instD[24:20]),
    .i_rd_addr (rd_addrE),
	 .i_rd_wren (rd_wrenE),
	 .i_flush   (is_jalE || is_jalrE ||(is_brE & branch_decisionE)),
    .o_stall(stall),
	 .o_clear(clear)
  );
/************************************
             Forwarding
*************************************/
   forwarding_unit hazard_forwarding(
    .i_rs1_addrE(rs1_addrE),
	 .i_rs2_addrE(rs2_addrE),
    .i_rd_addrM(rd_addrM), 
	 .i_rd_addrW(rd_addrW),
    .i_rd_wrenM(rd_wrenM), 
	 .i_rd_wrenW(rd_wrenW),
    .o_forward_a(fwd_rs1_selE), 
	 .o_forward_b(fwd_rs2_selE));
/************************************
             Debug signal
*************************************/
  assign mispredE = is_jalE || is_jalrE ||(is_brE & branch_decisionE);
  assign pc_debugW = pcW;
  assign ctrlE = is_brE ;
  assign flush = is_jalE || is_jalrE ||(is_brE & branch_decisionE);
endmodule