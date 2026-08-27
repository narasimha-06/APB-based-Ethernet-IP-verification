class mac_driver extends uvm_driver #(ethernet_seq_item);

	//=======FACTOR REGISTRATION
	`uvm_component_utils(mac_driver)

	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "mac_driver", uvm_component parent);
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
		
		forever @(vif.cb_mac_driver) begin
			
			seq_item_port.get_next_item(req);		//-------getting samples from sequence through seq item.				 
				//req.psel_i = 0;
				//req.MRxDV = 1;
				vif.cb_mac_driver.MRxDV <= req.MRxDV;
				vif.cb_mac_driver.MRxD  <= req.MRxD;
				vif.cb_mac_driver.MRxErr<= req.MRxErr;
				vif.cb_mac_driver.MCrS  <= req.MCrS;

			seq_item_port.item_done();				//----------Acknowledgement
		end

	endtask

endclass