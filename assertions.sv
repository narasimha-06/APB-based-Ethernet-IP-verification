module ethernet_assertions(
 
//====================host_apb signals================================= 
   	input prstn_i, 
	input psel_i,
	input penable_i,
	input pwrite_i,
	input[31:0]paddr_i,
	input[31:0]pwdata_i,
	input[31:0]prdata_o,
	input pready_o,
	input int_o,

 //=========================memory_apb signals========================  

	input m_pready_i,
	input [31:0]m_prdata_i, 
	input m_psel_o,
	input m_pwrite_o,
	input m_penable_o,
	input [31:0]m_paddr_o,
	input [31:0]m_pwdata_o,

//=============================rx mac signals===============================
	input MRxClk,
	input MRxDV,
	input [3:0]MRxD,
	input MRxErr,
	input MCrS	);

//=======================================================================================================================
//.............................................ASSERTION CHECKS...............................................................
//==========================================================================================================================

//=====================================PCLK_I_CHECK-1=====================================================================

	property check_pclk_i;
   		real t1,t2;
   		@(posedge pclk_i) (1,t1=$realtime) |=> (1,t2=$realtime) |-> (40==(t2-t1));
  	endproperty

	assert property(check_pclk_i)
		$display($time,"\tpclk_i clock check success");
	else $display($time,"\tpclk_i clock check fail");


//=====================================MRxCLK_CHECK-2=====================================================================

	property check_MRxClk;
 	  real t1,t2;
  		 @(posedge MRxclk) (1,t1=$realtime) |=> (1,t2=$realtime) |-> (40==(t2-t1));
 	endproperty

	assert property(check_MRxClk)
		$display($time,"\tMRxClk clock check success");
	else $display($time,"\tMRxClk clock check fail");


//===========================================HOST_SIG_OP_UNKNOWN_CHECK-3===========================================================

	property  host_signal_op_unknown_check;
   		@(posedge pclk_i)    $rose(prstn_i) |-> $rose(psel_i) |->!isunknown(pready_o) |->!isunknown(prdata_o);
	endproperty
	
	assert property(host_signal_op_unknown_check)
		$display($time,"\thost output signals unknown values check success");
	else $display($time,"\thost output signals unknown values check fail");

//============================================MEM_SIG_OP_UNKNOWN_CHECK-4=========================================================

	property  mem_signal_op_unknown_check;
  		 @(posedge pclk_i)  $rose(prstn_i) |->!isunknown(m_psel_o) |->!isunknown(m_penable_o) |-> !isunknown(m_pwrite_o) |-> !isunknown(m_paddr_o) |-> !isunknown(m_pwdata_o) ;
	endproperty

	assert property(mem_signal_op_unknown_check)
		$display($time,"\tmemory output signals unknown values check success");
	else $display($time,"\tmemory output signals unknown values  check fail");

//===================================================HOST_APB_SETUP_SIG-5============================================================

	property host_apb_setup_sig;
  		 @(posedge pclk_i) (prstn_i==1) |->$rose(psel_i) |-> (penable_i==0) ;
	endproperty

	assert property(host_apb_setup_sig)
		$display($time,"\thost signals setup values check success");
	else $display($time,"\thost signals setup values  check fail");

//=========================================================HOST_APB_ACCESS_SIG-6==========================================================

	property host_apb_access_sig;
   		@(posedge pclk_i) (prstn_i==1) |-> (psel_i==1) |=> $rose (penable_i) ;
	endproperty

	assert property(host_apb_access_sig)
		$display($time,"\thost signals access phase  values check success");
	else $display($time,"\thost signals access phase values  check fail");

//==========================================================HOST_APB_READY_TIMEOUT-7==========================================================

	property host_apb_ready_timeout;
	   @(posedge pclk_i) (prstn_i==1) |-> $rose(psel_i) |=> $rose (penable_i) ##[0:$] pready_o;
	endproperty

	assert property(host_apb_ready_timeout)
		$display($time,"\thost signals access ready signal timeout check success");
	else $display($time,"\thost signals access ready signal timeout check fail");

