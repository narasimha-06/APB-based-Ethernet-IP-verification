class host_active_agent extends uvm_agent;

	//=======FACTOR REGISTRATION
	`uvm_component_utils(host_active_agent)

	//=======class instances
	host_sequencer	h_host_sequencer;
	host_driver	h_host_driver;
	host_monitor	h_host_monitor;

	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "host_active_agent", uvm_component parent);
		super.new(rgstr_name,parent);
	endfunction

	//=======build phase
	function void build_phase (uvm_phase phase);
		super.build_phase(phase);

		//=======MEMORIES FOR CLASS INSTANCES
		h_host_sequencer	= host_sequencer::type_id::create("h_host_sequencer",this);
		h_host_driver		= host_driver::type_id::create("h_host_driver",this);
		h_host_monitor		= host_monitor::type_id::create("h_host_monitor",this);

	endfunction

	//======CONNECT PHASE
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		
		//======DRIVER SEQUENCER PORT CONNECTION
		h_host_driver.seq_item_port.connect(h_host_sequencer.seq_item_export);
				
	endfunction

endclass
