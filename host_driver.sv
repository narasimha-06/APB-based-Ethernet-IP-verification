class host_driver extends uvm_driver#(ethernet_seq_item);

	//=======FACTOR REGISTRATION
	`uvm_component_utils(host_driver)

	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "host_driver", uvm_component parent);
		super.new(rgstr_name,parent);
	endfunction
	
	//=======INTERFACE INSTANCE
	virtual ethernet_interface	vif;

	//=======build phase
	function void build_phase (uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db #(virtual ethernet_interface)::get(this,"","vif",vif))
			`uvm_fatal("NO VIF","VIRTUAL INTERFACE NOT FOUND !!");
		
	endfunction
	
	//=======run phase
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever @(vif.cb_host_driver) begin
			
			seq_item_port.get_next_item(req);		//=======getting samples from sequence through seq item.				 
				
				if(!req.prstn_i) begin
					reset_signals;
				end
				else begin
					
					if(req.psel_i) begin
						
						//================ SETUP ================
	   					host_apb_setup;
 					
						//================ ACCESS ================
	        			 	@(vif.cb_host_driver);
						host_apb_access;
	 				
						// ============================= WAIT FOR READY ================
						if(req.prstn_i && req.psel_i && req.penable_i) begin
							`uvm_info("HOST DRIVER",$sformatf("WAITINGGGGGGGGGGGGGGGGGGGGGGGGGGG"),UVM_HIGH);
							/*if(req.paddr_i inside {[32'h400:32'h7FF]}) begin
								wait(vif.pready_o);
								@(vif.cb_host_driver);
							end
							else begin
								@(vif.pready_o);
							end*/
							//wait(vif.pready_o);
							//@(vif.pready_o);
		        			 	wait(vif.cb_host_driver.pready_o);			//IN RXBD BY SEEING the ready, the next signals are driving, 
													//as enable is zero for the next transaction the pready is getting deasseted as a glitch
						end
		
					end
					else begin
    						vif.cb_host_driver.penable_i	<= 1'b0;
				    		vif.cb_host_driver.psel_i   	<= 1'b0;
					end
					
					/*host_apb_setup;
					@(vif.cb_host_driver);
					host_apb_access;
					while(!vif.pready_o)begin
						@(posedge vif.cb_host_driver);
					end
					//wait(vif.cb_host_driver.pready_o);*/

				
				end
			seq_item_port.item_done();				//==========Acknowledgement
		end

	endtask

	task reset_signals;
		
		vif.cb_host_driver.prstn_i	<= req.prstn_i;
    		vif.cb_host_driver.psel_i   	<= req.psel_i;
    		vif.cb_host_driver.penable_i	<= req.penable_i;
    		vif.cb_host_driver.paddr_i   	<= req.paddr_i;
    		vif.cb_host_driver.pwrite_i  	<= req.pwrite_i;
		vif.cb_host_driver.pwdata_i  	<= req.pwdata_i;

	endtask

	task host_apb_setup;
          	req.psel_i=1;
		req.penable_i=0;  
                     
		vif.cb_host_driver.prstn_i	<= req.prstn_i;
    		vif.cb_host_driver.psel_i   	<= req.psel_i;
    		vif.cb_host_driver.penable_i	<= req.penable_i;
    		vif.cb_host_driver.paddr_i   	<= req.paddr_i;
    		vif.cb_host_driver.pwrite_i  	<= req.pwrite_i;
		vif.cb_host_driver.pwdata_i  	<= req.pwdata_i;
			
		`uvm_info("\t[HOST DRIVER SETUP]",$sformatf(" \tprstn_i= %0d \t PSELx = %0d \t PADDR = %0d \t PENABLE = %0d \t PWRITE = %0d \t PWDATA = %0d \t "
									,req.prstn_i , req.psel_i, req.paddr_i ,req.penable_i ,req.pwrite_i ,req.pwdata_i ),UVM_NONE);
	endtask

	task host_apb_access;

		req.penable_i = 1;

                vif.cb_host_driver.prstn_i	<= req.prstn_i;
    		vif.cb_host_driver.psel_i   	<= req.psel_i;
    		vif.cb_host_driver.penable_i	<= req.penable_i;
    		vif.cb_host_driver.paddr_i   	<= req.paddr_i;
    		vif.cb_host_driver.pwrite_i  	<= req.pwrite_i;
		vif.cb_host_driver.pwdata_i  	<= req.pwdata_i;
          	
		`uvm_info("\t[HOST DRIVER ACCESS]",$sformatf(" \tprstn_i= %0d \t PSELx = %0d \t PADDR = %0d \t PENABLE = %0d \t PWRITE = %0d \t PWDATA = %0d \t "
												,req.prstn_i , req.psel_i, req.paddr_i ,req.penable_i ,req.pwrite_i ,req.pwdata_i ),UVM_NONE);
	endtask

endclass