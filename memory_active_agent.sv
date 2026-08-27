class mem_active_agent extends uvm_agent;

	//=======FACTOR REGISTRATION
	`uvm_component_utils(mem_active_agent)

	//=======class instances
	mem_sequencer	h_mem_sequencer;
	mem_driver	h_mem_driver;

	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "mem_active_agent", uvm_component parent);
		super.new(rgstr_name,parent);
	endfunction

	//=======build phase
	function void build_phase (uvm_phase phase);
		super.build_phase(phase);

		//=======MEMORIES FOR CLASS INSTANCES
		h_mem_sequencer	= mem_sequencer::type_id::create("h_mem_sequencer",this);
		h_mem_driver	= mem_driver::type_id::create("h_mem_driver",this);

	endfunction

	//======CONNECT PHASE
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		
		//======DRIVER SEQUENCER PORT CONNECTION
		h_mem_driver.seq_item_port.connect(h_mem_sequencer.seq_item_export);
				
	endfunction

endclass
