//============================================FUNCTION FEATURE TESTCASES=======================================================//
//=============test case rx enable zero configuration=================
class Base_sequence_mac extends uvm_sequence #(ethernet_seq_item);
	`uvm_object_utils(Base_sequence_mac)
  
  	//--------------------declarations----------------
	config_class h_config;

	int nibble_da_to_payload[$];
	bit [31:0] generated_crc ;
    int packet_count;
	int rxbd_num;

	//-------------------object constructor--------------------
 	function new(string name="Base_sequence");
  		super.new(name);
	endfunction
    
	//----------------------task body----------------------
    virtual task body();


		//----------initial values--------------------
      	req = ethernet_seq_item::type_id::create("req");
   		
	    if(!uvm_config_db #(config_class)::get(null,this.get_full_name(),"config",h_config))
                 `uvm_fatal("MAC SEQUENCE CLASS","CONFIG CLASS NOT FOUND");
	

		initial_seq ();

		wait(h_config.config_done);					//------------waiting for reg configuration
     #0;
	//	#400;			//--------preamble starts after this delay (check waveform)

		rxbd_num = 128 - (h_config.tx_bd_num) ;		//----------calculating no. of rxbds


		for(int i;i<rxbd_num ;i++)begin

	       		preamble_generation();
		     	sfd_generation();
    	   		destination_address();
    	   		source_address();
			    length_field();
		    	payload();
		     	crc();
			    frame_gap();

				packet_count++;
		end
   		     
   	endtask

	//-------------INitial sequence------------------

	    virtual task initial_seq ();
			start_item(req);
          		 req.randomize() with{ MAC_FIELD == ALL_ZEROES;};			
    	 		`uvm_info("PREAMBLE INITIAL",$sformatf("preamble initiaited : MRxD = %h",req.MRxD),UVM_MEDIUM);
        	finish_item(req);
		endtask

	
   //---------------preamble----------------------
   	virtual task preamble_generation();
       
      if(h_config.moder[2]==0)begin	
        for(int i;i<14;i++)begin
          start_item(req);
          	req.randomize() with { MAC_FIELD == PATTERN ;};			//---------0101
     	 	`uvm_info("PREAMBLE",$sformatf("preamble generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
          finish_item(req);
        end
      end

   	endtask

	//--------------sfd--------------------------
	virtual task sfd_generation();
	
    	start_item(req);
      		req.randomize() with { MAC_FIELD == PATTERN;};			//--------0101
     	 `uvm_info("SFD",$sformatf("SFD generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
    	finish_item(req);

    	start_item(req);
      		req.randomize() with { MAC_FIELD == SFD;};				//-------1011 inverted 1101 : 'hd
     	 `uvm_info("SFD",$sformatf("SFD generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
    	finish_item(req);

	endtask

    //-----------destination--------------------------
	virtual task destination_address();
        
      
		for(int j ;j < 4;j++) begin
	  		start_item(req);
             

    	  		req.MRxD = h_config.mac_addrs1[15-(4*j)-:4];			//-------byte 0 & byte 1 nibbles [a,b,c,d]
     	 		`uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);

    		finish_item(req);

			nibble_da_to_payload.push_back(req.MRxD);
		end


		for(int j;j < 8;j++) begin
	  		start_item(req);
    	  		req.MRxD = h_config.mac_addrs0[3+(4*j)-:4];			//------byte 2,3,4,5 nibbles
     	 		`uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);

    		finish_item(req);

			nibble_da_to_payload.push_back(req.MRxD);
		end

 	endtask

 
//----------source address-------------------------------------------
	virtual task source_address();     		

	/*	for(int i;i <8 ;i++)begin
       			start_item(req);
                       req.MRxD = {3'd0,h_config.mii_addrs[4]};
					//req.MRxD = h_config.mii_addrs[31-(4*i)-:4];			//------------[31:5] ==> 6 nibbles reserved	   		 				
     	 			`uvm_info("SOURCE ADDR",$sformatf("source addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
       			finish_item(req);
			nibble_da_to_payload.push_back(req.MRxD);
     		end*/
      
   	      start_item(req);
       			req.MRxD = {3'd0,h_config.mii_addrs[4]};
			//req.MRxD = 4'h0;
     	 `uvm_info("SOURCE ADDR",$sformatf("source addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);

     		finish_item(req);

			nibble_da_to_payload.push_back(req.MRxD);
     		start_item(req);
        		req.MRxD = h_config.mii_addrs[3:0];
        	//	req.MRxD = 4'hc;
     	 `uvm_info("SOURCE ADDR",$sformatf("source addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);

     		finish_item(req);

			nibble_da_to_payload.push_back(req.MRxD);
            
          for(int i;i<10;i++)begin
          start_item(req);

					req.randomize() with {MAC_FIELD == ADDZEROS;};			//------------[31:5] ==> 6 nibbles reserved	   		 				
     	 			`uvm_info("SOURCE ADDR",$sformatf("source addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
       			finish_item(req);
			nibble_da_to_payload.push_back(req.MRxD);
     		end

  	endtask

	//---------------------length-------------------------
	virtual task length_field();
           	
			int addr;
			reg [31:0] rxbd_reg;

			addr = (h_config.tx_bd_num+packet_count)*8 ; 

			rxbd_reg = h_config.rxbd[1024+addr];

	    	`uvm_info("RXBD_ADDR",$sformatf("\n \t===> packet_count = %0d \t rxbd_reg = %h \t addr = %0d ", packet_count, rxbd_reg , addr),UVM_HIGH);
//			h_config.display;
		   	for(int i;i<4 ;i++)begin
		    	start_item(req);
       				req.MRxD =  rxbd_reg[31-(4*i) -: 4];
     	 			`uvm_info("LENGTH",$sformatf("length generated : MRxD = %b",req.MRxD),UVM_MEDIUM);
       			finish_item(req);
	       
				nibble_da_to_payload.push_back(req.MRxD);
			end
	endtask

	//----------------payload + pad ----------------------
	virtual task payload();
			int i;
			int payload_reg ;

			payload_reg = h_config.rxbd[1024+((h_config.tx_bd_num+packet_count)*8)][31:16] ;
			$display("payload_reg=%0d",payload_reg);
       		
			if(payload_reg <= 'd46) begin
				if(h_config.moder[15] == 1) begin
		   		        
					 	for(int i;i < payload_reg*2 ;i++)begin
			
       						start_item(req);

								req.randomize() with {MAC_FIELD == DEFAULT ; };
     	 							`uvm_info("PAYLOAD",$sformatf("payload : MRxD = %h",req.MRxD),UVM_MEDIUM);

							finish_item(req);

							nibble_da_to_payload.push_back(req.MRxD);
  						end



						for(int i;i<((46-payload_reg)*2);i++) begin
				
       						start_item(req);

								req.randomize() with {MAC_FIELD == ADDZEROS;};
     	 							`uvm_info("PAYLOAD",$sformatf(" - with pad : MRxD = %h",req.MRxD),UVM_MEDIUM);

							finish_item(req);

							nibble_da_to_payload.push_back(req.MRxD);
  						end
				end
				else begin
					for(int i;i<payload_reg*2;i++) begin
				
       					start_item(req);
							req.randomize() with {MAC_FIELD == DEFAULT ;};
     	 						`uvm_info("PAYLOAD",$sformatf("payload - no pad : MRxD = %h",req.MRxD),UVM_MEDIUM);

						finish_item(req);

						nibble_da_to_payload.push_back(req.MRxD);
  					end

				end
			end
			else if(payload_reg > 'd46 && payload_reg < 'd1500) begin
				for(int i;i<payload_reg*2 ;i++) begin
				
       					start_item(req);

							req.randomize() with {MAC_FIELD == DEFAULT ; };
     	 						`uvm_info("PAYLOAD",$sformatf("payload > 46 : MRxD = %h",req.MRxD),UVM_MEDIUM);

						finish_item(req);

						nibble_da_to_payload.push_back(req.MRxD);
  				end

			end
	endtask
	
	//-----------------------crc generation--------------------
	virtual task crc();
		int c;

			crc_generation();

			for(int i;i<8 ;i++)begin
			    	start_item(req);
       					req.MRxD = generated_crc[31-(4*i)-:4] ;
     	 				`uvm_info("CRC",$sformatf("crc generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
       				finish_item(req);
			end
	endtask



//----------------CRC GENERATION TASK---------------------

	virtual task crc_generation();
		bit [3:0] data;
		bit [31:0] crc_variable = 32'hffff_ffff; // initializing the variable
		bit [31:0] crc_next; 
		int nibble_size;
		
		nibble_size = nibble_da_to_payload.size;
	
			for(int i=0;i<nibble_size;i++) 
			begin
			data = nibble_da_to_payload.pop_front;
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

		generated_crc[31:28] = {~crc_variable[28],~crc_variable[29],~crc_variable[30],~crc_variable[31]};
		generated_crc[27:24] = {~crc_variable[24],~crc_variable[25],~crc_variable[26],~crc_variable[27]};
		generated_crc[23:20] = {~crc_variable[20],~crc_variable[21],~crc_variable[22],~crc_variable[23]};
		generated_crc[19:16] = {~crc_variable[16],~crc_variable[17],~crc_variable[18],~crc_variable[19]};
		generated_crc[15:12] = {~crc_variable[12],~crc_variable[13],~crc_variable[14],~crc_variable[15]};
		generated_crc[11:8] = {~crc_variable[8],~crc_variable[9],~crc_variable[10],~crc_variable[11]};
		generated_crc[7:4] = {~crc_variable[4],~crc_variable[5],~crc_variable[6],~crc_variable[7]};
		generated_crc[3:0] = {~crc_variable[0],~crc_variable[1],~crc_variable[2],~crc_variable[3]};
	
	endtask

	//-----------------IFG----------------------------------------------
   	virtual task frame_gap();
      if(h_config.moder[6] == 0) begin
		for(int i;i<24;i++)begin
          		start_item(req);
          			req.randomize() with { MAC_FIELD == ALL_ZEROES ;};			
     	 			`uvm_info("INTERFRAME GAP",$sformatf("IFG: MRxD = %h",req.MRxD),UVM_MEDIUM);
          		finish_item(req);
        	end
    end

	endtask

endclass

//------------TEST CASE - 3----------------------------------------------------------------------------------------------------

class TC_RXEN_0_mac extends Base_sequence_mac;
 `uvm_object_utils(TC_RXEN_0_mac)
  int tx_bd_num;

   //====object constructor=====================================
 	function new(string name="TC_RXEN_0_mac");
  		super.new(name);
	endfunction
	//=========task body===============================
	task body();                                                                                             
        	super.body();                                                                                                              
	endtask	    

endclass

//------------TEST CASE - 4------------------------------------------------------------------------------------------------

class TC_RXEN_1_mac  extends Base_sequence_mac;
 `uvm_object_utils(TC_RXEN_1_mac)


   //====object constructor=====================================
 	function new(string name="TC_RXEN_1_mac");
  		super.new(name);
	endfunction
	//=========task body===============================
	task body();                                                                                             
        	super.body();                                                                                                              
	endtask	    

endclass


//------------TEST CASE - 5-------------------------------------------------------------------------------------------

class TC_MCrS_0_mac extends Base_sequence_mac;
 `uvm_object_utils(TC_MCrS_0_mac)
   //====object constructor=====================================
 	function new(string name="TC_MCrS_0_mac");
  		super.new(name);
	endfunction
	//=========task body===============================
	task body();                                                                                             
        super.body();                                                                                                              
	endtask	  
 
endclass

//------------TEST CASE - 6---------------------------------------------------------------------------------------------

class TC_MCrS_1_mac  extends Base_sequence_mac;
 `uvm_object_utils(TC_MCrS_1_mac)
   //====object constructor=====================================
 	function new(string name="TC_MCrS_1_mac");
  		super.new(name);
	endfunction
	//=========task body===============================
	task body();                                                                                             
        super.body();                                                                                                              
	endtask	  
 
	task initial_seq ();
		start_item(req);
         	 req.randomize() with { MCrS == 1'b1; MRxErr == 1'b0;};			//-------when MCrs = 1 ,need not check other signals
    	 	`uvm_info("PREAMBLE INITIAL",$sformatf("preamble initiaited : MRxD = %h",req.MRxD),UVM_MEDIUM);
        	finish_item(req);
	endtask
 
endclass

//------------TEST CASE - 7--------------------------------------------------------------------------------------

class TC_EMPTY_0_mac  extends Base_sequence_mac;
 `uvm_object_utils( TC_EMPTY_0_mac )
   //====object constructor=====================================
 	function new(string name="TC_EMPTY_0_mac");
  		super.new(name);
	endfunction

	//=========task body===============================
	task body();                                                                                             
        super.body();                                                                                                              
	endtask	    
endclass

//---------TEST CASE -8--------------------------------------------------------------------------------------
class TC_EMPTY_RXBDS_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_EMPTY_RXBDS_mac)
    //===OBJECT CONSTRUCTOR ==========================
	function new(string name="TC_EMPTY_RXBDS_mac");
    	super.new(name);
	endfunction
   //====task body===============================
	task body();
 	   super.body();
	endtask
endclass

//---------TEST CASE -9---------------------------------------------------------------------------------------

class TC_MRxERR_1_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_MRxERR_1_mac)
    //====object constructor======================
	function new(string name="TC_MRxERR_1_mac");
  	  super.new(name);
	endfunction
    //====task body=============================
	task body();
  	  super.body();
	endtask
    //====preamble task error case
    task preamble_generation();
       
      if(h_config.moder[2]==0)begin	
        for(int i;i<14;i++)begin
          start_item(req);
          	req.randomize() with { MAC_FIELD == ERROR;};			//---------0101
     	 	`uvm_info("PREAMBLE",$sformatf("preamble generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
          finish_item(req);
        end
      end

   	endtask

endclass

//---------TEST CASE -10--------------------------------------------------------------------------------------

class TC_NOPRE_1_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_NOPRE_1_mac)
   //====object constructor======================
   function new(string name="TC_NOPRE_1_mac");
   		 super.new(name);
	endfunction
   //====task body========================
	task body();
 	   super.body();
	endtask
endclass

//---------TEST CASE -11--------------------------------------------------------------------------------------------

class TC_NOPRE_1_IL_mac extends Base_sequence_mac;       //==PREAMBLE BIT IS one not send  preamble but we are sending preamble

    `uvm_object_utils(TC_NOPRE_1_IL_mac)
    //======object constructor=====================
	function new(string name="TC_NOPRE_1_IL_mac");
 	   super.new(name);
	endfunction
    //=====task body================================
	task body();
 	   super.body();
	endtask

	 task preamble_generation();
   	  
       		 for(int i;i<14;i++)begin
          		start_item(req);
          			req.randomize() with { MAC_FIELD == ERROR;};			//---------0101
     	 			`uvm_info("PREAMBLE",$sformatf("preamble generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
          		finish_item(req);
        	end     	 

   	endtask

endclass

//---------TEST CASE -12--------------------------------------------------------------------------------------------
class TC_PRO_BRO_00_DA_MAC_mac extends Base_sequence_mac;      //===PRO =0 and BRO=0 but we are sending mac address only
    `uvm_object_utils(TC_PRO_BRO_00_DA_MAC_mac)
    //=====object constructor=================================
	function new(string name="TC_PRO_BRO_00_DA_MAC_mac");
  	  super.new(name);
	endfunction
   //=====task body==========================================
    task body();
   	 super.body();
   endtask
  
endclass

//---------TEST CASE -13--------------------------------------------------------------------------------------------

class TC_PRO_BRO_00_DA_BRDCST_mac extends Base_sequence_mac;               //PRO=0 & BRO=0 we are sending broadcast address all 11111's
    `uvm_object_utils(TC_PRO_BRO_00_DA_BRDCST_mac)
    //===object constructor================================
	function new(string name="TC_PRO_BRO_00_DA_BRDCST_mac");
 	   super.new(name);
	endfunction
   //==task body============================================
	task body();
	    super.body();
	endtask
  //====destination address====================================
    task destination_address();

   	for(int j ;j < 12;j++) begin
	  		start_item(req);             
   	  			 req.randomize() with {MAC_FIELD == BRDCST;};
     	 		`uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
    		finish_item(req);

			nibble_da_to_payload.push_back(req.MRxD);
		end
   endtask
endclass

//---------TEST CASE -14--------------------------------------------------------------------------------------------

class TC_PRO_BRO_01_DA_MAC_mac extends Base_sequence_mac;       //PRO=0 & BRO=1  as BRO is 1 reject broadcast we are sending mac address for checking 
    `uvm_object_utils(TC_PRO_BRO_01_DA_MAC_mac)
     //===object constructor===========================
	function new(string name="TC_PRO_BRO_01_DA_MAC_mac");
	    super.new(name);
	endfunction
	//====task body====================================
	task body();
  	  super.body();
	endtask
endclass

//---------TEST CASE -15--------------------------------------------------------------------------------------------

class TC_PRO_BRO_01_DA_BRDCST_mac extends Base_sequence_mac;      //PRO=0 & BRO=1  as BRO is 1 reject broadcast we are sending broadcast so drop frame
    `uvm_object_utils(TC_PRO_BRO_01_DA_BRDCST_mac)
    //===object constructor===========================
	function new(string name="TC_PRO_BRO_01_DA_BRDCST_mac");
 	   super.new(name);
	endfunction

	task body();
	    super.body();
	endtask
endclass
//---------TEST CASE -16--------------------------------------------------------------------------------------------

class TC_PRO_BRO_10_mac extends Base_sequence_mac;           //PRO=1 & BRO=0 as PRO bit high accept all frames irrespective of destiantion address
    `uvm_object_utils(TC_PRO_BRO_10_mac)
	//===object constructor===========================
	function new(string name="TC_PRO_BRO_10_mac");
 	   super.new(name);
	endfunction
	task body();
	    super.body();
	endtask
endclass

//---------TEST CASE -17--------------------------------------------------------------------------------------------

class TC_PRO_BRO_11_mac extends Base_sequence_mac;              //PRO=1 & BRO=1 as PRO bit high accept all frames irrespective of destiantion address
    `uvm_object_utils(TC_PRO_BRO_11_mac)
    //===object constructor===========================
	function new(string name="TC_PRO_BRO_11_mac");
	    super.new(name);
	endfunction
   //=====task body=====================================
	task body();
  	  super.body();
	endtask
endclass

//---------TEST CASE -18--------------------------------------------------------------------------------------------

class TC_WRONG_DA_4BYTES_mac extends Base_sequence_mac;              //first 4 bytes destination address not match with mac address
    `uvm_object_utils(TC_WRONG_DA_4BYTES_mac)
	//===object constructor===========================
	function new(string name="TC_WRONG_DA_4BYTES_mac");
    	super.new(name);
	endfunction
   //===task body========================================
	task body();
	    super.body();
	endtask
  //===destination address===============================
    task destination_address();
        
      
		for(int j ;j < 4;j++) begin
	  		start_item(req);
                 req.randomize() with{MAC_FIELD == DEFAULT;};          //as first 4 bytes data is wrong i am sending first 4 nibbles randomly
     	 		`uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);

    		finish_item(req);

			nibble_da_to_payload.push_back(req.MRxD);
		end


		for(int j;j < 8;j++) begin
	  		start_item(req);
    	  		req.MRxD = h_config.mac_addrs0[3+(4*j)-:4];			//------byte 2,3,4,5 nibbles
     	 		`uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);

    		finish_item(req);

			nibble_da_to_payload.push_back(req.MRxD);
		end

 	endtask

endclass
//---------TEST CASE -19--------------------------------------------------------------------------------------------

class TC_WRONG_DA_LAST_2BYTES_mac extends Base_sequence_mac;           //last 2 bytes data of destination address  is wrong 
    `uvm_object_utils(TC_WRONG_DA_LAST_2BYTES_mac)
     //===object constructor===========================
	function new(string name="TC_WRONG_DA_LAST_2BYTES_mac");
 	   super.new(name);
	endfunction
    //=====task body===================================
	task body();
  	  super.body();
	endtask
    //===destination address===============================
    task destination_address();
        
      
		for(int j ;j < 4;j++) begin
	  		start_item(req);
              	req.MRxD = h_config.mac_addrs1[15-(4*j)-:4];	//first 2 bytes
     	 		`uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);

    		finish_item(req);

			nibble_da_to_payload.push_back(req.MRxD);
		end


		for(int j;j < 4;j++) begin
	  		start_item(req);
    	  		req.MRxD = h_config.mac_addrs0[3+(4*j)-:4];			//another 2 bytes
     	 		`uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);

    		finish_item(req);

			nibble_da_to_payload.push_back(req.MRxD);
		end

      	for(int j;j < 4;j++) begin
	  		start_item(req);
    	           req.randomize() with{MAC_FIELD == DEFAULT;};    //last 2 bytes are random 
     	 		`uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);

    		finish_item(req);

			nibble_da_to_payload.push_back(req.MRxD);
		end
      


 	endtask

endclass
//-----------------------TEST CASE -20------------------------------------------

class TC_FL_LESS_THAN_MINFL_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_FL_LESS_THAN_MINFL_mac)
function new(string name="TC_FL_LESS_THAN_MINFL_mac");
    super.new(name);
endfunction
task body();
    super.body();
endtask
endclass

//-----------------------TEST CASE -21------------------------------------------

class TC_FL_EQUAL_TO_MINFL_PAD_0_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_FL_EQUAL_TO_MINFL_PAD_0_mac)
function new(string name="TC_FL_EQUAL_TO_MINFL_PAD_0_mac");
    super.new(name);
endfunction
task body();
    super.body();
endtask
endclass

//-----------------------TEST CASE -22------------------------------------------

class TC_FL_EQUAL_TO_MINFL_PAD_1_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_FL_EQUAL_TO_MINFL_PAD_1_mac)
function new(string name="TC_FL_EQUAL_TO_MINFL_PAD_1_mac");
    super.new(name);
endfunction
task body();
    super.body();
endtask
endclass

//-----------------------TEST CASE -23------------------------------------------

class TC_FL_LL_PAD_1_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_FL_LL_PAD_1_mac)
function new(string name="TC_FL_LL_PAD_1_mac");
    super.new(name);
endfunction
task body();
    super.body();
endtask
endclass

//-----------------------TEST CASE -24------------------------------------------

class TC_FL_LL_HUGEN_1_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_FL_LL_HUGEN_1_mac)
function new(string name="TC_FL_LL_HUGEN_1_mac");
    super.new(name);
endfunction
task body();
    super.body();
endtask
endclass

//-----------------------TEST CASE -25------------------------------------------

class TC_FL_LL_HUGEN_1_PAD_1_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_FL_LL_HUGEN_1_PAD_1_mac)
function new(string name="TC_FL_LL_HUGEN_1_PAD_1_mac");
    super.new(name);
endfunction
task body();
    super.body();
endtask
endclass

//-----------------------TEST CASE -26------------------------------------------

class TC_FL_GREATER_THAN_MAXFL_HUGEN_0_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_FL_GREATER_THAN_MAXFL_HUGEN_0_mac)
function new(string name="TC_FL_GREATER_THAN_MAXFL_HUGEN_0_mac");
    super.new(name);
endfunction
task body();
    super.body();
endtask
endclass

//-----------------------TEST CASE -27------------------------------------------

class TC_FL_GREATER_THAN_MAXFL_HUGEN_1_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_FL_GREATER_THAN_MAXFL_HUGEN_1_mac)
function new(string name="TC_FL_GREATER_THAN_MAXFL_HUGEN_1_mac");
    super.new(name);
