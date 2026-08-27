class host_environment extends uvm_env;
	
	//=======FACTOR REGISTRATION
	`uvm_component_utils(host_environment)
	
	//=======class instances
	host_active_agent	h_host_active_agent;
	mem_active_agent	h_mem_active_agent;
	mem_passive_agent	h_mem_passive_agent;

	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "host_environment", uvm_component parent);
		super.new(rgstr_name,parent);
	endfunction

	//=======build phase
	function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		
		h_host_active_agent	= host_active_agent::type_id::create("h_host_active_agent",this);
		h_mem_active_agent	= mem_active_agent::type_id::create("h_mem_active_agent",this);
		h_mem_passive_agent	= mem_passive_agent::type_id::create("h_mem_passive_agent",this);
		
	endfunction

endclass