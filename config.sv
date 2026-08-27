class config_class extends uvm_object;
	
	//======FACTORY REGISTRATION
	`uvm_object_utils(config_class)
	
	//=====CUSTOM CONSTRUCTOR
	function new(string rgstr_name="config_class");
		super.new(rgstr_name);
	endfunction
	
	//=========>REGISTERS<=========
	bit[31:0] moder;
	bit[31:0] int_source;
	bit[31:0] int_mask;
	bit[31:0] tx_bd_num;
	bit[31:0] mii_addrs;
	bit[31:0] mac_addrs0;
	bit[31:0] mac_addrs1;
	bit[31:0] rxbd[int];
	
	longint present_bd;						// PRESENT_BD = {RXBD[OFFSET+0],RXBD[OFFSET+4]}.
	bit config_done;						// THIS BIT BECOMES HIGH WHEN ALL THE REGISTERS CONFIGURED.
	//=========>FRAME COUNT<=======
	int frame_cnt;
	
	task display();
		
		//THIS TASK WILL DISPLAY THE BUFFER DISCRIPTORS WHICH ARE STORED IN THE ASSOCIATIVE ARRAY
		int i;

		if(rxbd.first(i)) begin
			do begin
			$display("[config class]==============adrrsss: %0d,  data:%0d",i,rxbd[i]);
			end
			while(rxbd.next(i));
		end
	endtask	
	
endclass