endfunction
task body();
    super.body();
endtask
endclass

//-----------------------TEST CASE -28------------------------------------------

class TC_FL_GREATER_THAN_MAXFL_2KB_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_FL_GREATER_THAN_MAXFL_2KB_mac)
function new(string name="TC_FL_GREATER_THAN_MAXFL_2KB_mac");
    super.new(name);
endfunction
task body();
    super.body();
endtask
endclass

//-----------------------TEST CASE -29------------------------------------------

class TC_IRQ_0_MASKED_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_IRQ_0_MASKED_mac)

//====object constructor=====================================
function new(string name="TC_IRQ_0_MASKED_mac");
    super.new(name);
endfunction

//=========task body===============================
task body();
    super.body();
endtask

endclass

//-----------------------TEST CASE -30------------------------------------------

class TC_IRQ_0_UNMASKED_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_IRQ_0_UNMASKED_mac)

function new(string name="TC_IRQ_0_UNMASKED_mac");
    super.new(name);
endfunction

task body();
    super.body();
endtask

endclass

//-----------------------TEST CASE -31------------------------------------------

class TC_IRQ_1_MASKED_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_IRQ_1_MASKED_mac)

function new(string name="TC_IRQ_1_MASKED_mac");
    super.new(name);
endfunction

task body();
    super.body();
