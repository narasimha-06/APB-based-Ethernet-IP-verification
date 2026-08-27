class top_environment extends uvm_env;
	
	//=======FACTOR REGISTRATION
	`uvm_component_utils(top_environment)
	
	//=======class instances
	mac_environment		h_mac_environment;
	host_environment	h_host_environment;
	scoreboard		h_scoreboard;
	ethernet_coverage	h_coverage;
	
	
	//======TLM FIFO DECLARATION
	uvm_tlm_fifo #(bit[31:0]) mac_fifo;
      	uvm_tlm_fifo #(bit [31:0]) mem_fifo;

	//======VIRTUAL SEQUENCER
	ethernet_virtual_sequencer	h_virtual_sequencer;
	
	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "top_environment", uvm_component parent);
		super.new(rgstr_name,parent);
	endfunction

	//=======build phase
	function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		
		h_mac_environment	= mac_environment::type_id::create("h_mac_environment",this);
		h_host_environment	= host_environment::type_id::create("h_host_environment",this);
		h_scoreboard		= scoreboard::type_id::create("h_scoreboard",this);
		h_coverage		= ethernet_coverage::type_id::create("h_coverage",this);
		
		mac_fifo = new("mac_fifo", this,100);
         	mem_fifo  = new("mem_fifo", this,100); 

		h_virtual_sequencer	= ethernet_virtual_sequencer::type_id::create("h_virtual_sequencer",this);
		
	endfunction

	//======Connect_phase
	function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		
		//=======POINTING SEQUENCERS IN VIRTUAL SEQUENCER TO THERE RESPECTIVE SEQUENCERS	
		h_virtual_sequencer.h_host_sequencer = h_host_environment.h_host_active_agent.h_host_sequencer; 
		h_virtual_sequencer.h_mac_sequencer = h_mac_environment.h_mac_active_agent.h_mac_sequencer; 
		h_virtual_sequencer.h_mem_sequencer = h_host_environment.h_mem_active_agent.h_mem_sequencer; 		

		//=======TLM FIFO CONNECTIONS
		//====MEM FIFO CONNECTIONS
		h_host_environment.h_mem_passive_agent.h_mem_monitor.mem_put_port.connect(mem_fifo.put_export);
		h_scoreboard.mem_get_port.connect(mem_fifo.get_export);

		//====MAC FIFO CONNECTIONS
		h_mac_environment.h_mac_active_agent.h_mac_monitor.mac_put_port.connect(mac_fifo.put_export);
		h_scoreboard.mac_get_port.connect(mac_fifo.get_export);

	endfunction

endclass

