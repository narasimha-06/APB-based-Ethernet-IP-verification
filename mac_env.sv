class mac_environment extends uvm_env;
	
	//=======FACTOR REGISTRATION
	`uvm_component_utils(mac_environment)
	
	//=======class instances
	mac_active_agent	h_mac_active_agent;

	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "mac_environment", uvm_component parent);
		super.new(rgstr_name,parent);
	endfunction

	//=======build phase
	function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		
		h_mac_active_agent	= mac_active_agent::type_id::create("h_mac_active_agent",this);
		
	endfunction

endclass