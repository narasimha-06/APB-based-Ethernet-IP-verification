class ethernet_virtual_sequencer extends uvm_sequencer;
	`uvm_component_utils(ethernet_virtual_sequencer)
	
	function new(string name="ethernet_virtual_sequencer",uvm_component base);
		super.new(name,base);
	endfunction

	host_sequencer	h_host_sequencer;
	mac_sequencer	h_mac_sequencer;
	mem_sequencer	h_mem_sequencer;
	
endclass