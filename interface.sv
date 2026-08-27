`timescale 1ns / 1ns

interface ethernet_interface (input pclk,input MRxClk);
	
	//=====>>HOST APB<<=====
	logic 		prstn_i; 
	logic 		psel_i;
	logic 		penable_i;
	logic 		pwrite_i;
	logic[31:0] 	paddr_i;
	logic[31:0] 	pwdata_i;
	logic[31:0] 	prdata_o;
	logic 		pready_o;

	//=====>>INTERRUPT<<=====
	logic 		int_o;
	
	//=====>>MEMORY APB<<=====
	logic 		m_pready_i;
	logic[31:0] 	m_prdata_i; 
	logic 		m_psel_o;
	logic 		m_pwrite_o;
	logic 		m_penable_o;
	logic[31:0] 	m_paddr_o;
	logic[31:0] 	m_pwdata_o;

	//=====>>TX MAC<<=====
	logic[3:0] 	MTxD;
	logic 		MTxEn;
	logic 		MTxErr;
	
	//=====>>RX MAC<<=====
	logic 		MRxDV=0;
	logic[3:0] 	MRxD;
	logic 		MRxErr;
	logic 		MCrS=0;

	clocking cb_apb_monitor @(posedge pclk);
		input m_pwdata_o, m_paddr_o, m_penable_o, m_pwrite_o, m_psel_o, int_o, m_pready_i, prdata_o, prstn_i;
	endclocking
	
	clocking cb_mem_driver@(posedge pclk);
		output m_pready_i,m_prdata_i;
	endclocking 

	clocking cb_apb_driver @(posedge pclk);
		output prstn_i, paddr_i, pwdata_i,psel_i,pwrite_i, penable_i, m_prdata_i, m_pready_i;
	endclocking 
	
	clocking cb_host_driver @(posedge pclk);
			output 	prstn_i; 
			output 	psel_i;
			output	penable_i;
			output	pwrite_i;
			output 	paddr_i;
			output 	pwdata_i;
			input  pready_o;

	endclocking
	
	clocking cb_mac_driver @(posedge MRxClk);
			output 	MRxDV;
			output 	MRxD;
			output	MRxErr;
			output	MCrS;
	endclocking
   	
	clocking cb_mac_monitor @(posedge MRxClk);
		input 	MRxDV;
		input 	MRxD;
		input	MRxErr;
		input	MCrS;
           	input 	prstn_i; 
	endclocking


//======================================host monitor clocking block===================================

	
	clocking cb_host_monitor @(posedge pclk);
			input 	prstn_i; 
			input 	psel_i;
			input	penable_i;
			input	pwrite_i;
			input 	paddr_i;
			input 	pwdata_i;
			input   pready_o;
			input   prdata_o;

	endclocking

endinterface