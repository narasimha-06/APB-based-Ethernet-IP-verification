


`timescale 1ns / 1ns

module ethernet_top;
	
	import uvm_pkg::*;
	import ethernet_package::*;

	//========CLOCK GENERATION
	//====APB CLOCK
	bit pclk;
	always #20 pclk++;
	//====MAC CLOCKS
	bit MRxClk;
	always #20 MRxClk++;

	bit MTxClk;
	always #20 MTxClk++;

	//========TEST INSTANCE
	ethernet_test	h_ethernet_test;
	
	//========INTERFACE INSTANCE 
	ethernet_interface	intf(pclk,MRxClk);

	//=======CONFIG CLASS INSTANCE
	config_class	h_config;

	//========Design INSTANCE
	eth_top	DUT(	
			.pclk_i(pclk),
			.prstn_i(intf.prstn_i),  
                        .pwdata_i(intf.pwdata_i), 
                        .prdata_o(intf.prdata_o), 
                        .paddr_i(intf.paddr_i),     
                        .psel_i(intf.psel_i),
                        .pwrite_i(intf.pwrite_i),    
                        .penable_i(intf.penable_i),   
	                .pready_o(intf.pready_o),    
			.int_o(intf.int_o),
			.m_paddr_o(intf.m_paddr_o),
			.m_psel_o(intf.m_psel_o),
                        .m_pwrite_o(intf.m_pwrite_o),
                        .m_prdata_i(intf.m_prdata_i),
                        .m_pwdata_o(intf.m_pwdata_o),
                        .m_penable_o(intf.m_penable_o),
                        .m_pready_i(intf.m_pready_i),

			.mtx_clk_pad_i(MTxClk),
                        .mtxd_pad_o(intf.MTxD),   
                        .mtxen_pad_o(intf.MTxEn),  
                        .mtxerr_pad_o(intf.MTxErr),
			
                        .mrx_clk_pad_i(MRxClk),
                        .mrxd_pad_i(intf.MRxD),   
                        .mrxdv_pad_i(intf.MRxDV),  
                        .mrxerr_pad_i(intf.MRxErr), 
                        .mcrs_pad_i(intf.MCrS)   
	);

	initial begin
		
		h_config	= new("h_config");
		uvm_config_db#(config_class)::set(null,"*","config",h_config);	
		
		//=============SETTING INTERFACE============
		uvm_config_db#(virtual ethernet_interface)::set(null,"*","vif",intf);
		
		run_test();
	end

	initial begin
		//#1400 $finish;
	end
	
	final begin
		$display("Config Class: %p",h_config);
	end
endmodule