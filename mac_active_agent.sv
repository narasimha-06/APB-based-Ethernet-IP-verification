class mac_active_agent extends uvm_agent;

	//=======FACTOR REGISTRATION
	`uvm_component_utils(mac_active_agent)

	//=======class instances
	mac_sequencer	h_mac_sequencer;
	mac_driver	h_mac_driver;
	mac_monitor	h_mac_monitor;

	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "mac_active_agent", uvm_component parent);
		super.new(rgstr_name,parent);
	endfunction

	//=======build phase
	function void build_phase (uvm_phase phase);
		super.build_phase(phase);

		//=======MEMORIES FOR CLASS INSTANCES
		h_mac_sequencer	= mac_sequencer::type_id::create("h_mac_sequencer",this);
		h_mac_driver	= mac_driver::type_id::create("h_mac_driver",this);
		h_mac_monitor	= mac_monitor::type_id::create("h_mac_monitor",this);

	endfunction

	//======CONNECT PHASE
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		
		//======DRIVER SEQUENCER PORT CONNECTION
		h_mac_driver.seq_item_port.connect(h_mac_sequencer.seq_item_export);
				
	endfunction

endclass