//=====================================================HOST_APB_STABLE_VAL-8===============================================================

	property host_apb_stable_val;
   		@(posedge pclk_i)  $stable({paddr_i,pwdata_i}) throughout ({prstn_i, psel_i ,penable_i}) until pready_o;
	endproperty 

	assert property( host_apb_stable_val)
		$display($time,"\thost signas stable values  check success");
	else $display($time,"\thost signals stable values check fail");

//======================================================MEM_APB_MASTER_SETUP_SIG-9=================================================================

	property mem_apb_setup_sig;
 		  @(posedge pclk_i) (prstn_i==1) |->$rose(m_psel_o) |-> (m_penable_i==0) ;
	endproperty
	
	assert property(mem_apb_setup_sig)
		$display($time,"\tmem apb signals setup values check success");
	else $display($time,"\tmem apb signals setup values  check fail");

//=======================================================MEM_APB_MASTER_ACCESS_SIG-10============================================================

	property mem_apb_access_sig;
 		  @(posedge pclk_i) (prstn_i==1) |->$rose(m_psel_o) |=> $rose(m_penable_o) ;
	endproperty
	
	assert property(mem_apb_access_sig)
		$display($time,"\tmem apb signals access values check success");
	else $display($time,"\tmem apb signals access values  check fail");

//=========================================================MEM_APB_READY_TIMEOUT-11============================================================

	property mem_apb_ready_timeout;
 		  @(posedge pclk_i) (prstn_i==1) |->$rose(m_psel_o) |=> $rose(m_penable_o)  ##[0:$] m_pready_i;
	endproperty
	
	assert property(mem_apb_ready_timeout)
		$display($time,"\tmem signals access ready signal timeout check success");
	else $display($time,"\tmem signals access ready signal timeout check fail");


//==========================================================MEM_APB_MASTER_STABLE_VAL-12========================================================

	property mem_apb_stable_val;
   		@(posedge pclk_i)  $stable({m_paddr_o,m_pwdata_o}) throughout ({prstn_i, m_psel_o ,m_penable_o}) until m_pready_i;
	endproperty 

	assert property( mem_apb_stable_val)
		$display($time,"\tmem signas stable values  check success");
	else $display($time,"\tmem signals stable values check fail");

//==========================================================MODER_DEFAULT_VALUES_CHECK-13=======================================================


	property moder_default_values_check;
  		 @(posedge pclk_i) disable iff(!prstn_i) 
	     	  $rose(prstn_i) |-> $rose(psel_i) |-> !pwrite_i  |-> (paddr_i==32'h0000_0000)) |=>(penable_i==1) ##[0:10]pready |->(prdata_o==32'h0000A000);
	endproperty

	assert property(moder_default_values_check)
		$display($time,"\tMODER REGISTER default value  check success");
	else $display($time,"\tMODER REGISTER default value check fail");

//========================================================MODER_CONFIG_CHECK-14=================================================================

	property moder_config_check;
   		  @(posedge pclk_i)  prstn_i |-> $rose(psel_i) |-> !penable |-> pwrite |-> (paddr_i == 32'h0000_0000) |-> ((pwdata_i[10] == 0) && (pwdata_i[7:6] == 2'b00));
	endproperty 

	assert property(moder_config_check)
		$display($time,"\tMODER REGISTER configure value  check success");
	else $display($time,"\tMODER REGISTER configure value check fail");

//========================================================INT_SOURCE_DEFAULT_VALUES_CHECK-15======================================================

	property int_source_default_val;
 	  @(posedge pclk_i) disable iff(!prstn_i) 
       $rose(prstn_i) |-> $rose(psel_i) |-> !pwrite_i  |-> (paddr_i==32'h0000_0004)) |=>(penable_i==1) ##[0:10]pready |->(prdata_o==32'h00000000);
	endproperty

	assert property(int_source_default_val)
		$display($time,"\tINT_SOURCE REGISTER default value  check success");
	else $display($time,"\tINT_SOURCE REGISTER default value check fail");

