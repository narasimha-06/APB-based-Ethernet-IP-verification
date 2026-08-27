class host_sequencer extends uvm_sequencer#(ethernet_seq_item);
	
	//=======FACTOR REGISTRATION
	`uvm_component_utils(host_sequencer)

	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "host_sequencer", uvm_component parent);
		super.new(rgstr_name,parent);
	endfunction

endclass