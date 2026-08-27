class ethernet_seq_item extends uvm_sequence_item;

	//=======FACTOR REGISTRATION
	`uvm_object_utils(ethernet_seq_item)

	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "ethernet_seq_item");
		super.new(rgstr_name);
	endfunction

	//=====>>HOST APB<<=====
	rand bit prstn_i; 
	rand bit psel_i;
	rand bit penable_i;
	rand bit pwrite_i;
	rand bit [31:0] paddr_i;
	rand bit [31:0] pwdata_i;
	int prdata_o;
	bit pready_o;

	//=====>>INTERRUPT<<=====
	bit int_o;
	
	//=====>>MEMORY APB<<=====
	rand bit m_pready_i;
	rand int m_prdata_i; 
	bit m_psel_o;
	bit m_pwrite_o;
	bit m_penable_o;
	int m_paddr_o;
	int m_pwdata_o;
	
	//=====>>RX MAC<<=====
	rand bit MRxDV;
	rand bit[3:0] MRxD;
	rand bit MRxErr;
	rand bit MCrS;

	//=========>>TYPEDEF DECLARATIONS<<========
	typedef enum {MODER,INT_SOURCE,INT_MASK,TX_BD_NUM,MII_ADDR,MAC_ADDR0,MAC_ADDR1,RX_BD,RX_BD_PTR} reg_type;

	typedef enum {RESET_LOW,RESET_HIGH} reset_e;
    	typedef enum {SEL_LOW,SEL_HIGH} sel_e;
	typedef enum {WRITE,READ} rw_mode;

	typedef enum {TXBDNUM_GT_128,TXBDNUM_EQ_128,TXBDNUM_LS_128} txbdnum_e;
	
	//------MODER
	typedef enum {PAD_1,PAD_0} pad_e;
	typedef enum {HUGEN_1,HUGEN_0} hugen_e;
	typedef enum {IFG_0,IFG_1} ifg_e;
	typedef enum {PRO_0,PRO_1} pro_e;
	typedef enum {BRO_0,BRO_1} bro_e;
	typedef enum {NOPRE_HIGH,NOPRE_LOW} nopre_e;
	typedef enum {RXEN_0,RXEN_1} Rxen_e;

	//--------INT MASK
	typedef enum {ONLY_RXE_M_01,ONLY_RXF_M_10,BOTH_RX_00,BOTH_RX_11} int_mask;

	//--------RXBD
	typedef enum {LT_4BYTES,LT_MINFL,MINFL,NORMAL,GT_MAXFL_LT_2KB,GT_2KB} fl_e;
	typedef enum {EMPTY_0,EMPTY_1} empty_e;
	typedef enum {IRQ_0,IRQ_1} irq_e;

	typedef enum {ALIGNED,UNALIGNED} rxbd_ptr_e;

	typedef enum {PATTERN,SFD,DEFAULT,ALL_ZEROES,MCRS_HIGH,ERROR,ADDZEROS,MRXDV_INVALID,BRDCST} pkt_e;		//---for mac sequences
	
	typedef enum {GOOD_PACKET,BAD_PACKET} pkt_type_e;

	//==========>>RAND DECLARATIONS FOR ENUMS<<=========
    	rand sel_e      SEL;
	rand reset_e	RESET;	

	rand reg_type	reg_ptr;	
	rand rw_mode	rw;

	rand pad_e	PAD;
	rand hugen_e	HUGEN;
	rand ifg_e	IFG;
	rand pro_e	PRO;
	rand bro_e	BRO;
	rand nopre_e	NOPRE;
	rand Rxen_e	RXEN;

	rand txbdnum_e	TXBD_NUM;

	rand fl_e	FL;
	rand empty_e	EMPTY;
	rand irq_e	IRQ;
	rand int_mask	rx_mask;		//------INT_MASK

	rand rxbd_ptr_e RXBD_PTR_DATA;

	rand pkt_e	MAC_FIELD;

	rand pkt_type_e	PACKET_TYPE;

	//===========>>TEMP REGISTERS<<================
	rand bit [31:0] TX_BD_NUM_value;

	//======>>CONSTRAINTS<<============
	constraint default_val { 	soft prstn_i == 1'b1;
					soft pwdata_i == 1'b1;}

   	constraint reset_bit {
                        if(RESET == RESET_LOW){
                              prstn_i == 0;}
                         else{
                              prstn_i == 1;}
						 }

   	constraint sel_bit {
                        if(SEL==SEL_HIGH){
                              psel_i ==1;}
                         else{
                              psel_i==0;} }

	constraint reg_rw_mode {
                       		if(rw==WRITE){
					       	soft pwrite_i == 1;}
					   else{
					   	soft pwrite_i == 0;}  }

	constraint paddr_range {
                           if(reg_ptr == MODER) {soft paddr_i == 'h00 ;}
                           if(reg_ptr == INT_SOURCE) {soft paddr_i == 'h04 ;}
                           if(reg_ptr == INT_MASK) {soft paddr_i == 'h08 ;}
                           if(reg_ptr == TX_BD_NUM) {paddr_i == 'h20 ; }
                           if(reg_ptr == MII_ADDR) {soft paddr_i == 'h30 ;}
                           if(reg_ptr == MAC_ADDR0) {soft paddr_i == 'h40 ;}
                           if(reg_ptr == MAC_ADDR1) {soft paddr_i == 'h44 ;}
                           if(reg_ptr == RX_BD) {soft paddr_i inside {['h400:'h7FF]} ;}
						}

	constraint tx_bd_num_range {if(reg_ptr == TX_BD_NUM)
									{
									//soft pwdata_i inside {[0:128]};
									
									(TXBD_NUM == TXBDNUM_GT_128) ->  pwdata_i > 128 ;
									(TXBD_NUM == TXBDNUM_EQ_128) ->  pwdata_i == 128 ;
									(TXBD_NUM == TXBDNUM_LS_128) ->  soft pwdata_i inside {[120:127]} ;


									TX_BD_NUM_value == pwdata_i ;	//-----for RXBDs
									}

								}

	constraint reg_reserved_bits {
									if(reg_ptr == MODER)
										{ 
										  pwdata_i[31:16] == 0 ;
										  pwdata_i[13:8] == 0 ;
										  //pwdata_i[10:8] == 0 ;
										  pwdata_i[7] 	== 0 ;
										  //pwdata_i[9] 	== 1 ;

										soft pwdata_i[6] == 0 ;			//--------IFG

										  pwdata_i[4]	== 0 ;
										  pwdata_i[1]	== 0 ;			//--------TXEN
										  
										  }

									if(reg_ptr == MII_ADDR) 
										{ pwdata_i[31:5] == 0;}

									if(reg_ptr == MAC_ADDR1)
										{ pwdata_i[31:16] == 0;}

									if(reg_ptr == INT_SOURCE) 
										{ pwdata_i[31:4] == 0;
										  pwdata_i[1:0] == 0 ;}

									if(reg_ptr == INT_MASK) 
										{ pwdata_i[31:4] == 0;
										  pwdata_i[1:0] == 0 ;}

								}

	
	
	constraint Moder_bit_config { 
								  if(reg_ptr == MODER) {
									if(PAD == PAD_1)
									{ pwdata_i[15] == 1 ;}
									if(PAD == PAD_0)
									{ pwdata_i[15] == 0 ;}
									
									if(HUGEN == HUGEN_0)
									{ pwdata_i[14] == 0 ;}
									if(HUGEN == HUGEN_1)
									{ pwdata_i[14] == 1 ;}

								  if (IFG == IFG_1) 
									{ pwdata_i[6] == 1 ;}	//-----IFG
								  else
									{ pwdata_i[6] == 0 ;}	//-----IFG


									if(PRO == PRO_0)
									{ pwdata_i[5] == 0 ;}
									else
									{ pwdata_i[5] == 1 ;} 

									if(BRO == BRO_0)
									{ pwdata_i[3] == 0 ;}
									else
									{ pwdata_i[3] == 1 ;}

									if(NOPRE == NOPRE_LOW)
									{ pwdata_i[2] == 0 ;}
									if(NOPRE == NOPRE_HIGH)
									{ pwdata_i[2] == 1 ;}

									if(RXEN == RXEN_1)
									{ pwdata_i[0] == 1 ;}
									if(RXEN == RXEN_0)
									{ pwdata_i[0] == 0 ;}

									soft pwdata_i[0] == 1 ;			//---------RXEN = 1 

								  }

							} 

	constraint reg_config {
							if (reg_ptr == MAC_ADDR1) {
									
									soft pwdata_i[15:0] == 'habcd ;		//-----------given address

								}
							else if (reg_ptr == MAC_ADDR0) {
									soft pwdata_i[31:0] == 'h0 ;		//----------given address
									
								}
							else if (reg_ptr == MII_ADDR) {
								soft pwdata_i[4]   == 'h0 ;				//------------given address
								soft pwdata_i[3:0] == 'hC ;				//------------given address
								}

							else if (reg_ptr == INT_MASK) {
								soft pwdata_i[3:0] == 'b1100 ;		//----------default RXE_M,RXE_F = 1

								(rx_mask == ONLY_RXE_M_01) -> pwdata_i[3:0] 	== 'b0100 ;
								(rx_mask == ONLY_RXF_M_10) -> pwdata_i[3:0] 	== 'b1000 ;
								(rx_mask == BOTH_RX_00) 	->pwdata_i[3:0] 	== 'b0000 ;
								(rx_mask == BOTH_RX_11) 	->pwdata_i[3:0] 	== 'b1100 ;

								}
								
							else if (reg_ptr == INT_SOURCE) {
								
								soft pwdata_i[3:0] 	== 'b1100 ;
								}
								
									}

							
	constraint RxD_config {if (reg_ptr == RX_BD)
								{
									
									pwdata_i[13:8] 	== 0 ;				
									pwdata_i[6:4] 	== 0 ;				
									pwdata_i[3] 	== 0 ;				
									pwdata_i[2] 	== 0 ;				
									pwdata_i[0] 	== 0 ;				

									if(IRQ == IRQ_0) 
										{pwdata_i[14] == 0 ;}
									else 
										{pwdata_i[14] == 1 ;}

									if(EMPTY == EMPTY_0) 
										{pwdata_i[15] == 0 ;}
									else 
										{pwdata_i[15] == 1 ;}


								  }
							}  

	constraint Aligned_rxbd_ptr { if(reg_ptr == RX_BD_PTR) {
										soft pwdata_i % 4 == 0 ;

									(RXBD_PTR_DATA == UNALIGNED) ->  pwdata_i % 4 != 0 ;
									(RXBD_PTR_DATA == ALIGNED) ->  pwdata_i % 4 == 0 ;

									}
									
								}


	constraint FL_range {	if(reg_ptr == RX_BD && paddr_i % 8 == 0)	{

							(FL == LT_4BYTES) -> pwdata_i[31:16] < 4;		//-----------SPEC VIOLATION CASE
							(FL == LT_MINFL) -> pwdata_i[31:16] < 46;
							(FL == MINFL) -> pwdata_i[31:16] == 46;
							(FL == NORMAL) -> pwdata_i[31:16] inside {[46:1500]};
							(FL == GT_MAXFL_LT_2KB) -> pwdata_i[31:16] inside {[1500:2047]};
							(FL == GT_2KB) -> pwdata_i[31:16] > 2047;
							}
									}



//---------------------------------------MAC SEQUENCE------------------------------------

	constraint Mac_seq { if(MAC_FIELD == ALL_ZEROES)
							{
          						MRxD == 0; MRxDV == 0;MCrS ==0; MRxErr == 0 ;								
							}
						else if(MAC_FIELD == PATTERN){
								MRxD == 4'b0101 ; MCrS == 1; MRxDV == 1; MRxErr == 0 ;	
							}
						else if(MAC_FIELD == SFD){
								MRxD == 4'b1101 ; MCrS == 1; MRxDV == 1; MRxErr == 0 ;
							}
						else if(MAC_FIELD == BRDCST){
								MRxD == 4'b1111 ; MCrS == 1; MRxDV == 1; MRxErr == 0 ;		
							}
						else if(MAC_FIELD == DEFAULT) {
								MCrS == 1 ;MRxDV == 1; MRxErr == 0 ;
							}
						else if(MAC_FIELD == ADDZEROS) {
								MRxD == 4'd0 ;MRxDV == 1; MCrS == 1; MRxErr == 0 ; 
							}
						else if (MAC_FIELD == MCRS_HIGH) {
								MCrS == 1 ; MRxDV == 0; MRxErr == 0 ;
							}
						else if (MAC_FIELD == ERROR) {
								MCrS == 1 ; MRxDV == 1; MRxErr == 1 ;
							}
						else if (MAC_FIELD == MRXDV_INVALID) {
								MCrS == 1 ; MRxDV == 0; MRxErr == 0 ;
							}
						
					}



endclass

/*
class ethernet_seq_item extends uvm_sequence_item;

	//=======FACTOR REGISTRATION
	`uvm_object_utils(ethernet_seq_item)

	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "ethernet_seq_item");
		super.new(rgstr_name);
	endfunction

	//=====>>HOST APB<<=====
	rand bit prstn_i; 
	rand bit psel_i;
	rand bit penable_i;
	rand bit pwrite_i;
	rand bit [31:0] paddr_i;
	rand bit [31:0] pwdata_i;
	int prdata_o;
	bit pready_o;

	//=====>>INTERRUPT<<=====
	bit int_o;
	
	//=====>>MEMORY APB<<=====
	rand bit m_pready_i;
	rand int m_prdata_i; 
	bit m_psel_o;
	bit m_pwrite_o;
	bit m_penable_o;
	int m_paddr_o;
	int m_pwdata_o;

	//=====>>TX MAC<<=====
	bit[3:0] MTxD;
	bit MTxEn;
	bit MTxErr;
	
	//=====>>RX MAC<<=====
	rand bit MRxDV;
	rand bit[3:0] MRxD;
	rand bit MRxErr;
	rand bit MCrS;

	//=========>>TYPEDEF DECLARATIONS<<========
	typedef enum {MODER,INT_SOURCE,INT_MASK,TX_BD_NUM,MII_ADDR,MAC_ADDR0,MAC_ADDR1,RX_BD,RX_BD_PTR} reg_type;