//========================================================INT_SOURCE_CONFIG_CHECK-16==========================================================							

	property int_mask_config_check;
  	   @(posedge pclk_i)  prstn_i |-> $rose(psel_i) |-> !penable |-> pwrite |-> (paddr_i == 32'h0000_0008) |-> (pwdata_i[3:0] == 15);
	endproperty 

	assert property(int_mask_config_check)
		$display($time,"\tINT_MASK REGISTER configure value  check success");
	else $display($time,"\tINT_MASK REGISTER configure value check fail");

//========================================================INT_MASK_DEFAULT_VALUES_CHECK-17=============================================================

	property int_mask_default_val;
  		 @(posedge pclk_i) disable iff(!prstn_i) 
      	prstn_i |-> $rose(psel_i) |-> !pwrite_i  |-> (paddr_i==32'h0000_0008)) |=>(penable_i==1) ##[0:10]pready |->(prdata_o==32'h00000000);
	endproperty

	assert property(int_mask_default_val)
		$display($time,"\tINT_MASK REGISTER default value  check success");
	else $display($time,"\tINT_MASK REGISTER default value check fail");

//============================================================DEFAULT_TX_BD_NUM_REGVALUES_CHECK-18===================================================

	property default_tx_bd_num_reg_val;
  		 @(posedge pclk_i) disable iff(!prstn_i) 
       prstn_i |-> $rose(psel_i) |-> !pwrite_i  |-> (paddr_i==32'h0000_0020)) |=>(penable_i==1) ##[0:10]pready |->(prdata_o==32'h00000040);
	endproperty

	assert property(default_tx_bd_num_reg_val)
		$display($time,"\tTX_BD REGISTER default value  check success");
	else $display($time,"\tTX_BD REGISTER default value check fail");

//=============================================================DEFAULT_MIIADDRESS_REG_VALUES_CHECK-19================================================

	property default_miiaddress_reg_val;
	   @(posedge pclk_i) disable iff(!prstn_i) 
        prstn_i |-> $rose(psel_i) |-> !pwrite_i  |-> (paddr_i==32'h0000_0030)) |=>(penable_i==1) ##[0:10]pready |->(prdata_o==32'h00000000);
	endproperty

	assert property(default_miiaddress_reg_val)
		$display($time,"\tMIIADDRESS REGISTER default value  check success");
	else $display($time,"\tMIIADDRESS REGISTER default value check fail");


//===========================================================DEFAULT_MAC_ADDR0_REG_VALUES_CHECK-20==========================================================

	property default_mac_addr0_reg_val;
 	  @(posedge pclk_i) disable iff(!prstn_i) 
       prstn_i |-> $rose(psel_i) |-> !pwrite_i  |-> (paddr_i==32'h0000_0040)) |=>(penable_i==1) ##[0:10]pready |->(prdata_o==32'h00000000);
	endproperty

	assert property(default_mac_addr0_reg_val)
		$display($time,"\tMAC_ADDR0 REGISTER default value  check success");
	else $display($time,"\tMAC_ADDR0 REGISTER default value check fail");

//==========================================================DEFAULT_MAC_ADDR1_REG_VALUES_CHECK-21=============================================================

	property default_mac_addr1_reg_val;
 	  @(posedge pclk_i) disable iff(!prstn_i) 
        prstn_i |-> $rose(psel_i) |-> !pwrite_i  |-> (paddr_i==32'h0000_0044)) |=>(penable_i==1) ##[0:10]pready |->(prdata_o==32'h00000000);
	endproperty

	assert property(default_mac_addr1_reg_val)
		$display($time,"\tMAC_ADDR1 REGISTER default value  check success");
	else $display($time,"\tMAC_ADDR1 REGISTER default value check fail");



endmodule