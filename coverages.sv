class ethernet_coverage extends uvm_component;

	//===============================factory registration====================
	`uvm_component_utils(ethernet_coverage)

	//==========================================instances==========================
	virtual ethernet_interface vintf;

 	//=========================================covergruop==================================================================
	covergroup ethernet_cg;


				//=========coverpoint :prstn_i===============
				cp_prstn_i: coverpoint  vintf.prstn_i {

                                                bins prstn_i_low   = {0};
                                                bins prstn_i_high  = {1};

                                              }

				//===============coverpoint :psel_i===============
				cp_psel_i: coverpoint vintf.psel_i  iff(vintf.prstn_i){

                                                bins psel_low     = {0};
                                                bins psel_high    = {1};

                                                }

				//===============coverpoint :penable_i===============
				cp_penable_i: coverpoint vintf.penable_i iff(vintf.prstn_i && vintf.psel_i){

                                               bins penable_low    = {0};
                                               bins penable_high   = {1};

                                               }

				//===============coverpoint :pwrite_i===============
				cp_pwrite_i: coverpoint vintf.pwrite_i iff(vintf.prstn_i && vintf.psel_i){

                                                bins pwrite_low    = {0};
                                                bins pwrite_high   = {1};

                                                }

				//===============coverpoint :paddr_i===============
				cp_paddr_i: coverpoint  vintf.paddr_i iff(vintf.prstn_i && vintf.psel_i) {

                                                bins moder_reg             =    {32'h00};
                                                bins int_source_reg        =    {32'h04};
                                                bins int_mask_reg          =    {32'h08};
                                                bins tx_bd_num_reg         =    {32'h20}; 
                                                bins mac_addr0_reg         =    {32'h40};
                                                bins mac_addr1_reg         =    {32'h44};
                                                bins mii_addr_reg          =    {32'h30};
                                                bins buffer_descriptors    =    {[32'h400:32'h7ff]} with (item % 4 == 0);
                                                //ignore_bins default_bins   = 	default;

                                                }


				//===============coverpoint :pwdata_i===============
				cp_pwdata_i : coverpoint vintf.pwdata_i iff(vintf.prstn_i && vintf.psel_i) {

                                                 bins low         = {32'h0000_0000};
                                                 bins high        = {32'hFFFF_FFFF};  
                                                 bins toggle_5	  = {32'h5555_5555};
                                                 bins taggle_a 	  = {32'hAAAA_AAAA};

												}

				//===============coverpoint :m_pready_i===============
				cp_m_pready_i: coverpoint vintf.m_pready_i  iff(vintf.prstn_i && vintf.m_psel_o && vintf.m_penable_o){

                                                bins mpready_low   = {0};
                                                bins mpready_high  = {1};

                                                }

				//===============coverpoint :MRXDV===============
				cp_mrx_dv: coverpoint vintf.MRxDV;

				//===============coverpoint :MCrS===============
				cp_mcrs: coverpoint vintf.MCrS;

				//===============coverpoint :MRxD===============
				cp_mrx_d: coverpoint vintf.MRxD iff(vintf.MRxDV) {

                                                 bins low      = {32'h0000_0000};
                                                 bins high     = {32'hFFFF_FFFF};  
                                                 bins toggle_5 = {32'h5555_5555};
                                                 bins toggle_a = {32'hAAAA_AAAA};

												}

				//===============coverpoint :MRxErr===============
				cp_mrx_err: coverpoint vintf.MRxErr iff(vintf.MRxDV) ;

				//===============coverpoint :MODER_PAD BIT===============
				cp_moder_reg_PAD : coverpoint vintf.pwdata_i[15] iff(vintf.paddr_i== 32'h0 &&  vintf.penable_i &&  vintf.prstn_i && vintf.pwdata_i[0] && vintf.psel_i);			

				//===============coverpoint :MODER_HUGEN BIT===============
				cp_moder_reg_HUGEN : coverpoint vintf.pwdata_i[14] iff(vintf.paddr_i==32'h0 &&  vintf.penable_i &&  vintf.prstn_i && vintf.pwdata_i[0] && vintf.psel_i);


				//===============coverpoint :MODER_FULLD BIT===============
				cp_moder_reg_FULLD : coverpoint vintf.pwdata_i[10]iff(vintf.paddr_i==32'h0 &&  vintf.penable_i &&  vintf.prstn_i && vintf.pwdata_i[0] && vintf.psel_i){

                                         bins half_duplex		  = {0};
                                         illegal_bins full_duplex = {1};


									}

				//===============coverpoint :MODER_LOOPBCK BIT===============
				cp_moder_reg_LOOPBCK  : coverpoint vintf.pwdata_i[7] iff(vintf.paddr_i==32'h0 &&  vintf.penable_i &&  vintf.prstn_i && vintf.pwdata_i[0] && vintf.psel_i){

                                         bins no_loop_back		 = {0};
                                         illegal_bins loop_back  = {1};

										}

				//===============coverpoint :MODER_IFG BIT===============
				cp_moder_reg_IFG  : coverpoint vintf.pwdata_i[6] iff(vintf.paddr_i==32'h0 &&  vintf.penable_i &&  vintf.prstn_i && vintf.pwdata_i[0] && vintf.psel_i){

                                         bins frame_gap			   = {0};
                                         illegal_bins no_frame_gap = {1};

										}


				//===============coverpoint :MODER_PRO BIT===============
				 cp_moder_reg_PRO  : coverpoint vintf.pwdata_i[5] iff(vintf.paddr_i==32'h0 &&  vintf.penable_i &&  vintf.prstn_i && vintf.pwdata_i[0] && vintf.psel_i);

				
				//===============coverpoint :MODER_BRO BIT===============
				 cp_moder_reg_BRO  : coverpoint vintf.pwdata_i[3] iff(vintf.paddr_i==32'h0 &&  vintf.penable_i &&  vintf.prstn_i && vintf.pwdata_i[0] && vintf.psel_i);


				//===============coverpoint :MODER_NOPRE BIT===============
				 cp_moder_reg_NOPRE  : coverpoint vintf.pwdata_i[2] iff(vintf.paddr_i==32'h0 &&  vintf.penable_i &&  vintf.prstn_i && vintf.pwdata_i[0] && vintf.psel_i);

				//===============coverpoint :MODER_TXEN BIT===============
				 cp_moder_reg_TXEN  : coverpoint vintf.pwdata_i[1] iff(vintf.paddr_i==32'h0 &&  vintf.penable_i &&  vintf.prstn_i && vintf.pwdata_i[0] && vintf.psel_i);

				//===============coverpoint :MODER_RXEN BIT===============
				cp_moder_reg_RXEN  : coverpoint vintf.pwdata_i[0] iff(vintf.paddr_i==32'h0 &&  vintf.penable_i &&  vintf.prstn_i && vintf.psel_i);


				//===============coverpoint :INT_SOURCE_RXE BIT===============
				cp_intsource_reg_RXE  : coverpoint vintf.pwdata_i[3] iff(vintf.paddr_i==32'h04 &&  vintf.penable_i &&  vintf.prstn_i && vintf.psel_i);
 
				//===============coverpoint :INT_SOURCE_RXB BIT===============
		 	 	cp_intsource_reg_RXB  : coverpoint vintf.pwdata_i[2] iff(vintf.paddr_i==32'h04 &&  vintf.penable_i &&  vintf.prstn_i && vintf.psel_i);   

				//===============coverpoint :INT_MASK_RXE_M BIT===============
				cp_intmask_reg_RXE_M  : coverpoint vintf.pwdata_i[3] iff(vintf.paddr_i==32'h08 &&  vintf.penable_i &&  vintf.prstn_i && vintf.psel_i);
    
				//===============coverpoint :INT_MASK_RXF_M BIT===============
				cp_intmask_reg_RXF_M  : coverpoint vintf.pwdata_i[2] iff(vintf.paddr_i==32'h08 &&  vintf.penable_i &&  vintf.prstn_i && vintf.psel_i);




//==================================================================================================================================================================================================
//..............................................................................CROSS BINS........................................................................................................
//==================================================================================================================================================================================================

				//===============cross bin coverpoint for paddr_i,pwrite_i===============
				cr_paddr_pwrite: cross cp_paddr_i, cp_pwrite_i iff(vintf.prstn_i && vintf.psel_i);	

				//===============cross bin coverpoint for psel_i,penable_i===============
				cr_psel_penb: cross cp_psel_i, cp_penable_i  iff(vintf.prstn_i);

				//===============cross bin coverpoint for MRxDV,MCrS===============
				cr_mrx_dv_mcrs : cross cp_mrx_dv, cp_mcrs;

				//===============cross bin coverpoint for BRO,PRO===============
				cr_pro_bro: cross cp_moder_reg_PRO,cp_moder_reg_BRO iff(vintf.paddr_i== 32'h0 &&  vintf.penable_i &&  vintf.prstn_i && vintf.psel_i);

				//===============cross bin coverpoint for PAD,HUGEN===============
				cr_pad_hugen: cross cp_moder_reg_PAD,cp_moder_reg_HUGEN iff(vintf.paddr_i== 32'h0 &&  vintf.penable_i &&  vintf.prstn_i && vintf.psel_i);



//====================================================================================================================================================================================================
//..............................................................................TRANSITION BINS...............................................................................................
//=====================================================================================================================================================================================================


				//===============transition bin for reset===============
				cp_rst_transition: coverpoint  vintf.prstn_i {

                                                bins prstn_i_0_to_1 = (0 => 1);
                                                bins prstn_i_1_to_0 = (1 => 0);

                                                }

				//===============transition bin for psel_i===============
				cp_psel_transition: coverpoint vintf.psel_i  iff(vintf.prstn_i){

                                                bins psel_0_to_1 = (0 => 1);
                                                bins psel_1_to_0 = (1 => 0);

                                                }

				//===============transition bin for penable_i===============
				cp_penable_transition: coverpoint vintf.penable_i iff(vintf.prstn_i && vintf.psel_i){

                      						  bins enb_tr1 = (0=>1=>0);                //without wait states
                       						  bins enb_tr2 = (0=>1[=1]=>0);          //with wait states
                                   

									   }
				//===============transition bin for MRxErr===============
				cp_mrx_err_transition: coverpoint vintf.MRxErr iff(vintf.MRxDV) {

                                                bins error_0_to_1 = (0 => 1);
                                                bins error_1_to_0 = (1 => 0);
											}

				//===============transition bin for m_pready_i===============
				cp_m_pready_i_transition: coverpoint vintf.m_pready_i  iff(vintf.prstn_i && vintf.m_psel_o && vintf.m_penable_o){

                                                bins mpready_0_to_1  = (0 => 1);
                                                bins mpready_1_to_0  = (1 => 0);

                                                }

	endgroup


 	//===============new constructor==========================
	function new(string name="ethernet_coverage",uvm_component base);
		super.new(name,base);
		ethernet_cg=new();
		
	endfunction

	//===============build phase=============================
	function void build_phase(uvm_phase phase);

		super.build_phase(phase);


		if(!uvm_config_db #(virtual ethernet_interface)::get(this,"","vif",vintf))
			`uvm_fatal("NO VIF","VIRTUAL INTERFACE NOT FOUND !!");
					
	endfunction



 	//===============run phase====================================   
	task run_phase(uvm_phase phase);
		super.run_phase(phase);

	 	forever@(posedge vintf.pclk) begin
      			ethernet_cg.sample;
     	 		`uvm_info("COVERAGE", $sformatf("\nCOVERAGE PERCENTAGE:%.2f%% ",ethernet_cg.get_coverage), UVM_HIGH);	
        	end
      
    	endtask
	
	function void extract_phase(uvm_phase phase);
		super.extract_phase(phase);
     	 	
		`uvm_info("COVERAGE", $sformatf("\n\t\t\t\t\t\t=================================>COVERAGE PERCENTAGE:%.2f%%<========================================== ",ethernet_cg.get_coverage), UVM_NONE);			

	endfunction

  
endclass
