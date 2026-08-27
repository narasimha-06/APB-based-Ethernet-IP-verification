class ethernet_test extends uvm_test;
	
	//=======FACTOR REGISTRATION
	`uvm_component_utils(ethernet_test)
	
	//=======class instances
	top_environment h_top_environment;
	ethernet_virtual_sequence	h_virtual_sequence;
	
	//=======CONFIG CLASS INSTANCE
	config_class	h_config;

	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "ethernet_test", uvm_component parent);
		super.new(rgstr_name,parent);
	endfunction

	//=======build phase
	function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		
		h_top_environment	= top_environment::type_id::create("h_top_environment",this);
		
		//========CONFIG CLASS MEMORY CREATION AND SETTING
		h_config	= config_class::type_id::create("h_config");
		//uvm_config_db#(config_class)::set(this,"*","config",h_config);

	endfunction
	

	//======END OF ELLOBARATION PHASE
	function void end_of_elaboration_phase (uvm_phase phase);
		
		super.end_of_elaboration_phase(phase);

		uvm_top.print_topology();
		
	endfunction


	//=====run_phase
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		
		h_virtual_sequence = ethernet_virtual_sequence::type_id::create("h_virtual_sequence");
		phase.phase_done.set_drain_time(this,1000ns);
		
		phase.raise_objection(this,"raised test objection");					//-------raise objection

			h_virtual_sequence.start(h_top_environment.h_virtual_sequencer);		//------invoking virtual sequencer 
			//#100;
		
		phase.drop_objection(this,"dropped test objection");					//-------drop objection	endtask
			
	endtask
endclass