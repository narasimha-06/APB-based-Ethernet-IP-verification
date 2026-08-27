class mem_driver extends uvm_driver#(ethernet_seq_item);

	//=======FACTOR REGISTRATION
	`uvm_component_utils(mem_driver)

	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "mem_driver", uvm_component parent);
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
		
		forever @(vif.cb_mem_driver) begin
			
			if(vif.m_psel_o && vif.m_penable_o && vif.m_pwrite_o) begin
				
				seq_item_port.get_next_item(req);		//-------getting samples from sequence through seq item.				 
					
					vif.cb_mem_driver.m_pready_i <= req.m_pready_i;
				
				seq_item_port.item_done();				//----------Acknowledgement
			
			end
			else begin
				vif.cb_mem_driver.m_pready_i <= 1'b0;
			end
		end

	endtask


endclass