class mem_passive_agent extends uvm_agent;

	//=======FACTOR REGISTRATION
	`uvm_component_utils(mem_passive_agent)

	//=======class instances
	mem_monitor	h_mem_monitor;

	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "mem_passive_agent", uvm_component parent);
		super.new(rgstr_name,parent);
	endfunction

	//=======build phase
	function void build_phase (uvm_phase phase);
		super.build_phase(phase);

		//=======MEMORIES FOR CLASS INSTANCES
		h_mem_monitor	= mem_monitor::type_id::create("h_mem_monitor",this);

	endfunction

	//======CONNECT PHASE
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
						
	endfunction

endclass
