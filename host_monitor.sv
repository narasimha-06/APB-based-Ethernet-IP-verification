class host_monitor extends uvm_monitor;

	//===================FACTORY REGISTRATION===================
	`uvm_component_utils(host_monitor);

	//===================INSTANCES===================	
	virtual	 ethernet_interface 	vif;
	ethernet_seq_item 				h_seq_item;	
	config_class 					h_config;


	//===================INTERNAL SIGNALS===================
	bit config_moder_done;
	bit config_int_source_done;
	bit config_int_mask_done;	
	bit config_tx_bd_num_done;
	bit config_mii_addrs_done;
	bit config_mac_addr0_done;
	bit config_mac_addr1_done;
	bit config_rx_bd_done;

	bit config_done;

	int i;					//USED FOR ITERATING OVER BD's

	
	//===================CONSTRUCTOR===================
	function new(string name="host_monitor",uvm_component base);
		super.new(name,base);
	endfunction
	
	//===================BUILD PHASE===================
	function void build_phase(uvm_phase phase);

				super.build_phase(phase);
				h_seq_item=new();

				if(!uvm_config_db#(virtual ethernet_interface)::get(this,"this.get_full_name","vif",vif))

				`uvm_fatal("INTF","getting interface failed")

				if(!uvm_config_db#(config_class)::get(this,"this.get_full_name","config",h_config))

				`uvm_fatal("CFG","getting configclass failed")

	endfunction

	//===================RUN PHASE===================		
	task run_phase(uvm_phase phase);

		super.run_phase(phase);

		forever  @(vif.cb_host_monitor) begin


			h_seq_item.prstn_i  	= vif.cb_host_monitor.prstn_i;
			h_seq_item.psel_i 	= vif.cb_host_monitor.psel_i;
			h_seq_item.penable_i	= vif.cb_host_monitor.penable_i;
			h_seq_item.pwrite_i	= vif.cb_host_monitor.pwrite_i;
			h_seq_item.paddr_i  	= vif.cb_host_monitor.paddr_i;
			h_seq_item.pwdata_i  	= vif.cb_host_monitor.pwdata_i;
			h_seq_item.pready_o 	= vif.cb_host_monitor.pready_o;
			h_seq_item.prdata_o  	= vif.cb_host_monitor.prdata_o;

			host_monitor_check;

		end

	endtask



	task host_monitor_check;
			
		if(h_seq_item.prstn_i==0) begin		
			
			//..DEFAULT registers values
			h_config.moder        = 32'h0000_A000;
			h_config.int_source   = 32'h0000_0000;
			h_config.int_mask     = 32'h0000_0000;
			h_config.tx_bd_num    = 32'h0000_0040;
			h_config.mii_addrs    = 32'h0000_0000;
			h_config.mac_addrs0   = 32'h0000_0000;
			h_config.mac_addrs1   = 32'h0000_0000;

			config_moder_done		= 1'b0;
		 	config_int_source_done		= 1'b0;
			config_int_mask_done		= 1'b0;	
			config_tx_bd_num_done		= 1'b0;
			config_mii_addrs_done		= 1'b0;
			config_mac_addr0_done		= 1'b0;
			config_mac_addr1_done		= 1'b0;
			config_rx_bd_done		= 1'b0;

			config_done			= 1'b0;

		end
		else begin
			if(h_seq_item.prstn_i && h_seq_item.psel_i && h_seq_item.penable_i && h_seq_item.pready_o && h_seq_item.pwrite_i) begin
				
				//===================>>MODER CONFIGURATION<<====================
				if(h_seq_item.paddr_i==32'h0000_0000) begin
					
					`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO MODER"),UVM_HIGH);			
					h_config.moder = h_seq_item.pwdata_i;
					config_moder_done=1;

				end
				//================>>INT_SOURCE CONFIGURATION<<==================
				if(h_seq_item.paddr_i==32'h0000_0004) begin
					
					`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO INT_SOURCE"),UVM_HIGH);	
					h_config.int_source = h_seq_item.pwdata_i;
					config_int_source_done=1;
				
				end
				//================>>INT_MASK CONFIGURATION<<====================
				if(h_seq_item.paddr_i==32'h0000_0008) begin
					
					`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO INT_MASK"),UVM_HIGH);							
					h_config.int_mask = h_seq_item.pwdata_i;
					config_int_mask_done=1;
				end
				//===============>>TX_BD_NUM CONFIGURATION<<====================
				if(h_seq_item.paddr_i==32'h0000_0020) begin
					
					`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO TXBD_NUM"),UVM_HIGH);
					//if(h_seq_item.pwdata_i <= 128) begin
						h_config.tx_bd_num = h_seq_item.pwdata_i;
						config_tx_bd_num_done=1;						
					//end
					//else begin
					//	`uvm_warning("HOST MONITOR","BUFFER DESCRIPTORS GREATER THAN 128...IGNORING");
					//end
				
				end
				//===================>>MIIADDRS CONFIGURATION<<====================
				if(h_seq_item.paddr_i==32'h0000_0030) begin
					
					`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO MIIADDRS "),UVM_HIGH);			
					h_config.mii_addrs = h_seq_item.pwdata_i;
					config_mii_addrs_done=1;

				end
				//===================>>MACADDR0 CONFIGURATION<<====================
				if(h_seq_item.paddr_i==32'h0000_0040) begin
					
					`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO MACADDR0"),UVM_HIGH);							
					h_config.mac_addrs0 = h_seq_item.pwdata_i;
					config_mac_addr0_done=1;
				
				end
				//===================>>MACADDR1 CONFIGURATION<<====================
				if(h_seq_item.paddr_i==32'h0000_0044) begin
					
					`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO MACADDR1"),UVM_HIGH);							
					h_config.mac_addrs1 = h_seq_item.pwdata_i;
					config_mac_addr1_done=1;

				end
				//===================>>RXBD CONFIGURATION<<====================
				if(h_seq_item.paddr_i==(1024+(h_config.tx_bd_num + i)*8)) begin
					
					`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO RX_BD "),UVM_HIGH);			
					//$display($time,"[HOST MONITOR]******************************************, addr: %0d pwdata: %0d",h_seq_item.paddr_i,h_seq_item.pwdata_i);
					
					h_config.rxbd[1024+(h_config.tx_bd_num + i)*8] = h_seq_item.pwdata_i;
					//h_config.display();		//-->>DISPLAYS BD'S IN CONFIG CLASS
				end

				if(h_seq_item.paddr_i==(1028+(h_config.tx_bd_num + i)*8)) begin
					
					`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO RX_BD "),UVM_HIGH);			
					//$display($time,"[HOST MONITOR]******************************************, addr: %0d pwdata: %0d",h_seq_item.paddr_i,h_seq_item.pwdata_i);
					
					h_config.rxbd[1028+(h_config.tx_bd_num + i)*8] = h_seq_item.pwdata_i;
					//h_config.display();
					i++;
					
					`uvm_info("HOST MONITOR",$sformatf("WRITINGGGGGGGGGGGGGGGGGGGGGGGGGGG"),UVM_HIGH);
					if(h_config.tx_bd_num + i == 128) begin
						config_rx_bd_done = 1;
					end
				end

			end 

		end
		
		if(config_moder_done && config_int_source_done && config_int_mask_done && config_tx_bd_num_done && config_mii_addrs_done &&  config_mac_addr0_done && config_mac_addr1_done && config_rx_bd_done)begin
			`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO config done "),UVM_HIGH);			
			config_done=1; 
		end 

		h_config.config_done = config_done;


	endtask

endclass

/*	// WORKING CODEEE ____ TX BD NUM PWRITE CHECK
task host_monitor_check;

			if(h_seq_item.prstn_i==0) begin																					
				//..DEFAULT registers values
				h_config.moder        = 32'h0000_A000;
				h_config.int_source   = 32'h0000_0000;
				h_config.int_mask     = 32'h0000_0000;
				h_config.tx_bd_num    = 32'h0000_0040;
				h_config.mii_addrs    = 32'h0000_0000;
				h_config.mac_addrs0   = 32'h0000_0000;
				h_config.mac_addrs1   = 32'h0000_0000;

				config_moder_done		= 1'b0;
			 	config_int_source_done		= 1'b0;
				config_int_mask_done		= 1'b0;	
				config_tx_bd_num_done		= 1'b0;
				config_mii_addrs_done		= 1'b0;
				config_mac_addr0_done		= 1'b0;
				config_mac_addr1_done		= 1'b0;
				config_rx_bd_done		= 1'b0;

				config_done			= 1'b0;

			end	

			if(h_seq_item.prstn_i && h_seq_item.psel_i && h_seq_item.penable_i && h_seq_item.pready_o && h_seq_item.paddr_i==32'h0000_0000 && h_seq_item.pwrite_i)
			begin
			//...MODER reg configuration update
						
						`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO MODER"),UVM_HIGH);			
						h_config.moder = h_seq_item.pwdata_i;
						config_moder_done=1;
			end 					

			if(h_seq_item.prstn_i && h_seq_item.psel_i && h_seq_item.penable_i && h_seq_item.pready_o && h_seq_item.paddr_i==32'h0000_0004&& h_seq_item.pwrite_i)
			begin
			//...INT_SOURCE reg configuration update
						`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO INT_SOURCE"),UVM_HIGH);			
				
						h_config.int_source = h_seq_item.pwdata_i;
						config_int_source_done=1;
			end 		
			if(h_seq_item.prstn_i && h_seq_item.psel_i && h_seq_item.penable_i && h_seq_item.pready_o && h_seq_item.paddr_i==32'h0000_0008&& h_seq_item.pwrite_i)
			begin
			//...INT_MASK reg configuration update
						`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO INT_MASK"),UVM_HIGH);			
				
						h_config.int_mask = h_seq_item.pwdata_i;
						config_int_mask_done=1;
			end

			if(h_seq_item.prstn_i && h_seq_item.psel_i && h_seq_item.penable_i && h_seq_item.pready_o && h_seq_item.paddr_i==32'h0000_0020&& h_seq_item.pwrite_i)
			begin
			//...TXBD_NUM reg configuration update
						`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO TXBD_NUM"),UVM_HIGH);			
				
						h_config.tx_bd_num = h_seq_item.pwdata_i;
						config_tx_bd_num_done=1;
			end 
	
			if(h_seq_item.prstn_i && h_seq_item.psel_i && h_seq_item.penable_i && h_seq_item.pready_o && h_seq_item.paddr_i==32'h0000_0030&& h_seq_item.pwrite_i)
			begin
			//...MIIADDRS reg configuration update
						`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO MIIADDRS "),UVM_HIGH);			
				
						h_config.mii_addrs = h_seq_item.pwdata_i;
						config_mii_addrs_done=1;
			end 
	
 			if(h_seq_item.prstn_i && h_seq_item.psel_i && h_seq_item.penable_i && h_seq_item.pready_o && h_seq_item.paddr_i==32'h0000_0040&& h_seq_item.pwrite_i)
			begin
			//...MACADDR0 reg configuration update
						`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO MACADDR0"),UVM_HIGH);			
				
						h_config.mac_addrs0 = h_seq_item.pwdata_i;
						config_mac_addr0_done=1;
			end

			if(h_seq_item.prstn_i && h_seq_item.psel_i && h_seq_item.penable_i && h_seq_item.pready_o && h_seq_item.paddr_i==32'h0000_0044&& h_seq_item.pwrite_i)
			begin
			//...MACADDR1 reg configuration update
						`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO MACADDR1"),UVM_HIGH);			
				
						h_config.mac_addrs1 = h_seq_item.pwdata_i;
						config_mac_addr1_done=1;
			end 

			//for(int i ; i < (128 - h_config.tx_bd_num) ; 
			begin

			if(h_seq_item.prstn_i && h_seq_item.psel_i && h_seq_item.penable_i && h_seq_item.pready_o && h_seq_item.paddr_i==(1024+(h_config.tx_bd_num + i)*8)&& h_seq_item.pwrite_i)

					begin
			//...RX_BD reg configuration update
						`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO RX_BD "),UVM_HIGH);			
						
						//$display($time,"[HOST MONITOR]******************************************, addr: %0d pwdata: %0d",h_seq_item.paddr_i,h_seq_item.pwdata_i);
						h_config.rxbd[1024+(h_config.tx_bd_num + i)*8] = h_seq_item.pwdata_i;
						h_config.display();
						
						i++;
						`uvm_info("HOST MONITOR",$sformatf("WRITINGGGGGGGGGGGGGGGGGGGGGGGGGGG"),UVM_HIGH);
						//$display($time,"\t =============>> rxbd[%0h] = %0d",h_seq_item.paddr_i,h_seq_item.pwdata_i);
					end
	
			end 

					config_rx_bd_done = 1 ;			

			if(config_moder_done && config_int_source_done && config_int_mask_done && config_tx_bd_num_done && config_mii_addrs_done &&  config_mac_addr0_done && config_mac_addr1_done && config_rx_bd_done)
			begin
						`uvm_info("HOST MONITOR",$sformatf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO config done "),UVM_HIGH);			
			
						config_done=1; 
			end 

			h_config.config_done = config_done;
		
	endtask
*/

/*class host_monitor extends uvm_monitor;

	//=======FACTOR REGISTRATION
	`uvm_component_utils(host_monitor)

	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "host_monitor", uvm_component parent);
		super.new(rgstr_name,parent);
	endfunction

	//=======INTERFACE INSTANCE
	virtual ethernet_interface	vif;
	
	//=======CONFIG CLASS INSTANCE
	config_class	h_config;

	//=======connect phase
	function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		
		//==========GET VIF
		if(!uvm_config_db #(virtual ethernet_interface)::get(this,"","vif",vif))
			`uvm_fatal("NO VIF","VIRTUAL INTERFACE NOT FOUND !!");
		
		//==========GET CONFIG CLASS
		if(!uvm_config_db#(config_class)::get(this,"","config",h_config))
			`uvm_fatal("NO CONFIG","CONFIG CLASS NOT FOUND !!");

	endfunction
	
	task run_phase(uvm_phase phase);
		super.run_phase(phase);

	endtask

endclass*/		