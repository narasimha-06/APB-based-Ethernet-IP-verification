class mem_monitor extends uvm_monitor;

	//=======FACTOR REGISTRATION
	`uvm_component_utils(mem_monitor)

	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "mem_monitor", uvm_component parent);
		super.new(rgstr_name,parent);
	endfunction

	//=======INTERFACE INSTANCE
	virtual ethernet_interface	vif;
	
	//=======ANALYSIS PORT DECLARATION
	uvm_blocking_put_port #(bit[31:0]) mem_put_port;
	
	//=======CONFIG CLASS INSTANCE
	config_class	h_config;

	//=======Sequence item Instance
	ethernet_seq_item	h_seq;
	
	//=======build phase
	function void build_phase (uvm_phase phase);
		super.build_phase(phase);

		//==========ANALYSIS PORT MEMORY CREATION
		mem_put_port	= new("mem_put_port",this);
		
		//========== MEMORY FOR SEQUENCE ITEM
		h_seq	= ethernet_seq_item::type_id::create("h_seq");

		//==========GET VIF
		if(!uvm_config_db #(virtual ethernet_interface)::get(this,"","vif",vif))
			`uvm_fatal("NO VIF","VIRTUAL INTERFACE NOT FOUND !!");
		
		//==========GET CONFIG CLASS
		if(!uvm_config_db#(config_class)::get(this,"","config",h_config))
			`uvm_fatal("NO CONFIG","CONFIG CLASS NOT FOUND !!");

	endfunction
	

	//========Internal declarations
	int count;				// Number of WORDS(32bits) recieved from the DUT.
	int data_length;          		// data_length = payload_check length + pad(if available).
	int data_count;           		// count for received data.
	bit drop_fm;              		// DROP FRAME INDICATION - While Drop frame condition MAC monitor doesn't send any data to scoreboard.
	bit bad_fm;               		// BAD FRAME INDICATION.
	int bad_fmcnt,good_fmcnt; 		// BAD AND GOOD FRAME COUNT.
	bit[31:0] bytes_rxd;			// Stores the PAYLOAD Bytes for sending to the scoreboard.
	byte crc_bytes;				// Count for recieved CRC bytes.
	bit fcs_error;				// USED in CRC TASK 	
	bit[3:0] nibble_crc[$];			// CRC QUEUE
	
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		
		forever@(vif.cb_apb_monitor) begin
			
			h_seq.m_psel_o    = vif.cb_apb_monitor.m_psel_o;
			h_seq.m_penable_o = vif.cb_apb_monitor.m_penable_o;
			h_seq.m_pwrite_o  = vif.cb_apb_monitor.m_pwrite_o;
			h_seq.m_paddr_o   = vif.cb_apb_monitor.m_paddr_o;
			h_seq.m_pwdata_o  = vif.cb_apb_monitor.m_pwdata_o;
			h_seq.prstn_i     = vif.cb_apb_monitor.prstn_i;
			h_seq.m_pready_i  = vif.cb_apb_monitor.m_pready_i;
			h_seq.int_o       = vif.cb_apb_monitor.int_o;

			monitor_check;

		end

	endtask

	task monitor_check;
		
		if(!h_seq.prstn_i) begin	//into check resetting counters ??
			
			count = 0;
			data_length = 0;
			data_count = 0;
			crc_bytes = 0;
			drop_fm = 0;
			bad_fm = 0;
			bytes_rxd = 32'h00;
			bad_fmcnt = 0;
			good_fmcnt = 0;
         		`uvm_info("MEM CHECK RESET", "DESTINATION CHECK", UVM_LOW);					

		end
		else begin
         		
			`uvm_info("MEM CHECK NOT RESET", $sformatf("m_psel_o:%0b, m_penable_o:%0b, m_pready_i:%0b, m_pwrite_o:%0b",h_seq.m_psel_o, h_seq.m_penable_o, h_seq.m_pready_i, h_seq.m_pwrite_o), UVM_HIGH);
					
			if(h_seq.m_psel_o && h_seq.m_penable_o && h_seq.m_pready_i && h_seq.m_pwrite_o) begin	
         			
				
				//---In the access phase only the pwdata is valid.
				count++;
         			`uvm_info("MEM CHECK NOT RESET", $sformatf("\n[%0t]count:%0d,data_length:%0d,data_count:%0d,drop_fm%0d,bad_fm:%0d,bad_fmcnt:%0d,good_fmcnt:%0d,bytes_rxd:%0d,crc_bytes:%0d,fcs_error:%0d,   pwdata:%h\n"
						,$time,count,data_length,data_count,drop_fm,bad_fm,bad_fmcnt,good_fmcnt,bytes_rxd,crc_bytes,fcs_error,h_seq.m_pwdata_o), UVM_HIGH);
				`uvm_info("MEM VALID DATA", $sformatf("\nVALIDD DATA: %h, count value:%d",h_seq.m_pwdata_o,count), UVM_HIGH);						
				frame_check;
				
			end
			
		end

	endtask

	task frame_check;
		
		if(count == 1) begin
			dst_addrs;												//----Destination Address Check
         		`uvm_info("MEMMMMMMMMCHECK", "DESTINATION CHECK", UVM_HIGH);		
		end
		
		if(!drop_fm) begin
			
			
			if(count<5||data_count<data_length) begin								//COUNT<5 IS FOR PUSHING UPTO LENGTH FIELD AND THE OTHER CONDITION FOR PUSHING ONLY PAYLOAD
				push_bytes(4);
			end

			
			if(count == 2) begin											// DESTINATION AND SOURCE (2+2) BYTES CHECK
				dst_src; 
         			`uvm_info("MEMCHECK1", "DESTINATION_SRC CHECK", UVM_HIGH);		
			end
		
			if(count == 3) begin											// SOURCE ADDRESS CHECK ONLY
				src_addrs;
         			`uvm_info("MEMCHECK2", "SRC CHECK", UVM_HIGH);		
			end

			if(count == 4) begin											// LENGTH CHECK AND STORE TWO BYTES OF PAYLOAD
				length_check;
         			`uvm_info("MEMCHECK3", "LENGTH CHECK", UVM_HIGH);
			end
		
			if(count > 4) begin
				if(data_count < data_length) begin								// COLLECT PAYLOAD AND SEND IT TO SCOREBOARD
					payload_check;
         				`uvm_info("MEMCHECK4", "PAYLOAD CHECK", UVM_HIGH);		
				end
				else begin
					pay_crc;										// COLLECT CRC AND INVOKE THE CRC_CRC TASK
         				`uvm_info("MEMCHECK5", "CRC CHECK", UVM_HIGH);		
				end
			end
		end
		else begin
			frame_drop;
         		`uvm_info("MEMCHECK_DROP_FRAME", "DROP_FRAME", UVM_HIGH);		
		end

	endtask
	
	
	task dst_addrs;
		
		//The destination address is checked based on the pro and bro condition.
		//MISS MATCH, THEN THE FRAME IS DROPPED.

		//MODER[5] -> PRO
		if(h_config.moder[5] == 1) begin	
			//---DESTINATION ADDRESS IS NOT CHECKED
			drop_fm = 0;
		end
		else begin
		
			//MODER[3] -> BRO
			if(h_config.moder[3] == 0) begin	
				
				//DA check with MAC ADDR AND BRDCST ADDRS
				if(da_check() || brdcst_check1()) begin
					drop_fm = 0;
				end
				else begin
					drop_fm = 1;
				end

			end
			else begin
				
				//DA check with MAC ADDR
				if(da_check()) begin
					drop_fm = 0;
				end
				else begin
					drop_fm = 1;
				end
	
			end
		end

	endtask
		
	task dst_src;
		
		//The destination address is checked based on the pro and bro condition and source address is checked with MII ADDRS/
		//MISS MATCH, THEN IT IS A BAD FRAME.
		
		if(h_config.moder[5] == 1) begin

			//---DESTINATION ADDRESS IS NOT CHECKED BUT SOURCE IS CHECKED
			if(h_seq.m_pwdata_o[15-:16] == {3'b000,h_config.mii_addrs[4:0],8'h00}) begin
				bad_fm = 0;
			end
			else begin
				bad_fm = 1;
			end

		end
		else begin
			
			if(h_config.moder[3] == 0) begin
				
				//DA check with MAC ADDR AND BRDCST ADDRS
				if(ds_check() || brdcst_check2()) begin
					bad_fm = 0;
				end
				else begin
					bad_fm = 1;
				end
	
			end
			else begin
			
				//DA check with MAC ADDR
				if(ds_check()) begin
					bad_fm = 0;
				end
				else begin
					bad_fm = 1;
				end

			end
		end
	endtask

	function bit da_check;
		
		if(h_seq.m_pwdata_o == { {<<4{h_config.mac_addrs1[15-:8]}},{<<4{h_config.mac_addrs1[7-:8]}},{<<4{h_config.mac_addrs0[31-:8]}},{<<4{h_config.mac_addrs0[23-:8]}} }) begin
														//{<<4{MAC_ADDR1[15:8]}} -> streaming opeartor with 4bit slice reversal that gives nibble swapping. 
														//{<<{MAC_ADDR1[15:8]}} -> streaming opeartor that reverses all the bits. 
			return 1;
		end

		return 0;

	endfunction
	
	function bit brdcst_check1;

		if(h_seq.m_pwdata_o == 32'hFFFF_FFFF) begin
			return 1;
		end
		
		return 0;

	endfunction
	
	function bit ds_check;
		
		if(h_seq.m_pwdata_o == {{<<4{h_config.mac_addrs0[15-:8]}},{<<4{h_config.mac_addrs0[7-:8]}},h_config.mii_addrs[3:0],12'h0000}) begin
			return 1;
		end

		return 0;

	endfunction
	
	function bit brdcst_check2;

		if(h_seq.m_pwdata_o == {16'hFFFF,3'b000,h_config.mii_addrs[4:0],8'h00}) begin
			return 1;
		end
		
		return 0;

	endfunction


	task src_addrs;
		
		//SOURCE ADDRS IS CHECKED WITH THE MII ADDRS
		if(h_seq.m_pwdata_o != 32'h0000_0000) begin
			bad_fm = 1;
		end

	endtask

	task length_check;
		
		if(h_seq.m_pwdata_o[31-:16] < 46) begin								//IF ADDRS IS LESS THAN 46BYTES CHECK FOR PAD BIT. 
			
			if(h_config.moder[15]) begin								//IF PAD IS ENABLED THEN SET FRAME LENGTH AS 46 ELSE SET LENGTH MENTIONED IN BD AND MAKE IT BAD FRAME.
				data_length = 46;
			end
			else if(!h_config.moder[15]) begin
				data_length = h_config.present_bd[31:16];			
				//data_length = h_seq.m_pwdata_o[31-:16];
				bad_fm = 1;				
			end

		end
		else if(h_seq.m_pwdata_o[31-:16] > 1500) begin							//IF ADDRS IS GREATER THAN 1500BYTES CHECK FOR HUGEN BIT.			
			if(h_config.moder[14]) begin								//IF HUGEN IS SET THEN CONSIDER ELSE MAKE IT A BAD FRAME.
				//data_length = h_config.present_bd[31:16];			
				data_length = h_seq.m_pwdata_o[31-:16];	
			end
			else if(!h_config.moder[14]) begin
				data_length = h_config.present_bd[31:16];			
				//data_length = h_seq.m_pwdata_o[31-:16];
				bad_fm = 1;				
			end

		end
		else if(h_seq.m_pwdata_o[31-:16] > 2047) begin							//IF ADDRS IS GREATER THAN 2047BYTES MAKE IT A BAD FRAME.
			data_length = h_config.present_bd[31:16];			
			//data_length = h_seq.m_pwdata_o[31-:16];	
			bad_fm = 1;
		end
		else begin											//IF ADDRS IS GREATER THAN 46 BYTES AND LESS THAN 1500 BYTES THEN STORE THE FRAME LENGTH.
			//data_length = h_seq.m_pwdata_o[31-:16];		
			data_length = h_config.present_bd[31:16];			
		end

								
		bytes_rxd = {bytes_rxd[15-:16],h_seq.m_pwdata_o[15-:16]};					//WITH THE LENGTH FIELD 2 BYTES OF PAYLOAD IS SENT, STORE THEM IN THE BYTES_RXD AND SET DATA_COUNT TO 2.
		data_count = 2;


	endtask

	task payload_check;
		
		byte curr_byte;											//TO STORE EACH BYTE INTO BYTES_RXD CURR_BYTE IS USED. 

		for(int i=0;i<4;i++) begin

			curr_byte = h_seq.m_pwdata_o[31-8*i -:8];						//SLICE THE REQUIRED BYTE FROM THE DUT OUTPUT AND STORE IT IN CURR_BYTE.

			// PAYLOAD REGION
			if(data_count < data_length) begin							//UNTILL COMPLETE PAYLOAD IS RECIEVED, THIS CONDITION WILL PASS

    				bytes_rxd = {bytes_rxd[23:0], curr_byte};					//SHIFT THE BYTES AND STORE THE CURRENT BYTE AND INCREMENT DATA_COUNT
    				data_count++;

	    			if( data_count %4 == 0) begin							// IF BYTES_RXD IS COMPLETELY FILLED SEND IT TO SCOREBOARD AND CLEAR THE BYTES_RXD.
					bytes_rxd = re_arrange(bytes_rxd);
					//$display($time,"\t mem monitor (line 350) %h",bytes_rxd);
	        			mem_put_port.put(bytes_rxd);
	        			bytes_rxd = 0;
    				end
				else if(data_count == data_length) begin					
					while(data_count % 4 != 0) begin					//WHEN THE COMPLETE PAYLOAD IS RECIEVED AND THE BYTES_RXD IS NOT FILLED
						bytes_rxd = {bytes_rxd[23:0],8'h00};				//THEN APPEND ZEROS TO THE BYTES_RXD AND SEND IT TO SCCOREBOARD
						data_count++;
					end
					bytes_rxd = re_arrange(bytes_rxd);
					mem_put_port.put(bytes_rxd);
				end
  			end
 			
			// CRC REGION
  			else if(crc_bytes < 4) begin								//INCREMENT THE CRC COUNTER
      				crc_bytes++;
  			end

		end

	endtask

	

	task pay_crc;
		
		push_bytes(4-crc_bytes);									//BASED ON THE PREVIOUSLY RECIEVED CRC_BYTES,
														//THE NO.OF CRC BYTES TO BE STORED IS CHECKED AND PUSHED INTO THE (NIBBLE_CRC)QUEUE.

		crc_check();											//CRC_CHECK TASK IS INVOKED FOR CRC CHECKING

		crc_bytes = 0;											//INITIALIZE ALL THE INTERNAL VARIABLES TO THIER DEFAULT VALUES
		data_count = 0;
		data_length = 0;
		count = 0;
		bytes_rxd = 32'h0000_0000;
		
		if(bad_fm || fcs_error ) begin
			bad_fmcnt++;
			bad_fm = 0;
			fcs_error = 0;
		end
		else begin
			good_fmcnt++;
		end
		`uvm_info("[MEM_MONITOR]",$sformatf("\n\t\t\t\t\t\t========================>GOOD FRAME COUNT:%0d, BAD FRAME COUNT:%0d, TOTAL FRAMES:%0d<======================== ",good_fmcnt,bad_fmcnt,good_fmcnt+bad_fmcnt),UVM_NONE);
	endtask

	task frame_drop;
		if(count == 4) begin
			if(h_seq.m_pwdata_o < 46) begin
				data_length = 50;								//46(MINFL) + 4(CRC)
			end
			else begin
				data_length = h_seq.m_pwdata_o[31-:16] + 4;
			end
			data_count = 2;
		end
		if(count > 4 && data_count < data_length) begin
			data_count += 4;
		end
		else if(count > 4 && data_count >= data_length)begin
			drop_fm 	= 0;
			data_count 	= 0;
			data_length 	= 0;
			count 		= 0;
			bad_fm 		= 0;
		end
	endtask
	
	//==========================CRC CHECK=========================================
	task crc_check();
		bit [3:0] data;
		bit [31:0] crc_variable = 32'hffff_ffff; // initializing the variable
		bit [31:0] crc_next; 
		bit [31:0] calculated_magic_number;
		int nibble_size;
		
		nibble_size = nibble_crc.size;
			$display("[MEM_MONITOR] CRC QUEUE=%p",nibble_crc);
			for(int i=0;i<nibble_size;i++) 
			begin
			data = nibble_crc.pop_front;
			data = {<<{data}}; 

			crc_next[0]  =    (data[0] ^ crc_variable[28]); 
			crc_next[1]  =    (data[1] ^ data[0] ^ crc_variable[28] ^ crc_variable[29]); 
			crc_next[2]  =    (data[2] ^ data[1] ^ data[0] ^ crc_variable[28] ^ crc_variable[29] ^ crc_variable[30]); 
			crc_next[3]  =    (data[3] ^ data[2] ^ data[1] ^ crc_variable[29] ^ crc_variable[30] ^ crc_variable[31]); 
			crc_next[4]  =    (data[3] ^ data[2] ^ data[0] ^ crc_variable[28] ^ crc_variable[30] ^ crc_variable[31]) ^ crc_variable[0]; 
			crc_next[5]  =    (data[3] ^ data[1] ^ data[0] ^ crc_variable[28] ^ crc_variable[29] ^ crc_variable[31]) ^ crc_variable[1]; 
			crc_next[6]  =    (data[2] ^ data[1] ^ crc_variable[29] ^ crc_variable[30]) ^ crc_variable[2]; 
			crc_next[7]  =    (data[3] ^ data[2] ^ data[0] ^ crc_variable[28] ^ crc_variable[30] ^ crc_variable[31]) ^ crc_variable[3]; 
			crc_next[8]  =    (data[3] ^ data[1] ^ data[0] ^ crc_variable[28] ^ crc_variable[29] ^ crc_variable[31]) ^ crc_variable[4]; 
			crc_next[9]  =    (data[2] ^ data[1] ^ crc_variable[29] ^ crc_variable[30]) ^ crc_variable[5]; 
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
				$display("calculated_magic_number=%h",calculated_magic_number);	
		if(calculated_magic_number != 32'hc704dd7b)begin
			fcs_error =1;
			`uvm_error("MEM_MON",$sformatf("*********************CRC check Fail ******************"))
		end else begin
			fcs_error =0;
			$display("PASSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS");
		end
	
	endtask
	
	function push_bytes(int bytes);
		
		for (int i = 3; i >= (4-bytes); i--) begin
    			nibble_crc.push_back( h_seq.m_pwdata_o[(i*8) +: 4] ); // bits 3:0, 11:8, etc.
    			nibble_crc.push_back( h_seq.m_pwdata_o[(i*8+4) +: 4] ); // bits 7:4, 15:12, etc.
		end
		
	endfunction
	
	function int re_arrange(int dataa);
		return { {<<4{dataa[31-:8]}}, {<<4{dataa[23-:8]}}, {<<4{dataa[15-:8]}}, {<<4{dataa[7-:8]}}};
	endfunction
	
endclass