endtask

endclass

//-----------------------TEST CASE -32------------------------------------------

class TC_IRQ_1_UNMASKED_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_IRQ_1_UNMASKED_mac)

function new(string name="TC_IRQ_1_UNMASKED_mac");
    super.new(name);
endfunction

task body();
    super.body();
endtask

endclass

//-----------------------TEST CASE -33------------------------------------------

class TC_IFG_0_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_IFG_0_mac)

function new(string name="TC_IFG_0_mac");
    super.new(name);
endfunction

task body();
    super.body();
endtask

endclass

//-----------------------TEST CASE -34------------------------------------------

class TC_IFG_1_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_IFG_1_mac)

function new(string name="TC_IFG_1_mac");
    super.new(name);
endfunction

task body();
    super.body();
endtask

endclass

//-----------------------TEST CASE -35------------------------------------------

class TC_TXBD_NUM_128_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_TXBD_NUM_128_mac)

function new(string name="TC_TXBD_NUM_128_mac");
    super.new(name);
endfunction

task body();
    super.body();
endtask

endclass

//-----------------------TEST CASE -36------------------------------------------

class TC_TXBD_NUM_GREATER_128_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_TXBD_NUM_GREATER_128_mac)

function new(string name="TC_TXBD_NUM_GREATER_128_mac");
    super.new(name);
