class ethernet_virtual_sequence extends uvm_sequence;

	`uvm_object_utils(ethernet_virtual_sequence)
	
	`uvm_declare_p_sequencer(ethernet_virtual_sequencer)
	
	//=========HOST SEQUENCES================
	Base_sequence 	h_base_sequence;
	
	TC_RESET	h_TC_RESET;
	TC_REG_CONFIG	h_TC_REG_CONFIG;

    TC_RX_EN_0_host       h_TC_RX_EN_0_host;
	TC_RX_EN_1_host       h_TC_RX_EN_1_host;
    TC_MCrS_0_host        h_TC_MCrS_0_host;
    TC_MCrS_1_host        h_TC_MCrS_1_host; 
    TC_EMPTY_0_host       h_TC_EMPTY_0_host;
    TC_EMPTY_RXBDS_host                 h_TC_EMPTY_RXBDS_host;
	TC_MRxERR_1_host                    h_TC_MRxERR_1_host;
    TC_NOPRE_1_host                     h_TC_NOPRE_1_host;
    TC_NOPRE_1_IL_host                  h_TC_NOPRE_1_IL_host;
    TC_PRO_BRO_00_DA_MAC_host           h_TC_PRO_BRO_00_DA_MAC_host;
    TC_PRO_BRO_00_DA_BRDCST_host        h_TC_PRO_BRO_00_DA_BRDCST_host;
    TC_PRO_BRO_01_DA_MAC_host           h_TC_PRO_BRO_01_DA_MAC_host;
    TC_PRO_BRO_01_DA_BRDCST_host        h_TC_PRO_BRO_01_DA_BRDCST_host;
    TC_PRO_BRO_10_host                  h_TC_PRO_BRO_10_host;
    TC_PRO_BRO_11_host                  h_TC_PRO_BRO_11_host;
    TC_WRONG_DA_4BYTES_host             h_TC_WRONG_DA_4BYTES_host;
    TC_WRONG_DA_LAST_2BYTES_host        h_TC_WRONG_DA_LAST_2BYTES_host;
    
    TC_FL_LESS_THAN_MINFL_host                h_TC_FL_LESS_THAN_MINFL_host;
    TC_FL_EQUAL_TO_MINFL_PAD_0_host           h_TC_FL_EQUAL_TO_MINFL_PAD_0_host;
    TC_FL_EQUAL_TO_MINFL_PAD_1_host           h_TC_FL_EQUAL_TO_MINFL_PAD_1_host;
    TC_FL_LL_PAD_1_host                       h_TC_FL_LL_PAD_1_host;
    TC_FL_LL_HUGEN_1_host                     h_TC_FL_LL_HUGEN_1_host;
    TC_FL_LL_HUGEN_1_PAD_1_host               h_TC_FL_LL_HUGEN_1_PAD_1_host;
	TC_FL_GREATER_THAN_MAXFL_HUGEN_0_host     h_TC_FL_GREATER_THAN_MAXFL_HUGEN_0_host;
    TC_FL_GREATER_THAN_MAXFL_HUGEN_1_host     h_TC_FL_GREATER_THAN_MAXFL_HUGEN_1_host;
    TC_FL_GREATER_THAN_MAXFL_2KB_host         h_TC_FL_GREATER_THAN_MAXFL_2KB_host;
    TC_IRQ_0_MASKED_host                      h_TC_IRQ_0_MASKED_host;
    TC_IRQ_0_UNMASKED_host                    h_TC_IRQ_0_UNMASKED_host;
    TC_IRQ_1_MASKED_host                      h_TC_IRQ_1_MASKED_host;
    TC_IRQ_1_UNMASKED_host                    h_TC_IRQ_1_UNMASKED_host;
    TC_IFG_0_host                             h_TC_IFG_0_host;
    TC_IFG_1_host                             h_TC_IFG_1_host;
    TC_TXBD_NUM_128_host                      h_TC_TXBD_NUM_128_host;
    TC_TXBD_NUM_GREATER_128_host              h_TC_TXBD_NUM_GREATER_128_host;
    TC_UNALLIGNED_RX_PNTR_host                h_TC_UNALLIGNED_RX_PNTR_host;
    TC_INVALID_ACCESS_host                    h_TC_INVALID_ACCESS_host;
    TC_CRC_ERROR_host                         h_TC_CRC_ERROR_host;
    TC_INSUFFICIENT_BD_host                   h_TC_INSUFFICIENT_BD_host;
    TC_LAST_BD_0_host                         h_TC_LAST_BD_0_host;
    TC_RXBD_LEN_NE_host                       h_TC_RXBD_LEN_NE_host;
    TC_WRONG_PREAMBLE_host                    h_TC_WRONG_PREAMBLE_host;
	TC_WRONG_SFD_host                         h_TC_WRONG_SFD_host;
    TC_WRONG_PADDING_host                     h_TC_WRONG_PADDING_host;
    TC_LENGTH_LS_4_host                       h_TC_LENGTH_LS_4_host;
    TC_MRxDV_0_host                           h_TC_MRxDV_0_host;
    TC_REG_CONFIG_AFTER_RXEN_host             h_TC_REG_CONFIG_AFTER_RXEN_host;
    TC_IFG_LS_24_host                         h_TC_IFG_LS_24_host;
    TC_IFG_GS_24_host                         h_TC_IFG_GS_24_host;
    
    
    
    
    
    	//=========MAC SEQUENCES=================
        Base_sequence_mac    	    	 h_base_sequence_mac;
    	TC_RXEN_0_mac	              	 h_TC_RXEN_0_mac;
        TC_RXEN_1_mac              	     h_TC_RXEN_1_mac;
        TC_MCrS_0_mac       		     h_TC_MCrS_0_mac;
        TC_MCrS_1_mac        			 h_TC_MCrS_1_mac;
	    TC_EMPTY_0_mac         			 h_TC_EMPTY_0_mac;
        TC_EMPTY_RXBDS_mac     			 h_TC_EMPTY_RXBDS_mac;
        TC_MRxERR_1_mac        			 h_TC_MRxERR_1_mac;
        TC_NOPRE_1_mac           		 h_TC_NOPRE_1_mac ;
        TC_NOPRE_1_IL_mac         		 h_TC_NOPRE_1_IL_mac;
        TC_PRO_BRO_00_DA_MAC_mac  		 h_TC_PRO_BRO_00_DA_MAC_mac;
        TC_PRO_BRO_00_DA_BRDCST_mac 	 h_TC_PRO_BRO_00_DA_BRDCST_mac;
        TC_PRO_BRO_01_DA_MAC_mac   	     h_TC_PRO_BRO_01_DA_MAC_mac;
        TC_PRO_BRO_01_DA_BRDCST_mac       h_TC_PRO_BRO_01_DA_BRDCST_mac;
        TC_PRO_BRO_10_mac                h_TC_PRO_BRO_10_mac;
        TC_PRO_BRO_11_mac                h_TC_PRO_BRO_11_mac;
        TC_WRONG_DA_4BYTES_mac           h_TC_WRONG_DA_4BYTES_mac;
        TC_WRONG_DA_LAST_2BYTES_mac      h_TC_WRONG_DA_LAST_2BYTES_mac;
    
    
        TC_FL_LESS_THAN_MINFL_mac                h_TC_FL_LESS_THAN_MINFL_mac;
	    TC_FL_EQUAL_TO_MINFL_PAD_0_mac           h_TC_FL_EQUAL_TO_MINFL_PAD_0_mac;
        TC_FL_EQUAL_TO_MINFL_PAD_1_mac           h_TC_FL_EQUAL_TO_MINFL_PAD_1_mac;
	    TC_FL_LL_PAD_1_mac                       h_TC_FL_LL_PAD_1_mac;
        TC_FL_LL_HUGEN_1_mac                     h_TC_FL_LL_HUGEN_1_mac;
        TC_FL_LL_HUGEN_1_PAD_1_mac               h_TC_FL_LL_HUGEN_1_PAD_1_mac;
        TC_FL_GREATER_THAN_MAXFL_HUGEN_0_mac     h_TC_FL_GREATER_THAN_MAXFL_HUGEN_0_mac;
        TC_FL_GREATER_THAN_MAXFL_HUGEN_1_mac     h_TC_FL_GREATER_THAN_MAXFL_HUGEN_1_mac;
        TC_FL_GREATER_THAN_MAXFL_2KB_mac         h_TC_FL_GREATER_THAN_MAXFL_2KB_mac;
        TC_IRQ_0_MASKED_mac                      h_TC_IRQ_0_MASKED_mac;
        TC_IRQ_0_UNMASKED_mac                    h_TC_IRQ_0_UNMASKED_mac;
        TC_IRQ_1_MASKED_mac                      h_TC_IRQ_1_MASKED_mac;
        TC_IRQ_1_UNMASKED_mac                    h_TC_IRQ_1_UNMASKED_mac;
        TC_IFG_0_mac                             h_TC_IFG_0_mac;
        TC_IFG_1_mac                             h_TC_IFG_1_mac;
        TC_TXBD_NUM_128_mac                      h_TC_TXBD_NUM_128_mac;
        TC_TXBD_NUM_GREATER_128_mac              h_TC_TXBD_NUM_GREATER_128_mac;
        TC_UNALLIGNED_RX_PNTR_mac                h_TC_UNALLIGNED_RX_PNTR_mac;
        TC_INVALID_ACCESS_mac                    h_TC_INVALID_ACCESS_mac;
	    TC_CRC_ERROR_mac                         h_TC_CRC_ERROR_mac;
        TC_INSUFFICIENT_BD_mac                   h_TC_INSUFFICIENT_BD_mac;
    	TC_LAST_BD_0_mac                         h_TC_LAST_BD_0_mac;
        TC_RXBD_LEN_NE_mac                       h_TC_RXBD_LEN_NE_mac;
        TC_WRONG_PREAMBLE_mac                    h_TC_WRONG_PREAMBLE_mac;
        TC_WRONG_SFD_mac                         h_TC_WRONG_SFD_mac;
        TC_WRONG_PADDING_mac                     h_TC_WRONG_PADDING_mac;
        TC_LENGTH_LS_4_mac                       h_TC_LENGTH_LS_4_mac;
        TC_MRxDV_0_mac                           h_TC_MRxDV_0_mac;
        TC_REG_CONFIG_AFTER_RXEN_mac             h_TC_REG_CONFIG_AFTER_RXEN_mac;
        TC_IFG_LS_24_mac                         h_TC_IFG_LS_24_mac;
        TC_IFG_GS_24_mac                         h_TC_IFG_GS_24_mac;
            
          
        
        	
        	//=========MEM_SEQUENCES=================
    	     mem_pready	h_mem_pready;
    	

	reg_status	h_reg_status;

	        config_class h_config;

	   function new(string name="");
		   super.new(name);
       endfunction

       	task body();
	
       //===========host sequence memory creation================================
		
		h_base_sequence		= Base_sequence::type_id::create("h_base_sequence");
		h_reg_status		= reg_status::type_id::create("h_reg_status");
		
		h_TC_RESET	= TC_RESET::type_id::create("h_TC_RESET");
		h_TC_REG_CONFIG = TC_REG_CONFIG::type_id::create("h_TC_REG_CONFIG");
          
		h_TC_RX_EN_1_host = TC_RX_EN_1_host::type_id::create("h_TC_RX_EN_1_host");
       	h_TC_RX_EN_0_host = TC_RX_EN_0_host::type_id::create("h_TC_RX_EN_0_host");
        h_TC_MCrS_1_host = TC_MCrS_1_host ::type_id::create("h_TC_MCrS_1_host");   
        h_TC_MCrS_0_host = TC_MCrS_0_host ::type_id::create("h_TC_MCrS_0_host");   

        h_TC_EMPTY_0_host = TC_EMPTY_0_host::type_id::create("h_TC_EMPTY_0_host");
        h_TC_EMPTY_RXBDS_host = TC_EMPTY_RXBDS_host::type_id::create("h_TC_EMPTY_RXBDS_host");
        h_TC_MRxERR_1_host = TC_MRxERR_1_host::type_id::create("h_TC_MRxERR_1_host");
        h_TC_NOPRE_1_host = TC_NOPRE_1_host::type_id::create("h_TC_NOPRE_1_host");
        h_TC_NOPRE_1_IL_host = TC_NOPRE_1_IL_host::type_id::create("h_TC_NOPRE_1_IL_host");
        h_TC_PRO_BRO_00_DA_MAC_host = TC_PRO_BRO_00_DA_MAC_host::type_id::create("h_TC_PRO_BRO_00_DA_MAC_host");
        h_TC_PRO_BRO_00_DA_BRDCST_host = TC_PRO_BRO_00_DA_BRDCST_host::type_id::create("h_TC_PRO_BRO_00_DA_BRDCST_host");
        h_TC_PRO_BRO_01_DA_MAC_host = TC_PRO_BRO_01_DA_MAC_host::type_id::create("h_TC_PRO_BRO_01_DA_MAC_host");
        h_TC_PRO_BRO_01_DA_BRDCST_host = TC_PRO_BRO_01_DA_BRDCST_host::type_id::create("h_TC_PRO_BRO_01_DA_BRDCST_host");
        h_TC_PRO_BRO_10_host = TC_PRO_BRO_10_host::type_id::create("h_TC_PRO_BRO_10_host");
        h_TC_PRO_BRO_11_host = TC_PRO_BRO_11_host::type_id::create("h_TC_PRO_BRO_11_host");
        h_TC_WRONG_DA_4BYTES_host = TC_WRONG_DA_4BYTES_host::type_id::create("h_TC_WRONG_DA_4BYTES_host");
        h_TC_WRONG_DA_LAST_2BYTES_host = TC_WRONG_DA_LAST_2BYTES_host::type_id::create("h_TC_WRONG_DA_LAST_2BYTES_host");
        h_TC_FL_LESS_THAN_MINFL_host = TC_FL_LESS_THAN_MINFL_host::type_id::create("h_TC_FL_LESS_THAN_MINFL_host");
        h_TC_FL_EQUAL_TO_MINFL_PAD_0_host = TC_FL_EQUAL_TO_MINFL_PAD_0_host::type_id::create("h_TC_FL_EQUAL_TO_MINFL_PAD_0_host");
        h_TC_FL_EQUAL_TO_MINFL_PAD_1_host = TC_FL_EQUAL_TO_MINFL_PAD_1_host::type_id::create("h_TC_FL_EQUAL_TO_MINFL_PAD_1_host");
        h_TC_FL_LL_PAD_1_host = TC_FL_LL_PAD_1_host::type_id::create("h_TC_FL_LL_PAD_1_host");
        h_TC_FL_LL_HUGEN_1_host = TC_FL_LL_HUGEN_1_host::type_id::create("h_TC_FL_LL_HUGEN_1_host");
        h_TC_FL_LL_HUGEN_1_PAD_1_host = TC_FL_LL_HUGEN_1_PAD_1_host::type_id::create("h_TC_FL_LL_HUGEN_1_PAD_1_host");
        h_TC_FL_GREATER_THAN_MAXFL_HUGEN_0_host = TC_FL_GREATER_THAN_MAXFL_HUGEN_0_host::type_id::create("h_TC_FL_GREATER_THAN_MAXFL_HUGEN_0_host");
        h_TC_FL_GREATER_THAN_MAXFL_HUGEN_1_host = TC_FL_GREATER_THAN_MAXFL_HUGEN_1_host::type_id::create("h_TC_FL_GREATER_THAN_MAXFL_HUGEN_1_host");
        h_TC_FL_GREATER_THAN_MAXFL_2KB_host = TC_FL_GREATER_THAN_MAXFL_2KB_host::type_id::create("h_TC_FL_GREATER_THAN_MAXFL_2KB_host");
        h_TC_IRQ_0_MASKED_host = TC_IRQ_0_MASKED_host::type_id::create("h_TC_IRQ_0_MASKED_host");
        h_TC_IRQ_0_UNMASKED_host = TC_IRQ_0_UNMASKED_host::type_id::create("h_TC_IRQ_0_UNMASKED_host");
        h_TC_IRQ_1_MASKED_host = TC_IRQ_1_MASKED_host::type_id::create("h_TC_IRQ_1_MASKED_host");
        h_TC_IRQ_1_UNMASKED_host = TC_IRQ_1_UNMASKED_host::type_id::create("h_TC_IRQ_1_UNMASKED_host");
        h_TC_IFG_0_host = TC_IFG_0_host::type_id::create("h_TC_IFG_0_host");
        h_TC_IFG_1_host = TC_IFG_1_host::type_id::create("h_TC_IFG_1_host");
        h_TC_TXBD_NUM_128_host = TC_TXBD_NUM_128_host::type_id::create("h_TC_TXBD_NUM_128_host");
        h_TC_TXBD_NUM_GREATER_128_host = TC_TXBD_NUM_GREATER_128_host::type_id::create("h_TC_TXBD_NUM_GREATER_128_host");
        h_TC_UNALLIGNED_RX_PNTR_host = TC_UNALLIGNED_RX_PNTR_host::type_id::create("h_TC_UNALLIGNED_RX_PNTR_host");
        h_TC_INVALID_ACCESS_host = TC_INVALID_ACCESS_host::type_id::create("h_TC_INVALID_ACCESS_host");
        h_TC_CRC_ERROR_host = TC_CRC_ERROR_host::type_id::create("h_TC_CRC_ERROR_host");
        h_TC_INSUFFICIENT_BD_host = TC_INSUFFICIENT_BD_host::type_id::create("h_TC_INSUFFICIENT_BD_host");
        h_TC_LAST_BD_0_host = TC_LAST_BD_0_host::type_id::create("h_TC_LAST_BD_0_host");
        h_TC_RXBD_LEN_NE_host = TC_RXBD_LEN_NE_host::type_id::create("h_TC_RXBD_LEN_NE_host");
        h_TC_WRONG_PREAMBLE_host = TC_WRONG_PREAMBLE_host::type_id::create("h_TC_WRONG_PREAMBLE_host");
        h_TC_WRONG_SFD_host = TC_WRONG_SFD_host::type_id::create("h_TC_WRONG_SFD_host");
        h_TC_WRONG_PADDING_host = TC_WRONG_PADDING_host::type_id::create("h_TC_WRONG_PADDING_host");
        h_TC_LENGTH_LS_4_host = TC_LENGTH_LS_4_host::type_id::create("h_TC_LENGTH_LS_4_host");
        h_TC_MRxDV_0_host = TC_MRxDV_0_host::type_id::create("h_TC_MRxDV_0_host");
        h_TC_REG_CONFIG_AFTER_RXEN_host = TC_REG_CONFIG_AFTER_RXEN_host::type_id::create("h_TC_REG_CONFIG_AFTER_RXEN_host");
        h_TC_IFG_LS_24_host = TC_IFG_LS_24_host::type_id::create("h_TC_IFG_LS_24_host");
        h_TC_IFG_GS_24_host = TC_IFG_GS_24_host::type_id::create("h_TC_IFG_GS_24_host");


       //=====mac sequences memory creation=========================================
         h_base_sequence_mac= Base_sequence_mac::type_id::create(" h_base_sequence_mac");   
         h_TC_RXEN_0_mac = TC_RXEN_0_mac::type_id::create("h_TC_RXEN_0_mac");
         h_TC_RXEN_1_mac = TC_RXEN_1_mac::type_id::create("h_TC_RXEN_1_mac");
         h_TC_MCrS_0_mac = TC_MCrS_0_mac::type_id::create(" h_TC_MCrS_0_mac");
         h_TC_MCrS_1_mac = TC_MCrS_1_mac::type_id::create(" h_TC_MCrS_1_mac");
         h_TC_EMPTY_0_mac =TC_EMPTY_0_mac::type_id::create(" h_TC_EMPTY_0_mac");
         h_TC_EMPTY_RXBDS_mac = TC_EMPTY_RXBDS_mac::type_id::create("h_TC_EMPTY_RXBDS_mac");
      	 h_TC_MRxERR_1_mac= TC_MRxERR_1_mac::type_id::create("h_TC_MRxERR_1_mac");
         h_TC_NOPRE_1_mac= TC_NOPRE_1_mac::type_id::create(" h_ TC_NOPRE_1_mac");                          // UPTO 10TH  CASES
       	 h_TC_NOPRE_1_IL_mac = TC_NOPRE_1_IL_mac::type_id::create("h_TC_NOPRE_1_IL_mac");
         h_TC_PRO_BRO_00_DA_MAC_mac = TC_PRO_BRO_00_DA_MAC_mac::type_id::create("h_ TC_PRO_BRO_00_DA_MAC_mac");
         h_TC_PRO_BRO_00_DA_BRDCST_mac = TC_PRO_BRO_00_DA_BRDCST_mac::type_id::create(" h_TC_PRO_BRO_00_DA_BRDCST_mac");
         h_TC_PRO_BRO_01_DA_MAC_mac= TC_PRO_BRO_01_DA_MAC_mac::type_id::create("h_ TC_PRO_BRO_01_DA_MAC_mac");
         h_TC_PRO_BRO_01_DA_BRDCST_mac= TC_PRO_BRO_01_DA_BRDCST_mac::type_id::create("h_ TC_PRO_BRO_01_DA_BRDCST_mac");
         h_TC_PRO_BRO_10_mac = TC_PRO_BRO_10_mac::type_id::create(" h_TC_PRO_BRO_10_mac");
         h_TC_PRO_BRO_11_mac= TC_PRO_BRO_11_mac::type_id::create("h_TC_PRO_BRO_11_mac");
         h_TC_WRONG_DA_4BYTES_mac = TC_WRONG_DA_4BYTES_mac::type_id::create("h_TC_WRONG_DA_4BYTES_mac");
         h_TC_WRONG_DA_LAST_2BYTES_mac= TC_WRONG_DA_LAST_2BYTES_mac::type_id::create("h_TC_WRONG_DA_LAST_2BYTES_mac");
      