//	typedef enum {IDLE,SETUP} phase_e;
    typedef enum {SEL_LOW,SEL_HIGH} sel_e;
	typedef enum {WRITE,READ} rw_mode;

	typedef enum {TXBDNUM_GT_128,TXBDNUM_EQ_128} txbdnum_e;

	typedef enum {PAD_1,PAD_0} pad_e;
	typedef enum {HUGEN_1,HUGEN_0} hugen_e;
	typedef enum {IFG_0,IFG_1} ifg_e;
	typedef enum {PRO_0,PRO_1} pro_e;
	typedef enum {BRO_0,BRO_1} bro_e;
	typedef enum {NOPRE_HIGH,NOPRE_LOW} nopre_e;
	typedef enum {RXEN_0,RXEN_1} Rxen_e;

	typedef enum {ONLY_RXE_M_01,ONLY_RXF_M_10,BOTH_RX_00,BOTH_RX_11} int_mask;


	typedef enum {LT_4BYTES,LT_MINFL,MINFL,NORMAL,GT_MAXFL_LT_2KB,GT_2KB} fl_e;
	typedef enum {EMPTY_0,EMPTY_1} empty_e;
	typedef enum {IRQ_0,IRQ_1} irq_e;

	typedef enum {ALIGNED,UNALIGNED} rxbd_ptr_e;

	//==========>>RAND DECLARATIONS FOR ENUMS<<=========
    rand sel_e      SEL;

	rand reg_type	reg_ptr;