endfunction

task body();
    super.body();
endtask

endclass

//-----------------------TEST CASE -37------------------------------------------

class TC_UNALLIGNED_RX_PNTR_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_UNALLIGNED_RX_PNTR_mac)

function new(string name="TC_UNALLIGNED_RX_PNTR_mac");
    super.new(name);
endfunction

task body();
    super.body();
endtask

endclass

//-----------------------TEST CASE -38------------------------------------------

class TC_INVALID_ACCESS_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_INVALID_ACCESS_mac)

function new(string name="TC_INVALID_ACCESS_mac");
    super.new(name);
endfunction

task body();
    super.body();
endtask

endclass

//-----------------------TEST CASE -39------------------------------------------

class TC_CRC_ERROR_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_CRC_ERROR_mac)

function new(string name="TC_CRC_ERROR_mac");
    super.new(name);
endfunction

task body();
    super.body();
endtask

endclass

//------------------TEST CASE 40---------------
//  

class TC_INSUFFICIENT_BD_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_INSUFFICIENT_BD_mac)

function new(string name="TC_INSUFFICIENT_BD_mac");
    super.new(name);
endfunction

task body();
    super.body();
endtask

endclass

//------------------TEST CASE 41---------------
//  If a BD is considered as a bad frame, then the next BDs pointer is overriden with the present BDs pointer. 
//But when the last BD is a bad frame it doesn't have any further BDs

class TC_LAST_BD_0_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_LAST_BD_0_mac)

function new(string name="TC_LAST_BD_0_mac");
    super.new(name);
endfunction

task body();
    super.body();
endtask

endclass


//------------------TEST CASE 42---------------
// The length in the RXBD and the Length field in the frame are not equal. 

class TC_RXBD_LEN_NE_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_RXBD_LEN_NE_mac)

function new(string name="TC_RXBD_LEN_NE_mac");
    super.new(name);
endfunction

task body();
    super.body();
endtask

endclass


//------------------TEST CASE 43---------------
// Preamble, which is 7 bytes, must be 101010?...101010. Wrong Preamble pattern is sent for one frame and less number of preamble bytes are sent

class TC_WRONG_PREAMBLE_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_WRONG_PREAMBLE_mac)

function new(string name="TC_WRONG_PREAMBLE_mac");
    super.new(name);
endfunction

task body();
    super.body();
endtask

  task preamble_generation();

      if(packet_count == rxbd_num/2) begin 
    	  if(h_config.moder[2]==0)begin	  //--preamble
        	for(int i;i<14;i++)begin
        	  start_item(req);
        	  	assert(req.randomize() with { MAC_FIELD == DEFAULT;})			//---------
     		 	`uvm_info("PREAMBLE",$sformatf("preamble generated : MRxD = %h",req.MRxD),UVM_MEDIUM)   else `uvm_error("RANDOMISE_FAIL", "Register configuration mismatch");
        	  finish_item(req);
       	 	end
      	  end
		end
	else begin
      if(h_config.moder[2]==0)begin	  //--preamble
        for(int i;i<14;i++)begin
          start_item(req);
          	assert(req.randomize() with { MAC_FIELD == PATTERN;})			//---------
     	 	`uvm_info("PREAMBLE",$sformatf("preamble generated : MRxD = %h",req.MRxD),UVM_MEDIUM)   else `uvm_error("RANDOMISE_FAIL", "Register configuration mismatch");
          finish_item(req);
        end
      end
    end

   endtask

endclass

//------------------TEST CASE 44---------------
// SFD, which is 1 byte, 10101011; the last 2 bits are 11, indicate the start of the frame.Wrong SFD pattern is sent

