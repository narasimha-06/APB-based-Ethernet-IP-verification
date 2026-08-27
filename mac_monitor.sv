// =====================================================================
// MAC RX MONITOR
// This monitor observes RX interface signals (MRxD, MRxDV,MRxErr,MCrs)
// It reconstructs the incoming Ethernet frame and performs
// the checks (preamble, SFD, DA/SA, length, payload, CRC, IRQ)
// =====================================================================
class mac_monitor extends uvm_monitor;


	//================ FACTORY REGISTRATION =============
	`uvm_component_utils(mac_monitor)
	
	// ================ TLM PUT PORT ===================
	uvm_blocking_put_port #(bit[31:0]) mac_put_port;
	
	//================ CONSTRUCTOR ============================
	function new(string name = "mac_monitor", uvm_component parent);
		super.new(name,parent);
	endfunction
	
	//================ INSTANCES ==============================
	ethernet_seq_item			h_ethernet_seq_item;
	config_class				h_config;

	virtual ethernet_interface  vif;
	//================ VARIABLES ==============================
	
  	bit frame_drop;                  // Indicates frame should be dropped
  	int address_count;               // Counts DA/SA nibbles
  	bit [31:0] register;             // Temporary shift register (collect 4 bits per clock)
  	int frame_length;                // Calculated frame length
  	int pad_count;                   // Padding byte count
  	bit len_bad;                     // Length error flag
  	bit fcs_error;                     // CRC error flag
  	bit da_bad;                      // Destination address error flag
  	bit payload_flag;                // Payload collection done flag
  	int payload_count;               // Counts payload nibbles
  	int crc_count;                   // Counts CRC nibbles
  	int pad_rxd_count;               // Counts padding nibbles
  	int clk_count;                   // clock count
  	int field_count ;                // based on the field_count we will know what field, we will check
  	int MAXFL = 'd1518;
  	int MINFL = 'd64;
  	bit [3:0] nibble_crc[$];         //CRC bit checking
  	int address;                     // this is used to get the next bd in the task get_rxbd
  	bit bd_reg;                      // just like flag whether to take next bd or not
  	bit payload_bad;                 //
  	int bad_frame;                   // counter for bad frames
  	int good_frame;                  // counter for good frames    
  	int length_count;

	//================ BUILD PHASE ============================
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		//==========TLM PORT MEMORY CREATION
		 mac_put_port	= new("mac_put_port",this);
		
		//==========GET VIF
		if(!uvm_config_db #(virtual ethernet_interface)::get(this,"","vif",vif))
		  `uvm_fatal("NO VIF","VIRTUAL INTERFACE NOT FOUND !!");
		
		//==========GET CONFIG CLASS
		if(!uvm_config_db#(config_class)::get(this,"","config",h_config))
		  `uvm_fatal("NO CONFIG","CONFIG CLASS NOT FOUND !!");		
	  	  h_ethernet_seq_item	= ethernet_seq_item::type_id::create("h_ethernet_seq_item");

	endfunction
	
	//=================== RUN PHASE ===========================
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever @(vif.cb_mac_monitor) begin			
			h_ethernet_seq_item.MCrS     	= vif.cb_mac_monitor.MCrS;
			h_ethernet_seq_item.MRxDV	= vif.cb_mac_monitor.MRxDV;
			h_ethernet_seq_item.MRxD	= vif.cb_mac_monitor.MRxD;
			h_ethernet_seq_item.MRxErr	= vif.cb_mac_monitor.MRxErr;
			h_ethernet_seq_item.prstn_i 	= vif.cb_mac_monitor.prstn_i;

			self_check();
		end

	endtask
	
	//================== get present and next bd======================================
          task get_rxbd();

               if(!bd_reg) begin 
                    if(h_config.rxbd.next(address))begin
		                h_config.present_bd = {h_config.rxbd[address + 4],h_config.rxbd[address]};
		             	h_config.rxbd.next(address);
			        bd_reg = 1;
		    end
               end

          endtask

	//================self check==============================================================
 	task self_check();	

  		if(!h_ethernet_seq_item.prstn_i)begin
	    		reset_variables();
		end
    		else begin // prstn_i==0 || MCrS || tx_bd_num[7:0] == 128

    			if(h_config.moder[0] && h_ethernet_seq_item.MCrS && h_config.tx_bd_num[7:0]!= 128)begin        //RXEN IS MODER_REG[0]
	    			get_rxbd();
        			if(h_config.present_bd[15] == 1)begin                                                              //----rxbd 15 = empty
	         	 		if(h_ethernet_seq_item.MRxDV) begin
                    				if(!h_ethernet_seq_item.MRxErr)begin
		    	       				field();
                    				end
                    				else begin 
                       					h_config.int_source[3] = 1;
                       					da_bad = 1;
			           			field();
                    				end
	         	 		end
                 			else begin //MRxDV IS LOW
						reset_variables();
             	 			end
          	 		end
       	 	 		else begin //Empty
            				while (h_config.present_bd[15] == 0)begin
                   				bd_reg = 0;
                   				get_rxbd();                
             				end
        	 		end
    	 		end
     		end
 
	endtask                       
	//====================================================================================================================
	// ---------------------task field 
	//====================================================================================================================
 	task field();

   		if(h_config.moder[2] == 1'B0)begin
      			if(field_count < 16)begin
	     			preamble_and_sfd_check();
         			field_count = field_count+'d1;
      			end
      			else if(field_count < 40  && field_count >= 16)begin
        			destination_source();	
	    			field_count = field_count+'d1;
      			end
      			else if(field_count < 44  && field_count >= 40)begin
       	 			length_field_check();
         			field_count = field_count+'d1;
      			end
      			else if(field_count >= 44 && !payload_flag)begin
         			payload_check();
       	 			field_count = field_count+'d1;
      			end
 	  		else if(field_count >= 44 && payload_flag) begin
       	 			crc();			
	  		end
			
   		end
   		else begin
		
      			if(field_count < 2)begin
	    			no_preamble_sfd_check();
	    			field_count = field_count+'d1;
     			end
     			else if(field_count < 26  && field_count >= 2)begin
        			destination_source();	
        			field_count = field_count+'d1;
     			end
     			else if(field_count < 30  && field_count >= 26)begin
        			length_field_check();
        			field_count = field_count+'d1;
     			end
      			else if(field_count >= 30 && !payload_flag)begin
         			payload_check();
       	 			field_count = field_count+'d1;
      			end
 	  		else if(field_count >= 30 && payload_flag) begin
       	 			crc();			
	  		end	
		end
	endtask

	//====================reset================================= 

	task reset_variables();
   
		frame_drop 	= 0;            
               	address_count 	= 0;               
               	register 	= 0;          
               	frame_length 	= 0;             
               	pad_count 	= 0;                   
               	len_bad 	= 0;                    
               	fcs_error 	= 0;                  
               	da_bad 		= 0;                    
               	payload_flag 	= 0;              
               	payload_count 	= 0;              
               	crc_count 	= 0;                
               	pad_rxd_count 	= 0;            
               	clk_count 	= 0;               
               	field_count 	= 0;           
               	nibble_crc.delete();   // Clears entire CRC queue
               	bd_reg 		= 0;
               	payload_bad 	= 0;
               	fcs_error 	= 0;
               	length_count 	= 0;
             
	endtask

	// ==========================================================
	// PREAMBLE + SFD CHECK
	// ==========================================================
	// Checks for 7 bytes of 0x55 (1010 nibbles)
	// Followed by SFD (1011)
	// ==========================================================
	task preamble_and_sfd_check();                                             

  		if(frame_drop == 1'b1)begin							    //checking for frame_drop value (initial value is 0)
			//wait(!h_ethernet_seq_item.MRxDV);
  		end
  		else begin
     			if(field_count < 'd15)begin					        // pre_count is initially zero( preamble is 7 bytes so it needs to count from 0 to 13 only preamble (1010) but i took  
	   			preamble_check();                                   // <15 because sfd first 4 bits are 1010) it is checked here in the preamble task
  	 		end
	 		else if(field_count == 'd15)begin                      // 1011 of sfd checked here
				SFD_check();
	 		end
  		end
                               
	endtask


	task no_preamble_sfd_check();

  		if(frame_drop == 1'b1)begin							    //checking for frame_drop value (initial value is 0)
			//wait(!h_ethernet_seq_item.MRxDV);
  		end
  		else begin                                                // NOPRE = 1
  	 		if(field_count < 'd1)begin								// 1010 OF SFD CHECKED HERE
	 	 		preamble_check();
	 		end  	
	 		else if(field_count == 'd1)begin 					    //1011 OF SFD CHECKED HERE
				SFD_check();
	 		end
  		end    

	endtask
	
	//=======preamble check===========task========
 	task preamble_check();

     		if(h_ethernet_seq_item.MRxD==4'b0101)begin             // MRxD is compared with 4'b1010 for the preamble and first 4bits of sfb
        		frame_drop = 0; 
     		end
     		else begin
        		frame_drop = 'b1;
     		end
	  
 	endtask
	
	//=========SFD check task=======================
	task SFD_check();

     		if(h_ethernet_seq_item.MRxD==4'b1101)begin             // MRxD is compared with 4'b1010 for the preamble and first 4bits of sfb    
        		frame_drop = 0;
     		end
     		else begin
        		frame_drop = 1;
     		end

	endtask


  	// =========================================================
  	// -----DESTINATION + SOURCE ADDRESS COLLECTION-------------
  	// =========================================================
  	//--- Collects 6 bytes DA + 6 bytes SA (24 nibbles)clocks------
  	// =========================================================

 	task register_shift__inc_address_count();                                               //----task for sfift register and incrementing address_count

     		register = {register[27:0],h_ethernet_seq_item.MRxD};  
     		nibble_crc.push_back(h_ethernet_seq_item.MRxD);                                     //push_back 4 bits MRxD into nibble_crc queue for CRC calculation 
     		address_count = address_count + 1;

 	endtask


	/*task destination_source();

  		if(h_config.moder[5] == 1'b0)begin                                                      // PRO=0(MODER[5]) (CHECK DA AND BA)
      			if(h_config.moder[3] == 1'b0)begin                                                   // BRO=0(MODER[3])

          			if(address_count == 'd8)begin  						  
	           			if(da_eq_mac_check_4bytes() || da_eq_broadcast_check_4bytes())begin         // checking 4 BYTES in the register with BYTE 0,1,2,3 of    
                  				register_shift__inc_address_count(); 
               				end
               				else begin
                  				frame_drop = 1; 
                  				register_shift__inc_address_count(); 
                  				h_config.rxbd[address][7] = 1'b1;                                       // miss bit updation
               				end
           			end 
		   		else if(address_count == 'd16)begin 
               				if(da_eq_mac_check_2bytes() || da_eq_broadcast_check_2bytes())begin                        // CHECKING NEXT 2 BYTES OF DESTINATION ADDRESS
                 				register_shift__inc_address_count(); 
               				end
               				else begin
                  				da_bad = 1;
                  				register_shift__inc_address_count(); 
				  		h_config.rxbd[address][7] = 1'b1;                                       // miss bit updation
               				end
           			end
           			else begin
             				da_sa(); 
           			end 

       			end
       			else begin                                                                            // PRO=0(MODER[5]) BRO=1(MODER[3])( BRO=1 reject all broadvcast adress----)
         			
				if(address_count == 8)begin  						    	
	         			if(da_eq_mac_check_4bytes())begin                                                // checking 4 BYTES in the register with BYTE 0,1,2,3 of 
                				register_shift__inc_address_count();
             				end
             				else begin
                				frame_drop = 1; 
                				h_config.rxbd[address][7] = 1'b1;                                       // miss bit updation 
		     			end 
         			end
		 		else if(address_count == 'd16)begin 
             				if(da_eq_mac_check_2bytes())begin                                               // CHECKING NEXT 2 BYTES OF DESTINATION ADDRESS
               					register_shift__inc_address_count(); 
             				end
             				else begin
               					da_bad = 1;
               					register_shift__inc_address_count();
               					h_config.rxbd[address][7] = 1'b1;                                       // miss bit updation  
             				end
	     			end  
				else begin
             				da_sa(); 
           			end      
 			end
		end
 		else begin                                                                                  //pro 1  (irrespective of bro 0  bro 1)  accept all frames
    			da_sa();
 		end

	endtask*/
	
	task destination_source();
		
		register_shift__inc_address_count();

  		if(h_config.moder[5] == 1'b0)begin                                                      // PRO=0(MODER[5]) (CHECK DA AND BA)
      			if(h_config.moder[3] == 1'b0)begin                                                   // BRO=0(MODER[3])
				
          			if(address_count == 'd8)begin  						  
	           			if(da_eq_mac_check_4bytes() || da_eq_broadcast_check_4bytes())begin         // checking 4 BYTES in the register with BYTE 0,1,2,3 of    
               				end
               				else begin
                  				frame_drop = 1; 
                  				h_config.rxbd[address][7] = 1'b1;                                       // miss bit updation
               				end
           			end 
		   		else if(address_count == 'd16)begin 
               				if(da_eq_mac_check_2bytes() || da_eq_broadcast_check_2bytes())begin                        // CHECKING NEXT 2 BYTES OF DESTINATION ADDRESS
               				end
               				else begin
                  				da_bad = 1;
				  		h_config.rxbd[address][7] = 1'b1;                                       // miss bit updation
               				end
           			end

       			end
       			else begin                                                                            // PRO=0(MODER[5]) BRO=1(MODER[3])( BRO=1 reject all broadvcast adress----)
         			
				if(address_count == 8)begin  						    	
	         			if(da_eq_mac_check_4bytes())begin                                                // checking 4 BYTES in the register with BYTE 0,1,2,3 of 
             				end
             				else begin
                				frame_drop = 1; 
                				h_config.rxbd[address][7] = 1'b1;                                       // miss bit updation 
		     			end 
         			end
		 		else if(address_count == 'd16)begin 
             				if(da_eq_mac_check_2bytes())begin                                               // CHECKING NEXT 2 BYTES OF DESTINATION ADDRESS
             				end
             				else begin
               					da_bad = 1;
               					h_config.rxbd[address][7] = 1'b1;                                       // miss bit updation  
             				end
	     			end  
 			end
		end

	endtask


 	// ------------- TO LOAD REGISTER-----------------------------------------------------------
  	task da_sa();

      		if(address_count <= 'd7)begin					
       	    		register_shift__inc_address_count(); 						                         // nibble(MRxD) at every  is stored into the 32-bit register
      		end
	  	else if(address_count >= 'd9 && address_count <= 'd15)begin			                     // GETTING 2 BYTES OF DESTINATION ADDRESS AND 2 BYTES OF SOURCE ADDRESS INTO THE REGISTER
            		register_shift__inc_address_count(); 
      		end
      		else if (address_count >= 'd17 && address_count < 'd28)begin
            		register_shift__inc_address_count();                                                 // to fill 4 bytes we requred 8 clocks 16 to 23
      		end
     
  	endtask

	// -------------FIRST 4 BYTES OF DESTINATION CHECK---------------------------------
    	function bit da_eq_mac_check_4bytes();
		
		if(register[31:16] == h_config.mac_addrs1[15:0] && register[15:0] == h_config.mac_addrs0[31:16]) begin
		   return 1;
		end
		return 0;

	endfunction
	
	function bit da_eq_broadcast_check_4bytes();

		if(register[31:0] == 32'hffff_ffff) begin
			return 1;
		end		
		return 0;

	endfunction
//-----------------------------------------------------------------------------

// -------------LAST 2 BYTES OF DESTINATION CHECK---------------------------------
	
    function bit da_eq_mac_check_2bytes();
		
		if(register[31:16] == h_config.mac_addrs0[15:0]) begin
			return 1;
		end
		return 0;

	endfunction
	
	function bit da_eq_broadcast_check_2bytes();

		if(register[31:16] == 16'hffff) begin
			return 1;
		end		
		return 0;

	endfunction
//---------------------------------------------------------------------------------

//----------------------------------------------------------
//=============== LENGTH CHECK=============================
//----------------------------------------------------------

	task length_field_check();

     		register_shift__inc_address_count();
   		if(address_count =='d28)begin
	     		if( register[15:0] < 'd46)begin                                                 //register [15:0] or rxbd [31:16]  both defines length.  if it is < 46 
        	      		if(h_config.moder[15]==1)begin                                             //  check for pad bit, if it is 1
                  			len_bad = 1'b0;
                  			pad_count = 'd64 - (register[15:0]+'d18);                              // pad_count(how many bytes padded) = frame_length-register[15:0]-(da+sa+len+crc)
              			end
              			else begin    
                  			len_bad = 1'b1;                                                        // h_config.moder[15] bit is 0(no padding)
              			end                
         		end
         		else if(register[15:0] > MINFL-'d18 && register[15:0] < MAXFL-'d18)begin        //minfl(64) < fl > maxfl(1518) (no problem)   len_bad=0
               			len_bad = 1'b0;
         		end
	     		else if(register[15:0] > MAXFL-'d18 && register[15:0] < 'd2048-'d18) begin      //2kb > fl > maxfl(1518) check for huge enable bit
              			if (!h_config.moder[14])begin                                              // huge enable bit check, if it 0, it wont accept frame length greater than 1518
                  			len_bad = 1'b1;
              			end
              			else begin                                                                 // huge enable bit check, if it 1, it will accept frame length greater than 1518 and < 2kb
                  			len_bad = 1'b0;
              			end
         		end
         		else if(register[15:0] >'d2048)begin                              
             			len_bad = 1'b1;
         		end
    		end
                                         
	endtask
	// =========================================================================================================================
	// -----------------------------------------------------------------PAYLOAD COLLECTION--------------------------------------
	// ============================================================================================================================
	task payload_check();

      		if(h_config.present_bd[31:16] <'d46)begin                                                                 //=======length less than 46==========
         		if(h_config.moder[15]==1)begin                                                                        //pad bit = 1, SO PAYLOAD + PADDING = 46			   
             			payload_count_ls_RXBD();                                                                          // RECEIVING PAYLOAD 
             			payload_count_eq_rxbd();                                                                          // RECEIVING PADDING
             			if(payload_count == 2*h_config.present_bd[31:16] && pad_rxd_count == 2*pad_count)begin
		        		while(pad_rxd_count <= (2*pad_count) + 'd4)begin                                               // ADDING ZEROS, adding 2 bytes of zeros  
            	   				if(clk_count == 'd8)begin
                       					mac_put_port.put(register);                                                             // update to scoreboard after reaching 8 clock cycles   
                   				end
                   				else begin
                      					register = {register [27:0],4'd0};                                                       //adding zeros until it match with 8 cycles count (clk_count)
                      					clk_count++;
                   				end
        	        			pad_rxd_count++;
                			end
		 	      		payload_flag='b1; 
              			end
		  	end
          		else begin
             			payload_bad=1;
			 	payload_plus_zeros();
          		end
       		end
       		else if(h_config.present_bd[31:16]>='d46)begin
          		payload_plus_zeros();
       		end		
   
	endtask
	
	//-----------------------------------------------------------------------------------------------
	//=================task from payload count less than rxbd============
	//--------------------------------------------------------------------------------------------------------
	task payload_count_ls_RXBD();
	
     		if(payload_count < (2*h_config.present_bd[31:16]))begin             //checking payload_count less than 2 x rxbd[31:16] bytes (converting  bytes count to nibbles count)          
			
			register = {register [27:0],h_ethernet_seq_item.MRxD};      //increment clk_count until the registeris filled with next 32 bit of payload(takes clk_count to 8)
                	nibble_crc.push_back(h_ethernet_seq_item.MRxD);             //push_back 4 bits MRxD into nibble_crc queue for CRC calculation
            		payload_count = payload_count +1;                                // increment payload count after every posedge 

		end
 		if(payload_count % 8 == 0 && payload_count > 0) begin
                	mac_put_port.put(register);		
		end
	
	endtask

	//-----------------------------------------------------------------------------------------------
	// ==========payload equal to rxbd[31:16]==========================================
	//-----------------------------------------------------------------------------------------------

	task  payload_count_eq_rxbd();

    		if(payload_count == 2*h_config.present_bd[31:16])begin		          //before this task we did payload_count_ls_rxbd, there we will get payload_count equal to 2xRXBD[31:16](nibbles)
        		if(pad_rxd_count < 2*pad_count)begin                                      //pad_rxd_count is initially 0, pad_count is no.of bytes we added to get MINFL, so pad_countx2 gives in nibbles
               			
				register = {register [27:0],h_ethernet_seq_item.MRxD};             //storing next padding bits into  register
               			nibble_crc.push_back(h_ethernet_seq_item.MRxD);                    //push_back 4 bits MRxD into nibble_crc queue for CRC calculation
        			pad_rxd_count++;

        		end
    		end
 		if(pad_rxd_count % 8 == 0 && pad_rxd_count>0) begin
                	mac_put_port.put(register);		
		end

	endtask	

	//-----------------------------------------------------------------------------------------------
	//==================payload adding zeros====================
	//-----------------------------------------------------------------------------------------------
	task payload_plus_zeros();                                                       // this task is to add zeros,?----- because payload or padding may or may not exact divisible by 4.
		
		if(h_config.present_bd[31:16]%4 == 'd1) begin                                // if we get remainder 1, we need to add 3 bytes of zeros, so + 6 is added to 2*h_config.present_bd[31:16]
       			payload_count_ls_RXBD();                                                  // first getting total payload, then zeros were added
       			if(payload_count == 2*h_config.present_bd[31:16])begin
	      			while(payload_count != 2*(h_config.present_bd[31:16] + 3))begin
              				register = {register [27:0],4'd0};                                // filling register with zeros
              				payload_count++;
           			end
           			mac_put_port.put(register);
           			payload_flag = 'b1;
       			end
		end
    		else if(h_config.present_bd[31:16] % 4 == 'd2) begin                          // if we get remainder 2, we need to add 2 bytes of zeros, so + 4 is added to 2*h_config.present_bd[31:16]
       			payload_count_ls_RXBD();                                                   // first getting total payload, then zeros were added
	   		if(payload_count == 2*h_config.present_bd[31:16])begin
	  	   		while(payload_count != 2*(h_config.present_bd[31:16] + 2))begin
              				register = {register [27:0],4'd0};                                // filling register with zeros
              				payload_count++;
           			end
           			mac_put_port.put(register);
           			payload_flag = 'b1;
	        	end
     		end
     		else if(h_config.present_bd[31:16]%4 == 'd3) begin                           // if we get remainder 3, we need to add 1 bytes of zeros, so + 2 is added to 2*h_config.present_bd[31:16]
        		payload_count_ls_RXBD();                                                  // first getting total payload, then zeros were added
	    		if(payload_count == 2*h_config.present_bd[31:16])begin
	  	   		while(payload_count != 2*(h_config.present_bd[31:16] + 1))begin
              				register = {register [27:0],4'd0};                                // filling register with zeros
              				payload_count++;
           			end
           			mac_put_port.put(register);
           			payload_flag = 'b1;
        		end
     		end
     		else if(h_config.present_bd[31:16]%4 == 0) begin                             // if we get remainder 0, so no need to add zeros
	    		payload_count_ls_RXBD(); 
        		if(payload_count == 2*h_config.present_bd[31:16])begin
          			payload_flag = 'b1; 
        		end
     		end

	endtask


//-----------------------------------------------------------------------------------------------
// ================ FRAME STATUS ===============================
//----------------------------------------------------------------------------------------------
  task frame_status();

    if(fcs_error|| len_bad || da_bad || payload_bad) begin
       h_config.int_source[2] = 1;
       h_config.int_source[3] = 1;
       bad_frame = bad_frame + 1;
    end
    else begin
       h_config.int_source[2] = 1;
       h_config.int_source[3] = 0;
       good_frame = good_frame + 1;
    end

  endtask

/*
  task frame_status();
    if(h_config.present_bd[14])
       if(fcs_error || len_bad || da_bad || payload_bad) begin
         h_config.int_source[2] = 1;
         h_config.int_source[3] = 1;
         bad_frame = bad_frame + 1;
       end
       else begin
          h_config.int_source[2] = 1;
          h_config.int_source[3] = 0;
          good_frame = good_frame + 1;
       end
    end
    else begin
      if(fcs_error || len_bad || da_bad || payload_bad) begin        
         bad_frame = bad_frame + 1;
       end
       else begin
          good_frame = good_frame + 1;
       end
    end

  endtask*/


//==========================CRC CHECK +=========================================
task crc_check();
		bit [3:0] data;
		bit [31:0] crc_variable = 32'hffff_ffff; // initializing the variable
		bit [31:0] crc_next; 
		bit [31:0] calculated_magic_number;
		int nibble_size;
		
		nibble_size = nibble_crc.size();
			$display("[MAC MONITOR] CRC QUEUE=%p",nibble_crc);
			for(int i=0;i<nibble_size;i++) 
			begin
			data = nibble_crc.pop_front();
			data = {<<{data}}; 

			crc_next[0] =    (data[0] ^ crc_variable[28]); 
			crc_next[1] =    (data[1] ^ data[0] ^ crc_variable[28] ^ crc_variable[29]); 
			crc_next[2] =    (data[2] ^ data[1] ^ data[0] ^ crc_variable[28] ^ crc_variable[29] ^ crc_variable[30]); 
			crc_next[3] =    (data[3] ^ data[2] ^ data[1] ^ crc_variable[29] ^ crc_variable[30] ^ crc_variable[31]); 
			crc_next[4] =    (data[3] ^ data[2] ^ data[0] ^ crc_variable[28] ^ crc_variable[30] ^ crc_variable[31]) ^ crc_variable[0]; 
			crc_next[5] =    (data[3] ^ data[1] ^ data[0] ^ crc_variable[28] ^ crc_variable[29] ^ crc_variable[31]) ^ crc_variable[1]; 
			crc_next[6] =    (data[2] ^ data[1] ^ crc_variable[29] ^ crc_variable[30]) ^ crc_variable[2]; 
			crc_next[7] =    (data[3] ^ data[2] ^ data[0] ^ crc_variable[28] ^ crc_variable[30] ^ crc_variable[31]) ^ crc_variable[3]; 
			crc_next[8] =    (data[3] ^ data[1] ^ data[0] ^ crc_variable[28] ^ crc_variable[29] ^ crc_variable[31]) ^ crc_variable[4]; 
			crc_next[9] =    (data[2] ^ data[1] ^ crc_variable[29] ^ crc_variable[30]) ^ crc_variable[5]; 
			crc_next[10] =    (data[3] ^ data[2] ^ data[0] ^ crc_variable[28] ^ crc_variable[30] ^ crc_variable[31]) ^ crc_variable[6]; 
			crc_next[11] =    (data[3] ^ data[1] ^ data[0] ^ crc_variable[28] ^ crc_variable[29] ^ crc_variable[31]) ^ crc_variable[7]; 
			crc_next[12] =    (data[2] ^ data[1] ^ data[0] ^ crc_variable[28] ^ crc_variable[29] ^ crc_variable[30]) ^ crc_variable[8]; 
			crc_next[13] =    (data[3] ^ data[2] ^ data[1] ^ crc_variable[29] ^ crc_variable[30] ^ crc_variable[31]) ^ crc_variable[9]; 
			crc_next[14] =    (data[3] ^ data[2] ^ crc_variable[30] ^ crc_variable[31]) ^ crc_variable[10]; 
			crc_next[15] =    (data[3] ^ crc_variable[31]) ^ crc_variable[11]; 
			crc_next[16] =    (data[0] ^ crc_variable[28]) ^ crc_variable[12]; 
			crc_next[17] =    (data[1] ^ crc_variable[29]) ^ crc_variable[13]; 
			crc_next[18] =    (data[2] ^ crc_variable[30]) ^ crc_variable[14]; 
			crc_next[19] =    (data[3] ^ crc_variable[31]) ^ crc_variable[15]; 
			crc_next[20] = 	  crc_variable[16]; 
			crc_next[21] =    crc_variable[17]; 
			crc_next[22] =    (data[0] ^ crc_variable[28]) ^ crc_variable[18]; 
			crc_next[23] =    (data[1] ^ data[0] ^ crc_variable[29] ^ crc_variable[28]) ^ crc_variable[19]; 
			crc_next[24] =    (data[2] ^ data[1] ^ crc_variable[30] ^ crc_variable[29]) ^ crc_variable[20]; 
			crc_next[25] =    (data[3] ^ data[2] ^ crc_variable[31] ^ crc_variable[30]) ^ crc_variable[21]; 
			crc_next[26] =    (data[3] ^ data[0] ^ crc_variable[31] ^ crc_variable[28]) ^ crc_variable[22]; 
			crc_next[27] =    (data[1] ^ crc_variable[29]) ^ crc_variable[23]; 
			crc_next[28] =    (data[2] ^ crc_variable[30]) ^ crc_variable[24]; 
			crc_next[29] =    (data[3] ^ crc_variable[31]) ^ crc_variable[25]; 
			crc_next[30] =    crc_variable[26]; 
			crc_next[31] =    crc_variable[27]; 

			crc_variable = crc_next;

			end
		
		calculated_magic_number = crc_variable;
				$display($time,"calculated_magic_number=%h",calculated_magic_number);	
		if(calculated_magic_number != 32'hc704dd7b)begin
			fcs_error =1;
			`uvm_error("MAC_MON",$sformatf("*********************CRC check Fail ******************"))
		end else begin
			fcs_error =0;
			$display("PASSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS");
		end
	
endtask

//-----------------------------------------------------------------------------------------------
// ===========CRC CHECK==========
//-----------------------------------------------------------------------------------------------

  task crc();

	if(payload_flag == 1)begin
	   if(crc_count < 'd8)begin                                      //----CRC_count less than  
          register = {register[27:0],h_ethernet_seq_item.MRxD};
          nibble_crc.push_back(h_ethernet_seq_item.MRxD);            //push_back 4 bits MRxD into nibble_crc queue for CRC calculation
	      crc_count = crc_count + 1;
       end
       if(crc_count==8)begin                                         //when count ==8 CRC_check task invok and check crc  
         crc_check();
		 frame_status();
	 	 ifg_check();
         bd_reg = 0;
       end
    end

  endtask

	// =========================================================
	// INTER FRAME GAP CHECK (96 bit times = 24 nibbles)
	// =========================================================
 	task ifg_check();

    		int ifg_count = 0;
    		
		if(h_config.moder[6]==0)begin								//========IFG bit===========
           		while(ifg_count < 'd24)begin
              			@( vif.cb_mac_monitor)
              			ifg_count++;
		   	end          
	    	end
    		reset_variables();
     
 	endtask
  
endclass