//	rand phase_e	apb_phase;
	rand rw_mode	rw;

	rand pad_e		PAD;
	rand hugen_e	HUGEN;
	rand ifg_e		IFG;
	rand pro_e		PRO;
	rand bro_e		BRO;
	rand nopre_e	NOPRE;
	rand Rxen_e		RXEN;

	rand txbdnum_e	TXBD_NUM;

	rand fl_e		FL;
	rand empty_e	EMPTY;
	rand irq_e		IRQ;
	rand int_mask	rx_mask;		//------INT_MASK

	rand rxbd_ptr_e RXBD_PTR_DATA;

	//===========>>TEMP REGISTERS<<================
	rand bit [31:0] TX_BD_NUM_value;

	//======>>CONSTRAINTS<<============
	constraint default_val { //	soft prstn_i == 1'b1;
								soft pwdata_i == 1'b1;}

/*	constraint phases {	
	                     if(apb_phase == IDLE){
						         psel_i==0;
								// prstn_i ==0;
								 } 
					    
                         if(apb_phase ==SETUP){
						        psel_i==1;
							//	prstn_i==1;
								penable_i==0;}
                           }

   constraint sel_bit {
                        if(SEL==SEL_HIGH){
                              psel_i ==1;}
                         else{
                              psel_i==0;} }
	constraint reg_rw_mode {
                       		if(rw==WRITE){
					       		soft pwrite_i == 1;}
					   		else{
					       		soft pwrite_i == 0;}  }

	constraint paddr_range {
                           if(reg_ptr == MODER) {soft paddr_i == 'h00 ;}
                           if(reg_ptr == INT_SOURCE) {soft paddr_i == 'h04 ;}
                           if(reg_ptr == INT_MASK) {soft paddr_i == 'h08 ;}
                           if(reg_ptr == TX_BD_NUM) {soft paddr_i == 'h20 ; }
                           if(reg_ptr == MII_ADDR) {soft paddr_i == 'h30 ;}
                           if(reg_ptr == MAC_ADDR0) {soft paddr_i == 'h40 ;}
                           if(reg_ptr == MAC_ADDR1) {soft paddr_i == 'h44 ;}
                           if(reg_ptr == RX_BD) {soft paddr_i inside {['h400:'h7FF]} ;}
						}

	constraint tx_bd_num_range {if(reg_ptr == TXBD_NUM)
									{
									soft pwdata_i inside {[0:128]};
									
									(TXBD_NUM == TXBDNUM_GT_128) ->  pwdata_i > 128 ;
									(TXBD_NUM == TXBDNUM_EQ_128) ->  pwdata_i == 128 ;

									TX_BD_NUM_value == pwdata_i ;	//-----for RXBDs
									}

								}

	constraint reg_reserved_bits {
									if(reg_ptr == MODER)
										{ 
										  pwdata_i[31:16] == 0 ;
										  pwdata_i[13:8] == 0 ;
										  //pwdata_i[10:8] == 0 ;
										  pwdata_i[7] 	== 0 ;
										  //pwdata_i[9] 	== 1 ;

										soft pwdata_i[6] == 0 ;			//--------IFG

										  pwdata_i[4]	== 0 ;
										  pwdata_i[1]	== 0 ;
										  
										  }

									/*if(reg_ptr == MII_ADDR) 
										{ pwdata_i[31:5] == 0;}/

									if(reg_ptr == MAC_ADDR1)
										{ pwdata_i[31:16] == 0;}

									if(reg_ptr == INT_SOURCE) 
										{ pwdata_i[31:4] == 0;
										  pwdata_i[1:0] == 0 ;}

									if(reg_ptr == INT_MASK) 
										{ pwdata_i[31:4] == 0;
										  pwdata_i[1:0] == 0 ;}

								}

	constraint Moder_bit_config { 
								  if(reg_ptr == MODER) {
									if(PAD == PAD_1)
									{ pwdata_i[15] == 1 ;}
									if(PAD == PAD_0)
									{ pwdata_i[15] == 0 ;}
									
									if(HUGEN == HUGEN_0)
									{ pwdata_i[14] == 0 ;}
									if(HUGEN == HUGEN_1)
									{ pwdata_i[14] == 1 ;}

									if(RXEN == RXEN_1)
									{ pwdata_i[0] == 1 ;}
									if(RXEN == RXEN_0)
									{ pwdata_i[0] == 0 ;}

								  if (IFG == IFG_1) 
									{ pwdata_i[6] == 1 ;}	//-----IFG
								  else
									{ pwdata_i[6] == 0 ;}	//-----IFG


									if(PRO == PRO_0)
									{ pwdata_i[5] == 0 ;}
									else
									{ pwdata_i[5] == 1 ;} 

									if(BRO == BRO_0)
									{ pwdata_i[3] == 0 ;}
									else
									{ pwdata_i[3] == 1 ;}

									if(NOPRE == NOPRE_LOW)
									{ pwdata_i[2] == 0 ;}
									if(NOPRE == NOPRE_HIGH)
									{ pwdata_i[2] == 1 ;}

									soft pwdata_i[0] == 1 ;			//---------RXE = 1 

								  }

							} 

	constraint reg_config {
							if (reg_ptr == MAC_ADDR1) {
									
									soft pwdata_i[15:0] == 'habcd;		//------------given address

								}
							else if (reg_ptr == MAC_ADDR0) {
									soft pwdata_i[31:0] == 'h0 ;		//------------given address
									
								}
							else if (reg_ptr == MII_ADDR) {
								soft pwdata_i == 'hC ;				//------------given address
								}

							else if (reg_ptr == INT_MASK) {
								soft pwdata_i[3:0] == 'b1100 ;		//----------default RXE_M,RXE_F = 1

								(rx_mask == ONLY_RXE_M_01) -> pwdata_i[3:0] 	== 'b0100 ;
								(rx_mask == ONLY_RXF_M_10) -> pwdata_i[3:0] 	== 'b1000 ;
								(rx_mask == BOTH_RX_00) 	->pwdata_i[3:0] 	== 'b0000 ;
								(rx_mask == BOTH_RX_11) 	->pwdata_i[3:0] 	== 'b1100 ;

								}
								
							else if (reg_ptr == INT_SOURCE) {
								
								soft pwdata_i[3:0] 	== 'b1100 ;
								}
								
									}

							
	constraint RxD_config {if (reg_ptr == RX_BD)
								{
									
									pwdata_i[13:0] 	== 0 ;

									if(IRQ == IRQ_0) 
										{pwdata_i[14] == 0 ;}
									else 
										{pwdata_i[14] == 1 ;}

									if(EMPTY == EMPTY_0) 
										{pwdata_i[15] == 0 ;}
									else 
										{pwdata_i[15] == 1 ;}


								  }
							}  

	constraint Aligned_rxbd_ptr { if(reg_ptr == RX_BD_PTR) {
										soft pwdata_i % 4 == 0 ;

									(RXBD_PTR_DATA == UNALIGNED) ->  pwdata_i % 4 != 0 ;
									(RXBD_PTR_DATA == ALIGNED) ->  pwdata_i % 4 == 0 ;

									}
									
								}


	constraint FL_range {	if(reg_ptr == RX_BD && paddr_i % 8 == 0)	{

							(FL == LT_4BYTES) -> pwdata_i[31:16] < 32;		//-----------SPEC VIOLATION CASE
							(FL == LT_MINFL) -> pwdata_i[31:16] < 46;
							(FL == MINFL) -> pwdata_i[31:16] == 46;
							(FL == NORMAL) -> pwdata_i[31:16] inside {[46:1500]};
							(FL == GT_MAXFL_LT_2KB) -> pwdata_i[31:16] inside {[1500:2047]};
							(FL == GT_2KB) -> pwdata_i[31:16] > 2047;
							}
									}


endclass


class ethernet_seq_item extends uvm_sequence_item;

	//=======FACTOR REGISTRATION
	`uvm_object_utils(ethernet_seq_item)

	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "ethernet_seq_item");
		super.new(rgstr_name);
	endfunction

	//=====>>HOST APB<<=====
	rand bit prstn_i; 
	rand bit psel_i;
	rand bit penable_i;
	rand bit pwrite_i;
	rand bit [31:0] paddr_i;
	rand bit [31:0] pwdata_i;
	int prdata_o;
	bit pready_o;

	//=====>>INTERRUPT<<=====
	bit int_o;
	
	//=====>>MEMORY APB<<=====
	rand bit m_pready_i;
	rand int m_prdata_i; 
	bit m_psel_o;
	bit m_pwrite_o;
	bit m_penable_o;
	int m_paddr_o;
	int m_pwdata_o;

	//=====>>TX MAC<<=====
	bit[3:0] MTxD;
	bit MTxEn;
	bit MTxErr;
	
	//=====>>RX MAC<<=====
	rand bit MRxDV;
	rand bit[3:0] MRxD;
	rand bit MRxErr;
	rand bit MCrS;

	//=========>>TYPEDEF DECLARATIONS<<========
	typedef enum {MODER,INT_SOURCE,INT_MASK,TX_BD_NUM,MII_ADDR,MAC_ADDR0,MAC_ADDR1,RX_BD,RX_BD_PTR} reg_type;
	typedef enum {IDLE,SETUP} phase_e;
	typedef enum {WRITE,READ} rw_mode;
	typedef enum {PAD_1,PAD_0} pad_e;
	typedef enum {HUGEN_1,HUGEN_0} hugen_e;
	typedef enum {PRO_0,PRO_1} pro_e;
	typedef enum {BRO_0,BRO_1} bro_e;
	typedef enum {NOPRE_HIGH,NOPRE_LOW} nopre_e;
	typedef enum {RXEN_0,RXEN_1} Rxen_e;
	typedef enum {LT_MINFL,MINFL,LT_MAXFL,GT_MAXFL_LT_2KB,GT_2KB} fl_e;
	typedef enum {EMPTY_0,EMPTY_1} empty_e;

	//==========>>RAND DECLARATIONS FOR ENUMS<<=========
	rand reg_type	reg_ptr;
	rand phase_e	apb_phase;
	rand rw_mode	rw;
	rand pad_e		PAD;
	rand hugen_e	HUGEN;
	rand pro_e		PRO;
	rand bro_e		BRO;
	rand nopre_e	NOPRE;
	rand Rxen_e		RXEN;
	rand fl_e		FL;
	rand empty_e	EMPTY;

	//===========>>TEMP REGISTERS<<================
	rand bit [31:0] TX_BD_NUM_value;

	//======>>CONSTRAINTS<<============
	constraint default_val { 	soft prstn_i == 1'b1;
								soft pwdata_i == 1'b1;}

/*	constraint phases {	
	                     if(apb_phase == IDLE){
						         psel_i==0;
								// prstn_i ==0;
								 } 
					    
                         if(apb_phase ==SETUP){
						        psel_i==1;
							//	prstn_i==1;
								penable_i==0;}
                           }

	constraint reg_rw_mode {
                       		if(rw==WRITE){
					       		soft pwrite_i == 1;}
					   		else{
					       		soft pwrite_i == 0;}  }

	constraint paddr_range {
                           if(reg_ptr == MODER) {soft paddr_i == 'h00 ;}
                           if(reg_ptr == INT_SOURCE) {soft paddr_i == 'h04 ;}
                           if(reg_ptr == INT_MASK) {soft paddr_i == 'h08 ;}
                           if(reg_ptr == TX_BD_NUM) {soft paddr_i == 'h20 ; }
                           if(reg_ptr == MII_ADDR) {soft paddr_i == 'h30 ;}
                           if(reg_ptr == MAC_ADDR0) {soft paddr_i == 'h40 ;}
                           if(reg_ptr == MAC_ADDR1) {soft paddr_i == 'h44 ;}
                           if(reg_ptr == RX_BD) {soft paddr_i inside {['h400:'h7FF]} ;}
						}

	constraint tx_bd_num_range {if(reg_ptr == TX_BD_NUM)
									{
									pwdata_i inside {[10:128]};
									TX_BD_NUM_value == pwdata_i ;	//-----for RXBDs
									}

								}

	constraint reg_reserved_bits {
									if(reg_ptr == MODER)
										{ 
										  pwdata_i[31:16] == 0 ;
										  pwdata_i[13:8] == 0 ;
										  pwdata_i[7] 	== 0 ;
										  pwdata_i[6] 	== 0 ;
										  pwdata_i[4]	== 0 ;
										  pwdata_i[1]	== 0 ;
										  
										  }

									if(reg_ptr == MII_ADDR) 
										{ pwdata_i[31:5] == 0;}

									if(reg_ptr == MAC_ADDR1)
										{ pwdata_i[31:16] == 0;}

									if(reg_ptr == INT_SOURCE) 
										{ pwdata_i[31:4] == 0;
										  pwdata_i[1:0] == 0 ;}

									if(reg_ptr == INT_MASK) 
										{ pwdata_i[31:4] == 0;
										  pwdata_i[1:0] == 0 ;}

								}

	constraint Moder_bit_config { 
								  if(reg_ptr == MODER) {
									if(PAD == PAD_1)
									{ pwdata_i[15] == 1 ;}
									if(PAD == PAD_0)
									{ pwdata_i[15] == 0 ;}
									
									if(HUGEN == HUGEN_0)
									{ pwdata_i[14] == 0 ;}
									if(HUGEN == HUGEN_1)
									{ pwdata_i[14] == 1 ;}

									if(RXEN == RXEN_1)
									{ pwdata_i[0] == 1 ;}
									if(RXEN == RXEN_0)
									{ pwdata_i[0] == 0 ;}

									if(PRO == PRO_0)
									{ pwdata_i[5] == 0 ;}
									else
									{ pwdata_i[5] == 1 ;} 

									if(BRO == BRO_0)
									{ pwdata_i[3] == 0 ;}
									else
									{ pwdata_i[3] == 1 ;}

									if(NOPRE == NOPRE_LOW)
									{ pwdata_i[2] == 0 ;}
									if(NOPRE == NOPRE_HIGH)
									{ pwdata_i[2] == 1 ;}

								  }

							} 

	constraint reg_config {
							if (reg_ptr == MAC_ADDR1) {
									
									soft pwdata_i[15:0] == 'hb3d5 ;

								}
							else if (reg_ptr == MAC_ADDR0) {
									soft pwdata_i[31:0] == 'h0 ;
									
								}
							else if (reg_ptr == MII_ADDR) {
								soft pwdata_i == 'h3 ;
								}

							else if (reg_ptr == INT_MASK) {
								
								soft pwdata_i[3:0] 	== 'b1100 ;
								}
								
							else if (reg_ptr == INT_SOURCE) {
								
								soft pwdata_i[3:0] 	== 'b1100 ;
								}
								
									}

	constraint FL_range {	if(reg_ptr == RX_BD && paddr_i % 8 == 0)	{
							(FL == LT_MINFL) -> pwdata_i[31:16] < 46;
							(FL == MINFL) -> pwdata_i[31:16] == 46;
							(FL == LT_MAXFL) -> {pwdata_i[31:16] < 1500; pwdata_i[31:16] > 46;}
							(FL == GT_MAXFL_LT_2KB) -> pwdata_i[31:16] inside {[1500:2047]};
							(FL == GT_2KB) -> pwdata_i[31:16] > 2047;
							}
									}


							
	constraint RxD_config {if (reg_ptr == RX_BD)
								{
									
									pwdata_i[14] 	== 1;		//------IRQ must be 1
									pwdata_i[13:0] 	== 0 ;

									if(EMPTY == EMPTY_0) 
										{pwdata_i[15] == 0 ;}
									else 
										{pwdata_i[15] == 1 ;}
								  }
							}  


endclass*/