class TC_WRONG_SFD_mac extends Base_sequence_mac;

    `uvm_object_utils(TC_WRONG_SFD_mac)

	function new(string name="TC_WRONG_SFD_mac");
        super.new(name);
     endfunction

task body();
    super.body();
endtask

	task sfd_generation();
	
    	start_item(req);
      		assert(req.randomize() with { MAC_FIELD == DEFAULT;})			//--------random MRxD
     	 `uvm_info("SFD",$sformatf("SFD generated : MRxD = %h",req.MRxD),UVM_MEDIUM)   else `uvm_error("RANDOMISE_FAIL", "Register configuration mismatch");
    	finish_item(req);

    	start_item(req);
      		assert(req.randomize() with { MAC_FIELD == DEFAULT;})			//-------random MRxD
     	 `uvm_info("SFD",$sformatf("SFD generated : MRxD = %h",req.MRxD),UVM_MEDIUM)   else `uvm_error("RANDOMISE_FAIL", "Register configuration mismatch");
    	finish_item(req);

	endtask


endclass

//------------------TEST CASE 45---------------


class TC_WRONG_PADDING_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_WRONG_PADDING_mac)

      function new(string name="TC_WRONG_PADDING_mac");
         super.new(name);
      endfunction

      task body();
         super.body();
      endtask


      task payload();
			int i;
			int payload_reg ;

			payload_reg = h_config.rxbd[1024+((h_config.tx_bd_num+packet_count)*8)][31:16] ;

			$display("payload_reg=%0d",payload_reg);
       		
			if(payload_reg <= 'd46) begin
				if(h_config.moder[15] == 1) begin
		   		        
					 	for(int i;i < payload_reg*2 ;i++)begin
			
       						start_item(req);

								assert(req.randomize() with {MAC_FIELD == DEFAULT ; })		//---------MRxD random
     	 							`uvm_info("PAYLOAD",$sformatf("payload : MRxD = %h",req.MRxD),UVM_MEDIUM)   else `uvm_error("RANDOMISE_FAIL", "Register configuration mismatch");

							finish_item(req);

							nibble_da_to_payload.push_back(req.MRxD);
  						end



						for(int i;i<((46-payload_reg)*2);i++) begin
				
       						start_item(req);

								assert(req.randomize() with {MAC_FIELD == DEFAULT;})
     	 							`uvm_info("PAYLOAD",$sformatf(" - with pad : MRxD = %h",req.MRxD),UVM_MEDIUM)   else `uvm_error("RANDOMISE_FAIL", "Register configuration mismatch");
								
								
								req.MRxD = 4'hf;

							finish_item(req);

							nibble_da_to_payload.push_back(req.MRxD);
  						end
				end
             end
         endtask
endclass

//------------------TEST CASE 46---------------

class TC_LENGTH_LS_4_mac extends Base_sequence_mac;

    `uvm_object_utils(TC_LENGTH_LS_4_mac)

     function new(string name="TC_LENGTH_LS_4_mac");
        super.new(name);
     endfunction

     task body();
        super.body();
     endtask

endclass

//------------------TEST CASE 47---------------
//  When frame is being received the MRxDV is deasserted
class TC_MRxDV_0_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_MRxDV_0_mac)

	function new(string name="TC_MRxDV_0_mac");
   		 super.new(name);
	endfunction

	task body();
   		 super.body();
	endtask

	     task payload();
			int i,temp;
			int payload_reg ;

			payload_reg = h_config.rxbd[1024+((h_config.tx_bd_num+packet_count)*8)][31:16] ;
			temp = $urandom_range(0,payload_reg);

			$display("payload_reg=%0d",payload_reg);
       		
			if(payload_reg <= 'd46) begin
				if(h_config.moder[15] == 1) begin
		   		        
					 	for(int i;i < payload_reg*2 ;i++)begin
			
       						start_item(req);

								assert(req.randomize() with {MAC_FIELD == DEFAULT ; })		//---------MRxD random
     	 							`uvm_info("PAYLOAD",$sformatf("payload : MRxD = %h",req.MRxD),UVM_MEDIUM)   else `uvm_error("RANDOMISE_FAIL", "Register configuration mismatch");
								if(i == temp)
									req.MRxDV = 0;
							finish_item(req);

							nibble_da_to_payload.push_back(req.MRxD);
  						end



						for(int i;i<((46-payload_reg)*2);i++) begin
				
       						start_item(req);

								assert(req.randomize() with {MAC_FIELD == DEFAULT;})
     	 							`uvm_info("PAYLOAD",$sformatf(" - with pad : MRxD = %h",req.MRxD),UVM_MEDIUM)   else `uvm_error("RANDOMISE_FAIL", "Register configuration mismatch");
								
								
								req.MRxD = 4'hf;

							finish_item(req);

							nibble_da_to_payload.push_back(req.MRxD);
  						end
				end
             end
         endtask

endclass

//------------------TEST CASE 48---------------

class TC_REG_CONFIG_AFTER_RXEN_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_REG_CONFIG_AFTER_RXEN_mac)

	function new(string name="TC_REG_CONFIG_AFTER_RXEN_mac");
   		 super.new(name);
	endfunction

	task body();
  	 	 super.body();
	endtask

endclass

//------------------TEST CASE 49---------------
//  When IFG is set to 0, Interframe gap is less than 24clock cycles 

class TC_IFG_LS_24_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_IFG_LS_24_mac)

	function new(string name="TC_IFG_LS_24_mac");
    	super.new(name);
	endfunction

	task body();
   		 super.body();
	endtask

   	task frame_gap();
       if(h_config.moder[6] == 0) begin
		  for(int i;i<19;i++)begin
          		start_item(req);
          			assert(req.randomize() with { MAC_FIELD == ALL_ZEROES ;})			
     	 			`uvm_info("INTERFRAME GAP",$sformatf("IFG: MRxD = %h",req.MRxD),UVM_MEDIUM)   else `uvm_error("RANDOMISE_FAIL", "Register configuration mismatch");
          		finish_item(req);
        	end
       end

	endtask

endclass

//------------------TEST CASE 50---------------
//  When IFG is set to 0, Interframe gap is more than 24clock cycles 