h_TC_FL_LESS_THAN_MINFL_mac = TC_FL_LESS_THAN_MINFL_mac::type_id::create("h_TC_FL_LESS_THAN_MINFL_mac");
h_TC_FL_EQUAL_TO_MINFL_PAD_0_mac = TC_FL_EQUAL_TO_MINFL_PAD_0_mac::type_id::create("h_TC_FL_EQUAL_TO_MINFL_PAD_0_mac");
h_TC_FL_EQUAL_TO_MINFL_PAD_1_mac = TC_FL_EQUAL_TO_MINFL_PAD_1_mac::type_id::create("h_TC_FL_EQUAL_TO_MINFL_PAD_1_mac");
h_TC_FL_LL_PAD_1_mac = TC_FL_LL_PAD_1_mac::type_id::create("h_TC_FL_LL_PAD_1_mac");
h_TC_FL_LL_HUGEN_1_mac = TC_FL_LL_HUGEN_1_mac::type_id::create("h_TC_FL_LL_HUGEN_1_mac");
h_TC_FL_LL_HUGEN_1_PAD_1_mac = TC_FL_LL_HUGEN_1_PAD_1_mac::type_id::create("h_TC_FL_LL_HUGEN_1_PAD_1_mac");
h_TC_FL_GREATER_THAN_MAXFL_HUGEN_0_mac = TC_FL_GREATER_THAN_MAXFL_HUGEN_0_mac::type_id::create("h_TC_FL_GREATER_THAN_MAXFL_HUGEN_0_mac");
h_TC_FL_GREATER_THAN_MAXFL_HUGEN_1_mac = TC_FL_GREATER_THAN_MAXFL_HUGEN_1_mac::type_id::create("h_TC_FL_GREATER_THAN_MAXFL_HUGEN_1_mac");
h_TC_FL_GREATER_THAN_MAXFL_2KB_mac = TC_FL_GREATER_THAN_MAXFL_2KB_mac::type_id::create("h_TC_FL_GREATER_THAN_MAXFL_2KB_mac");
h_TC_IRQ_0_MASKED_mac = TC_IRQ_0_MASKED_mac::type_id::create("h_TC_IRQ_0_MASKED_mac");
h_TC_IRQ_0_UNMASKED_mac = TC_IRQ_0_UNMASKED_mac::type_id::create("h_TC_IRQ_0_UNMASKED_mac");
h_TC_IRQ_1_MASKED_mac = TC_IRQ_1_MASKED_mac::type_id::create("h_TC_IRQ_1_MASKED_mac");
h_TC_IRQ_1_UNMASKED_mac = TC_IRQ_1_UNMASKED_mac::type_id::create("h_TC_IRQ_1_UNMASKED_mac");
h_TC_IFG_0_mac = TC_IFG_0_mac::type_id::create("h_TC_IFG_0_mac");
h_TC_IFG_1_mac = TC_IFG_1_mac::type_id::create("h_TC_IFG_1_mac");
h_TC_TXBD_NUM_128_mac = TC_TXBD_NUM_128_mac::type_id::create("h_TC_TXBD_NUM_128_mac");
h_TC_TXBD_NUM_GREATER_128_mac = TC_TXBD_NUM_GREATER_128_mac::type_id::create("h_TC_TXBD_NUM_GREATER_128_mac");
h_TC_UNALLIGNED_RX_PNTR_mac = TC_UNALLIGNED_RX_PNTR_mac::type_id::create("h_TC_UNALLIGNED_RX_PNTR_mac");
h_TC_INVALID_ACCESS_mac = TC_INVALID_ACCESS_mac::type_id::create("h_TC_INVALID_ACCESS_mac");
h_TC_CRC_ERROR_mac = TC_CRC_ERROR_mac::type_id::create("h_TC_CRC_ERROR_mac");
h_TC_INSUFFICIENT_BD_mac = TC_INSUFFICIENT_BD_mac::type_id::create("h_TC_INSUFFICIENT_BD_mac");
h_TC_LAST_BD_0_mac = TC_LAST_BD_0_mac::type_id::create("h_TC_LAST_BD_0_mac");
h_TC_RXBD_LEN_NE_mac = TC_RXBD_LEN_NE_mac::type_id::create("h_TC_RXBD_LEN_NE_mac");
h_TC_WRONG_PREAMBLE_mac = TC_WRONG_PREAMBLE_mac::type_id::create("h_TC_WRONG_PREAMBLE_mac");
h_TC_WRONG_SFD_mac = TC_WRONG_SFD_mac::type_id::create("h_TC_WRONG_SFD_mac");
h_TC_WRONG_PADDING_mac = TC_WRONG_PADDING_mac::type_id::create("h_TC_WRONG_PADDING_mac");
h_TC_LENGTH_LS_4_mac = TC_LENGTH_LS_4_mac::type_id::create("h_TC_LENGTH_LS_4_mac");
h_TC_MRxDV_0_mac = TC_MRxDV_0_mac::type_id::create("h_TC_MRxDV_0_mac");
h_TC_REG_CONFIG_AFTER_RXEN_mac = TC_REG_CONFIG_AFTER_RXEN_mac::type_id::create("h_TC_REG_CONFIG_AFTER_RXEN_mac");
h_TC_IFG_LS_24_mac = TC_IFG_LS_24_mac::type_id::create("h_TC_IFG_LS_24_mac");
h_TC_IFG_GS_24_mac = TC_IFG_GS_24_mac::type_id::create("h_TC_IFG_GS_24_mac");


     
       		//====MEMORY SEQUENCES MEMEROY CREATION======================================

		h_mem_pready	= mem_pready::type_id::create("h_mem_pready");
    
	  	//======starting sequences on particular sequencer============================
         
         	//-------sanity test cases--------------------------------------------
            	/*//`ifdef TC_RESET;
			h_TC_RESET.start(p_sequencer.h_host_sequencer);
             	//`endif
	       
	         
	        //`ifdef TC_REG_CONFIG;
				h_TC_REG_CONFIG.start(p_sequencer.h_host_sequencer);
	          //`endif

         	//------feature cases----------------------------------------------------
             	//`ifdef TC_RX_EN_0;
                   begin
		             	h_TC_RX_EN_0_host.start(p_sequencer.h_host_sequencer);
		        	fork			
	  	       		     h_TC_RXEN_0_mac.start(p_sequencer.h_mac_sequencer);					
			 		     h_mem_pready.start(p_sequencer.h_mem_sequencer);
				    join_any        
	    	      end
               //`endif

             	//`ifdef TC_RX_EN_1;
                 begin
		         h_TC_RX_EN_1_host.start(p_sequencer.h_host_sequencer);
			 fork
	  	             h_TC_RXEN_1_mac.start(p_sequencer.h_mac_sequencer);				
			     h_mem_pready.start(p_sequencer.h_mem_sequencer);
			 join_any
			 h_reg_status.start(p_sequencer.h_host_sequencer);
		  end	
           	//`endif

              //`ifdef TC_MCrS_0;
	  	begin
		         	h_TC_MCrS_0_host.start(p_sequencer.h_host_sequencer);
			        fork
	  	                h_TC_MCrS_0_mac.start(p_sequencer.h_mac_sequencer);					 
			            h_mem_pready.start(p_sequencer.h_mem_sequencer);
			        join_any
          	      end	 
              //`endif

              //`ifdef TC_MCrS_1;
                  begin
		         	h_TC_MCrS_1_host.start(p_sequencer.h_host_sequencer);
			        fork
	  	                h_TC_MCrS_1_mac.start(p_sequencer.h_mac_sequencer);					 
			            h_mem_pready.start(p_sequencer.h_mem_sequencer);
			        join_any
          	      end	 
              //`endif

              //`ifdef TC_EMPTY_0
                  begin
                       h_TC_EMPTY_0_host.start(p_sequencer.h_host_sequencer);
                    fork
                       h_TC_EMPTY_0_mac.start(p_sequencer.h_mac_sequencer);
                       h_mem_pready.start(p_sequencer.h_mem_sequencer);
                  join_any
			 h_reg_status.start(p_sequencer.h_host_sequencer);
		  
                 end
                //`endif

                //`ifdef TC_EMPTY_RXBDS;
                    begin
                      h_TC_EMPTY_RXBDS_host.start(p_sequencer.h_host_sequencer);
                     fork
                        h_TC_EMPTY_RXBDS_mac.start(p_sequencer.h_mac_sequencer);
                         h_mem_pready.start(p_sequencer.h_mem_sequencer);
                     join_any
                   end
                //`endif


//`ifdef TC_MRxERR_1;
begin
    h_TC_MRxERR_1_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_MRxERR_1_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_NOPRE_1;
begin
    h_TC_NOPRE_1_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_NOPRE_1_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_NOPRE_1_IL;
begin
    h_TC_NOPRE_1_IL_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_NOPRE_1_IL_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_PRO_BRO_00_DA_MAC;
begin
    h_TC_PRO_BRO_00_DA_MAC_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_PRO_BRO_00_DA_MAC_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_PRO_BRO_00_DA_BRDCST;
begin
    h_TC_PRO_BRO_00_DA_BRDCST_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_PRO_BRO_00_DA_BRDCST_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_PRO_BRO_01_DA_MAC;
begin
    h_TC_PRO_BRO_01_DA_MAC_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_PRO_BRO_01_DA_MAC_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_PRO_BRO_01_DA_BRDCST;
begin
    h_TC_PRO_BRO_01_DA_BRDCST_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_PRO_BRO_01_DA_BRDCST_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_PRO_BRO_10;
begin
    h_TC_PRO_BRO_10_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_PRO_BRO_10_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_PRO_BRO_11;
begin
    h_TC_PRO_BRO_11_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_PRO_BRO_11_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_WRONG_DA_4BYTES;
begin
    h_TC_WRONG_DA_4BYTES_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_WRONG_DA_4BYTES_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

////`ifdef TC_WRONG_DA_LAST_2BYTES;
begin
    h_TC_WRONG_DA_LAST_2BYTES_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_WRONG_DA_LAST_2BYTES_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
////`endif
	


//`ifdef TC_FL_LESS_THAN_MINFL;
begin
    h_TC_FL_LESS_THAN_MINFL_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_FL_LESS_THAN_MINFL_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_FL_EQUAL_TO_MINFL_PAD_0;
begin
    h_TC_FL_EQUAL_TO_MINFL_PAD_0_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_FL_EQUAL_TO_MINFL_PAD_0_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_FL_EQUAL_TO_MINFL_PAD_1;
begin
    h_TC_FL_EQUAL_TO_MINFL_PAD_1_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_FL_EQUAL_TO_MINFL_PAD_1_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_FL_LL_PAD_1;
begin
    h_TC_FL_LL_PAD_1_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_FL_LL_PAD_1_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_FL_LL_HUGEN_1;
begin
    h_TC_FL_LL_HUGEN_1_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_FL_LL_HUGEN_1_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_FL_LL_HUGEN_1_PAD_1;
begin
    h_TC_FL_LL_HUGEN_1_PAD_1_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_FL_LL_HUGEN_1_PAD_1_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_FL_GREATER_THAN_MAXFL_HUGEN_0;
begin
    h_TC_FL_GREATER_THAN_MAXFL_HUGEN_0_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_FL_GREATER_THAN_MAXFL_HUGEN_0_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_FL_GREATER_THAN_MAXFL_HUGEN_1;
begin
    h_TC_FL_GREATER_THAN_MAXFL_HUGEN_1_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_FL_GREATER_THAN_MAXFL_HUGEN_1_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_FL_GREATER_THAN_MAXFL_2KB;
begin
    h_TC_FL_GREATER_THAN_MAXFL_2KB_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_FL_GREATER_THAN_MAXFL_2KB_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_IRQ_0_MASKED;
begin
    h_TC_IRQ_0_MASKED_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_IRQ_0_MASKED_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_IRQ_0_UNMASKED;
begin
    h_TC_IRQ_0_UNMASKED_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_IRQ_0_UNMASKED_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_IRQ_1_MASKED;
begin
    h_TC_IRQ_1_MASKED_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_IRQ_1_MASKED_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_IRQ_1_UNMASKED;
begin
    h_TC_IRQ_1_UNMASKED_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_IRQ_1_UNMASKED_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_IFG_0;
begin
    h_TC_IFG_0_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_IFG_0_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_IFG_1;
begin
    h_TC_IFG_1_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_IFG_1_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_TXBD_NUM_128;
begin
    h_TC_TXBD_NUM_128_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_TXBD_NUM_128_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_TXBD_NUM_GREATER_128;
begin
    h_TC_TXBD_NUM_GREATER_128_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_TXBD_NUM_GREATER_128_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_UNALLIGNED_RX_PNTR;
begin
    h_TC_UNALLIGNED_RX_PNTR_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_UNALLIGNED_RX_PNTR_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_INVALID_ACCESS;
begin
    h_TC_INVALID_ACCESS_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_INVALID_ACCESS_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_CRC_ERROR;
begin
    h_TC_CRC_ERROR_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_CRC_ERROR_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_INSUFFICIENT_BD;
begin
    h_TC_INSUFFICIENT_BD_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_INSUFFICIENT_BD_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_LAST_BD_0;
begin
    h_TC_LAST_BD_0_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_LAST_BD_0_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_RXBD_LEN_NE;
begin
    h_TC_RXBD_LEN_NE_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_RXBD_LEN_NE_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_WRONG_PREAMBLE;
begin
    h_TC_WRONG_PREAMBLE_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_WRONG_PREAMBLE_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_WRONG_SFD;
begin
    h_TC_WRONG_SFD_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_WRONG_SFD_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_WRONG_PADDING;
begin
    h_TC_WRONG_PADDING_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_WRONG_PADDING_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
    h_reg_status.start(p_sequencer.h_host_sequencer);    
end
//`endif

//`ifdef TC_LENGTH_LS_4;
begin
    h_TC_LENGTH_LS_4_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_LENGTH_LS_4_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
    h_reg_status.start(p_sequencer.h_host_sequencer);    
    
end
//`endif
*/
//`ifdef TC_MRxDV_0;
begin
    h_TC_MRxDV_0_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_MRxDV_0_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
    h_reg_status.start(p_sequencer.h_host_sequencer);        
end
//`endif
/*
//`ifdef TC_REG_CONFIG_AFTER_RXEN;
begin
    h_TC_REG_CONFIG_AFTER_RXEN_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_REG_CONFIG_AFTER_RXEN_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_IFG_LS_24;
begin
    h_TC_IFG_LS_24_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_IFG_LS_24_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif

//`ifdef TC_IFG_GS_24;
begin
    h_TC_IFG_GS_24_host.start(p_sequencer.h_host_sequencer);
    fork
        h_TC_IFG_GS_24_mac.start(p_sequencer.h_mac_sequencer);
        h_mem_pready.start(p_sequencer.h_mem_sequencer);
    join_any
end
//`endif*/
	
	endtask
endclass
