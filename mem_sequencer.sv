class mem_sequencer extends uvm_sequencer#(ethernet_seq_item);
	
	//=======FACTOR REGISTRATION
	`uvm_component_utils(mem_sequencer)

	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "mem_sequencer", uvm_component parent);
		super.new(rgstr_name,parent);
	endfunction

endclass