class TC_IFG_GS_24_mac extends Base_sequence_mac;
    `uvm_object_utils(TC_IFG_GS_24_mac)

	function new(string name="TC_IFG_GS_24_mac");
    	super.new(name);
	endfunction

	task body();
    	super.body();
	endtask

   	task frame_gap();
         if(h_config.moder[6] == 0) begin
		   for(int i;i<29;i++)begin
          		start_item(req);
          			assert(req.randomize() with { MAC_FIELD == ALL_ZEROES ;})			
     	 			`uvm_info("INTERFRAME GAP",$sformatf("IFG: MRxD = %h",req.MRxD),UVM_MEDIUM)   else `uvm_error("RANDOMISE_FAIL", "Register configuration mismatch");
          		finish_item(req);
        	end
          end

	endtask
endclass




/*

//============================================FUNCTION FEATURE TESTCASES=======================================================//

//=============test case rx enable zero configuration=================
class TC_RXEN_0 extends uvm_sequence #(ethernet_seq_item);
	`uvm_object_utils(TC_RXEN_0)
  
  	//--------------------declarations----------------
	config_class h_config;
    int k;
	int nibble_da_to_payload[$];
	bit [31:0] generated_crc ;

	//-------------------object constructor--------------------
 	function new(string name="TC_RXEN_0");
  		super.new(name);
	endfunction
    
	//----------------------task body----------------------
    task body();
		int rxbd_num;
      	req = ethernet_seq_item::type_id::create("req");
   		
	    if(!uvm_config_db #(config_class)::get(null,this.get_full_name(),"config",h_config))
                 `uvm_fatal("MAC SEQUENCE CLASS","CONFIG CLASS NOT FOUND");
		

		wait(h_config.config_done);
		#400;

		rxbd_num = 128 - (h_config.tx_bd_num) ;

		//h_config.display();		//----------to display TXBDNUM
		$display("\n \t\t ===========>>rx_bd_num = %d \n \n ",rxbd_num);

		for(int i;i<rxbd_num ;i++)begin
	       		preamble_generation();
			sfd_generation();
    	   		destination_address();
    	   		source_address();
			length_field();
			payload();
			crc();
			frame_gap();
			k++;			//-------
		end
   		     
   endtask
	
	task frame_gap();
		for(int i;i<24;i++)begin
          		start_item(req);
          			req.MRxD = 0;req.MRxDV = 0; req.MCrS = 0;			//-----101010101.....1010
     	 			`uvm_info("PREAMBLE",$sformatf("preamble generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
          		finish_item(req);
        	end

	endtask
   //---------------preamble----------------------
   task preamble_generation();
     	
	int preamble = 4'h5;
	start_item(req);
          	req.MRxD =0 ; req.MRxDV = 0; req.MCrS = 'b0;				//-----101010101.....1010

     	 	`uvm_info("PREAMBLE",$sformatf("preamble generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
     	 	//`uvm_fatal("PREAMBLE","ERRORRRRRRRRRRRRRRRRRRRRRRRRRR");
          finish_item(req);

      	//preamble = 4'h5;

        for(int i;i<14;i++)begin
          start_item(req);
          	req.MRxD = preamble;req.MRxDV = 1; req.MCrS = 1;			//-----101010101.....1010
     	 	`uvm_info("PREAMBLE",$sformatf("preamble generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
          finish_item(req);
        end

   endtask

	task sfd_generation();
	
    	start_item(req);
      		req.MRxD = 4'h5;req.MRxDV = 1;
     	 `uvm_info("SFD",$sformatf("SFD generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
    	finish_item(req);

    	start_item(req);
      		req.MRxD = 4'hd;req.MRxDV = 1;
     	 `uvm_info("SFD",$sformatf("SFD generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
    	finish_item(req);

	endtask
      //-----------destination--------------------------
  
	task destination_address();

		int j=8;

    	/*for(int i;i< ;i++)(4) begin
			start_item(req);
      			req.MRxD = h_config.mac_addrs1[((4*i)-1) -:4];
     	 `uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);

    		finish_item(req);
			nibble_da_to_payload.push_back(req.MRxD);
			i--;
		end
	
		
		start_item(req);
      			req.MRxD = 4'ha;
     	 		`uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
    		finish_item(req);
		nibble_da_to_payload.push_back(req.MRxD);
		start_item(req);
      			req.MRxD = 4'hb;
     	 		`uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
    		finish_item(req);
		nibble_da_to_payload.push_back(req.MRxD);		start_item(req);
      			req.MRxD = 4'hc;
     	 		`uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
    		finish_item(req);
		nibble_da_to_payload.push_back(req.MRxD);		start_item(req);
      			req.MRxD = 4'hd;
     	 		`uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
    		finish_item(req);
		nibble_da_to_payload.push_back(req.MRxD);

		for(int i;i<8;i++) begin
	  		start_item(req);
    	  			req.MRxD = h_config.mac_addrs0[((4*j)-1)-:4];
     	 			`uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
			finish_item(req);
			nibble_da_to_payload.push_back(req.MRxD);
			j--;
		end	

 
 endtask
//----------source address-------------------------------------------
	task source_address();

 		//byte 0 
     		start_item(req);
       			//req.MRxD = {3'd0,h_config.mii_addrs[4]};
			req.MRxD = 4'h0;
     	 `uvm_info("SOURCE ADDR",$sformatf("source addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);

     		finish_item(req);

			nibble_da_to_payload.push_back(req.MRxD);
     		start_item(req);
        		//req.MRxD = h_config.mii_addrs[3:0];
        		req.MRxD = 4'hc;
     	 `uvm_info("SOURCE ADDR",$sformatf("source addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);

     		finish_item(req);

			nibble_da_to_payload.push_back(req.MRxD);
     	//byte1 to 5
     		for(int i;i<10 ;i++)begin
       			start_item(req);
       				req.MRxD = 4'h0;
     	 			`uvm_info("SOURCE ADDR",$sformatf("source addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
       			finish_item(req);
			nibble_da_to_payload.push_back(req.MRxD);
     		end
  endtask
//---------------------length-------------------------
	task length_field();
           	int i=0;
		reg [31:0] rxbd_reg;
		rxbd_reg = h_config.rxbd[1024+(h_config.tx_bd_num+k)*8];
		$display("k=%0d  -----------rxbd_reg=%0d adrress [%d]",k,rxbd_reg,1024+(h_config.tx_bd_num+k)*8);
     	 	`uvm_info("RXBD_ADDR",$sformatf(" ===> rxbd_reg = %h",rxbd_reg),UVM_HIGH);
		//h_config.display;
		//for(int i;i<4 ;i++)begin
		    start_item(req);
       			//req.MRxD =  rxbd_reg[31-(4*i) -: 4];
       			req.MRxD =  0;
     	 		`uvm_info("LENGTH",$sformatf("length generated : MRxD = %b",req.MRxD),UVM_MEDIUM);
       		    finish_item(req);
	            nibble_da_to_payload.push_back(req.MRxD);
		    start_item(req);
       			//req.MRxD =  rxbd_reg[31-(4*i) -: 4];
       			req.MRxD =  0;
     	 		`uvm_info("LENGTH",$sformatf("length generated : MRxD = %b",req.MRxD),UVM_MEDIUM);
     	 		`uvm_info("LENGTH",$sformatf("length generated : MRxD = %b",req.MRxD),UVM_MEDIUM);
       		    finish_item(req);
	            nibble_da_to_payload.push_back(req.MRxD);
		    start_item(req);
       		//	req.MRxD =  rxbd_reg[31-(4*i) -: 4];
       			req.MRxD =  4'hc;
     	 		`uvm_info("LENGTH",$sformatf("length generated : MRxD = %b",req.MRxD),UVM_MEDIUM);
     	 		`uvm_info("LENGTH",$sformatf("length generated : MRxD = %b",req.MRxD),UVM_MEDIUM);
       		    finish_item(req);
	            nibble_da_to_payload.push_back(req.MRxD);
		    start_item(req);
       			//req.MRxD =  rxbd_reg[31-(4*i) -: 4];
       			req.MRxD =  4'h3;
     	 		`uvm_info("LENGTH",$sformatf("length generated : MRxD = %b",req.MRxD),UVM_MEDIUM);
     	 		`uvm_info("LENGTH",$sformatf("length generated : MRxD = %b",req.MRxD),UVM_MEDIUM);
       		    finish_item(req);
	            nibble_da_to_payload.push_back(req.MRxD);
		//end
	endtask

	task payload();
			int i;
			int payload_reg ;

			payload_reg = h_config.rxbd[1024+((h_config.tx_bd_num+k)*8)][31:16] ;
$display("payload_reg=%0d",payload_reg);
       		if(payload_reg <= 'd46) begin
				if(h_config.moder[15] == 1) begin
		   		        
					 	for(int i;i<payload_reg*2 ;i++)begin
			
       							start_item(req);

								req.MRxD = $random;
     	 							`uvm_info("PAYLOAD",$sformatf("payload : MRxD = %h",req.MRxD),UVM_MEDIUM);

							finish_item(req);
							nibble_da_to_payload.push_back(req.MRxD);
  						end



						for(int i;i<((46-payload_reg)*2);i++) begin
				
       							start_item(req);

								req.MRxD = 4'h0;
     	 							`uvm_info("PAYLOAD",$sformatf(" - with pad : MRxD = %h",req.MRxD),UVM_MEDIUM);

							finish_item(req);
							nibble_da_to_payload.push_back(req.MRxD);
  						end
				end
				else begin
					for(int i;i<payload_reg*2;i++) begin
				
       						start_item(req);

							req.MRxD = $random;
     	 						`uvm_info("PAYLOAD",$sformatf("payload - no pad : MRxD = %h",req.MRxD),UVM_MEDIUM);

						finish_item(req);
						//	end
						nibble_da_to_payload.push_back(req.MRxD);
  					end

				end
			end
			else if(payload_reg > 'd46 && payload_reg < 'd1500) begin
				for(int i;i<payload_reg*2 ;i++) begin
				
       						start_item(req);

							req.MRxD = i;
     	 						`uvm_info("PAYLOAD",$sformatf("payload > 46 : MRxD = %h",req.MRxD),UVM_MEDIUM);

						finish_item(req);

						nibble_da_to_payload.push_back(req.MRxD);
  				end

			end
	endtask

	task crc();
		int c;

			crc_generation();
     	 		`uvm_info("CRC",$sformatf("crc generated : MRxD = %h",generated_crc),UVM_MEDIUM);
			for(int i;i<8 ;i++)begin
			    	start_item(req);
       					req.MRxD = generated_crc[31-(4*i)-:4] ;
     	 				`uvm_info("CRC",$sformatf("crc generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
       				finish_item(req);
				//c++;
			end
	endtask









//----------------CRC GENERATION TASK---------------------

	task crc_generation();
		bit [3:0] data;
		bit [31:0] crc_variable = 32'hffff_ffff; // initializing the variable
		bit [31:0] crc_next; 
		int nibble_size;
		
		nibble_size = nibble_da_to_payload.size;
	
			for(int i=0;i<nibble_size;i++) 
			begin
			data = nibble_da_to_payload.pop_front;
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

		generated_crc[31:28] = {~crc_variable[28],~crc_variable[29],~crc_variable[30],~crc_variable[31]};
		generated_crc[27:24] = {~crc_variable[24],~crc_variable[25],~crc_variable[26],~crc_variable[27]};
		generated_crc[23:20] = {~crc_variable[20],~crc_variable[21],~crc_variable[22],~crc_variable[23]};
		generated_crc[19:16] = {~crc_variable[16],~crc_variable[17],~crc_variable[18],~crc_variable[19]};
		generated_crc[15:12] = {~crc_variable[12],~crc_variable[13],~crc_variable[14],~crc_variable[15]};
		generated_crc[11:8] = {~crc_variable[8],~crc_variable[9],~crc_variable[10],~crc_variable[11]};
		generated_crc[7:4] = {~crc_variable[4],~crc_variable[5],~crc_variable[6],~crc_variable[7]};
		generated_crc[3:0] = {~crc_variable[0],~crc_variable[1],~crc_variable[2],~crc_variable[3]};
	
	endtask

endclass



//============================================FUNCTION FEATURE TESTCASES=======================================================//

//=============test case rx enable zero configuration=================
class TC_RXEN_0 extends uvm_sequence #(ethernet_seq_item);
	`uvm_object_utils(TC_RXEN_0)
  
  	//--------------------declarations----------------
	config_class h_config;
    int k;
	int nibble_da_to_payload[$];
	bit [31:0] generated_crc ;

	//-------------------object constructor--------------------
 	function new(string name="TC_RXEN_0");
  		super.new(name);
	endfunction
    
	//----------------------task body----------------------
    task body();
		int rxbd_num;
      	req = ethernet_seq_item::type_id::create("req");
   		
	    if(!uvm_config_db #(config_class)::get(null,this.get_full_name(),"config",h_config))
                 `uvm_fatal("MAC SEQUENCE CLASS","CONFIG CLASS NOT FOUND");
		

		wait(h_config.config_done);
		#400;

		rxbd_num = 128 - (h_config.tx_bd_num) ;

		h_config.display();		//----------to display TXBDNUM
		$display("\n \t\t ===========>>rx_bd_num = %d \n \n ",rxbd_num);

		for(int i;i<rxbd_num ;i++)begin
	       		preamble_generation();
			sfd_generation();
    	   		destination_address();
    	   		source_address();
			length_field();
			payload();
			crc();
			frame_gap();
			k++;			//-------
		end
   		     
   endtask
	
	task frame_gap();
		for(int i;i<24;i++)begin
          		start_item(req);
          			req.MRxD = 0;req.MRxDV = 0; req.MCrS = 0;			//-----101010101.....1010
     	 			`uvm_info("PREAMBLE",$sformatf("preamble generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
          		finish_item(req);
        	end

	endtask
   //---------------preamble----------------------
   task preamble_generation();
     	
	int preamble = 4'h5;
	start_item(req);
          	req.MRxD =0 ; req.MRxDV = 0; req.MCrS = 'b0;				//-----101010101.....1010

     	 	`uvm_info("PREAMBLE",$sformatf("preamble generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
     	 	//`uvm_fatal("PREAMBLE","ERRORRRRRRRRRRRRRRRRRRRRRRRRRR");
          finish_item(req);

      	//preamble = 4'h5;

        for(int i;i<14;i++)begin
          start_item(req);
          	req.MRxD = preamble;req.MRxDV = 1; req.MCrS = 1;			//-----101010101.....1010
     	 	`uvm_info("PREAMBLE",$sformatf("preamble generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
          finish_item(req);
        end

   endtask

	task sfd_generation();
	
    	start_item(req);
      		req.MRxD = 4'h5;req.MRxDV = 1;
     	 `uvm_info("SFD",$sformatf("SFD generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
    	finish_item(req);

    	start_item(req);
      		req.MRxD = 4'hd;req.MRxDV = 1;
     	 `uvm_info("SFD",$sformatf("SFD generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
    	finish_item(req);

	endtask
      //-----------destination--------------------------
  
	task destination_address();

		int i=4,j=8;

    	/*for(int i;i< ;i++)(4) begin
			start_item(req);
      			req.MRxD = h_config.mac_addrs1[((4*i)-1) -:4];
     	 `uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);

    		finish_item(req);
			nibble_da_to_payload.push_back(req.MRxD);
			i--;
		end	// comment end
		start_item(req);
      			req.MRxD = 4'hd;
     	 		`uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
    		finish_item(req);
		nibble_da_to_payload.push_back(req.MRxD);
		start_item(req);
      			req.MRxD = 4'hc;
     	 		`uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
    		finish_item(req);
		nibble_da_to_payload.push_back(req.MRxD);		start_item(req);
      			req.MRxD = 4'hb;
     	 		`uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
    		finish_item(req);
		nibble_da_to_payload.push_back(req.MRxD);		start_item(req);
      			req.MRxD = 4'ha;
     	 		`uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
    		finish_item(req);
		nibble_da_to_payload.push_back(req.MRxD);

		for(int i;i<8;i++) begin
	  		start_item(req);
    	  		req.MRxD = h_config.mac_addrs0[((4*j)-1)-:4];
     	 `uvm_info("DESTINATION ADDR",$sformatf("destination addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);

    		finish_item(req);

			nibble_da_to_payload.push_back(req.MRxD);
			j--;
		end

 
 endtask
//----------source address-------------------------------------------
	task source_address();

 		//byte 0 
     		start_item(req);
       			//req.MRxD = {3'd0,h_config.mii_addrs[4]};
			req.MRxD = 4'h0;
     	 `uvm_info("SOURCE ADDR",$sformatf("source addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);

     		finish_item(req);

			nibble_da_to_payload.push_back(req.MRxD);
     		start_item(req);
        		//req.MRxD = h_config.mii_addrs[3:0];
        		req.MRxD = 4'hc;
     	 `uvm_info("SOURCE ADDR",$sformatf("source addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);

     		finish_item(req);

			nibble_da_to_payload.push_back(req.MRxD);
     	//byte1 to 5
     		for(int i;i<10 ;i++)begin
       			start_item(req);
       				req.MRxD = 4'h0;
     	 			`uvm_info("SOURCE ADDR",$sformatf("source addr generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
       			finish_item(req);
			nibble_da_to_payload.push_back(req.MRxD);
     		end
  endtask
//---------------------length-------------------------
	task length_field();
           	int i=0;
		reg [31:0] rxbd_reg;
		rxbd_reg = h_config.rxbd[1024+(h_config.tx_bd_num+k)*8];
		$display("k=%0d  -----------rxbd_reg=%0d adrress [%d]",k,rxbd_reg,1024+(h_config.tx_bd_num+k)*8);
     	 	`uvm_info("RXBD_ADDR",$sformatf(" ===> rxbd_reg = %h",rxbd_reg),UVM_HIGH);
		h_config.display;
		//for(int i;i<4 ;i++)begin
		    start_item(req);
       			//req.MRxD =  rxbd_reg[31-(4*i) -: 4];
       			req.MRxD =  0;
     	 		`uvm_info("LENGTH",$sformatf("length generated : MRxD = %b",req.MRxD),UVM_MEDIUM);
       		    finish_item(req);
	            nibble_da_to_payload.push_back(req.MRxD);
		    start_item(req);
       			//req.MRxD =  rxbd_reg[31-(4*i) -: 4];
       			req.MRxD =  0;
     	 		`uvm_info("LENGTH",$sformatf("length generated : MRxD = %b",req.MRxD),UVM_MEDIUM);
     	 		`uvm_info("LENGTH",$sformatf("length generated : MRxD = %b",req.MRxD),UVM_MEDIUM);
       		    finish_item(req);
	            nibble_da_to_payload.push_back(req.MRxD);
		    start_item(req);
       		//	req.MRxD =  rxbd_reg[31-(4*i) -: 4];
       			req.MRxD =  4'hc;
     	 		`uvm_info("LENGTH",$sformatf("length generated : MRxD = %b",req.MRxD),UVM_MEDIUM);
     	 		`uvm_info("LENGTH",$sformatf("length generated : MRxD = %b",req.MRxD),UVM_MEDIUM);
       		    finish_item(req);
	            nibble_da_to_payload.push_back(req.MRxD);
		    start_item(req);
       			//req.MRxD =  rxbd_reg[31-(4*i) -: 4];
       			req.MRxD =  3;
     	 		`uvm_info("LENGTH",$sformatf("length generated : MRxD = %b",req.MRxD),UVM_MEDIUM);
     	 		`uvm_info("LENGTH",$sformatf("length generated : MRxD = %b",req.MRxD),UVM_MEDIUM);
       		    finish_item(req);
	            nibble_da_to_payload.push_back(req.MRxD);
		//end
	endtask

	task payload();
			int i;
			int payload_reg ;

			payload_reg = h_config.rxbd[1024+((h_config.tx_bd_num+k)*8)][31:16] ;
$display("payload_reg=%0d",payload_reg);
       		if(payload_reg <= 'd46) begin
				if(h_config.moder[15] == 1) begin
		   		        
					 	for(int i;i<payload_reg*2 ;i++)begin
			
       							start_item(req);

								req.MRxD = $random;
     	 							`uvm_info("PAYLOAD",$sformatf("payload : MRxD = %h",req.MRxD),UVM_MEDIUM);

							finish_item(req);
							nibble_da_to_payload.push_back(req.MRxD);
  						end



						for(int i;i<((46-payload_reg)*2);i++) begin
				
       							start_item(req);

								req.MRxD = 4'h0;
     	 							`uvm_info("PAYLOAD",$sformatf(" - with pad : MRxD = %h",req.MRxD),UVM_MEDIUM);

							finish_item(req);
							nibble_da_to_payload.push_back(req.MRxD);
  						end
				end
				else begin
					for(int i;i<payload_reg*2;i++) begin
				
       						start_item(req);

							req.MRxD = $random;
     	 						`uvm_info("PAYLOAD",$sformatf("payload - no pad : MRxD = %h",req.MRxD),UVM_MEDIUM);

						finish_item(req);
						//	end
						nibble_da_to_payload.push_back(req.MRxD);
  					end

				end
			end
			else if(payload_reg > 'd46 && payload_reg < 'd1500) begin
				for(int i;i<payload_reg*2 ;i++) begin
				
       						start_item(req);

							req.MRxD = $random;
     	 						`uvm_info("PAYLOAD",$sformatf("payload > 46 : MRxD = %h",req.MRxD),UVM_MEDIUM);

						finish_item(req);

						nibble_da_to_payload.push_back(req.MRxD);
  				end

			end
	endtask

	task crc();
		int c;

			crc_generation();
     	 		`uvm_info("CRC",$sformatf("crc generated : MRxD = %h",generated_crc),UVM_MEDIUM);
			for(int i;i<8 ;i++)begin
			    	start_item(req);
       					req.MRxD = generated_crc[31-(4*i)-:4] ;
     	 				`uvm_info("CRC",$sformatf("crc generated : MRxD = %h",req.MRxD),UVM_MEDIUM);
       				finish_item(req);
				//c++;
			end
	endtask









//----------------CRC GENERATION TASK---------------------

	task crc_generation();
		bit [3:0] data;
		bit [31:0] crc_variable = 32'hffff_ffff; // initializing the variable
		bit [31:0] crc_next; 
		int nibble_size;
		
		nibble_size = nibble_da_to_payload.size;
	
			for(int i=0;i<nibble_size;i++) 
			begin
			data = nibble_da_to_payload.pop_front;
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

		generated_crc[31:28] = {~crc_variable[28],~crc_variable[29],~crc_variable[30],~crc_variable[31]};
		generated_crc[27:24] = {~crc_variable[24],~crc_variable[25],~crc_variable[26],~crc_variable[27]};
		generated_crc[23:20] = {~crc_variable[20],~crc_variable[21],~crc_variable[22],~crc_variable[23]};
		generated_crc[19:16] = {~crc_variable[16],~crc_variable[17],~crc_variable[18],~crc_variable[19]};
		generated_crc[15:12] = {~crc_variable[12],~crc_variable[13],~crc_variable[14],~crc_variable[15]};
		generated_crc[11:8] = {~crc_variable[8],~crc_variable[9],~crc_variable[10],~crc_variable[11]};
		generated_crc[7:4] = {~crc_variable[4],~crc_variable[5],~crc_variable[6],~crc_variable[7]};
		generated_crc[3:0] = {~crc_variable[0],~crc_variable[1],~crc_variable[2],~crc_variable[3]};
	
	endtask

endclass

*/