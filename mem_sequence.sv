class mem_pready extends uvm_sequence #(ethernet_seq_item);

	`uvm_object_utils(mem_pready)

    	//====object constructor==================================================================================
 	function new(string name="mem_pready");
  		super.new(name);
	endfunction
   	//==========task body===================================================
    	task body();
      		req = ethernet_seq_item::type_id::create("req");

		forever begin
     			start_item(req);
          			req.m_pready_i=1;
      				`uvm_info("TC_MEM_PREADY_i",$sformatf("TC_MEM_PREADY_i m_pready=%0d",req.m_pready_i),UVM_MEDIUM);
      			finish_item(req);
		end
   	endtask

endclass
