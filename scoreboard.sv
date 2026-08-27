class scoreboard extends uvm_scoreboard;
   
	//=======FACTOR REGISTRATION
	`uvm_component_utils(scoreboard)
      	    
	uvm_blocking_get_port #(bit[31:0]) mem_get_port;
	uvm_blocking_get_port #(bit[31:0]) mac_get_port;

	//=======SEQUENCE ITEM INSTANCES
       	bit[31:0]  mem_data;
	bit[31:0]  mac_data;

   	//=======CUSTOM CONSTRUCTOR
	function new (string rgstr_name = "scoreboard", uvm_component parent);
		super.new(rgstr_name,parent);    
	endfunction

	//=======BUILD_PHASE
	function void build_phase (uvm_phase phase);
		super.build_phase(phase);
       		mac_get_port = new("mac_get_port", this);
         	mem_get_port  = new("mem_get_port", this); 
	endfunction

   	//=========Run phase
    	task run_phase(uvm_phase phase);
        	super.run_phase(phase);

        	forever begin
		
			mac_get_port.get(mac_data);
         		`uvm_info("SCOREBOARD", $sformatf("MACC_DATA:%h",mac_data), UVM_NONE);

			mem_get_port.get(mem_data);
         		`uvm_info("SCOREBOARD", $sformatf("MEMM_DATA:%h",mem_data), UVM_NONE);
   		
			Compare(mac_data,mem_data);
      		end    

    	endtask
  	
	//====comparison===
  	function Compare(bit[31:0] mac_payload,bit[31:0] mem_payload);
     		if(mac_payload == mem_payload) begin
         		`uvm_warning("SCOREBOARD_CHECK", "MATCH SUCCESS");	
		end
      		else begin
         		`uvm_error("SCOREBOARD_CHECK", "MATCH FAILED");
		end
  	endfunction 

endclass
