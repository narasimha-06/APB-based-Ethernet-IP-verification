//DUT
`include "../../RTL_DESIGN/RTL/apb_BDs_bridge.v"
`include "../../RTL_DESIGN/RTL/eth_clockgen.v"
`include "../../RTL_DESIGN/RTL/eth_crc.v"
`include "../../RTL_DESIGN/RTL/eth_fifo.v"
`include "../../RTL_DESIGN/RTL/eth_maccontrol.v"
`include "../../RTL_DESIGN/RTL/ethmac_defines.v"
`include "../../RTL_DESIGN/RTL/eth_macstatus.v"
`include "../../RTL_DESIGN/RTL/eth_miim.v"
`include "../../RTL_DESIGN/RTL/eth_outputcontrol.v"
`include "../../RTL_DESIGN/RTL/eth_random.v"
`include "../../RTL_DESIGN/RTL/eth_receivecontrol.v"
`include "../../RTL_DESIGN/RTL/eth_registers.v"
`include "../../RTL_DESIGN/RTL/eth_register.v"
`include "../../RTL_DESIGN/RTL/eth_rxaddrcheck.v"
`include "../../RTL_DESIGN/RTL/eth_rxcounters.v"
`include "../../RTL_DESIGN/RTL/eth_rxethmac.v"
`include "../../RTL_DESIGN/RTL/eth_rxstatem.v"
`include "../../RTL_DESIGN/RTL/eth_shiftreg.v"
`include "../../RTL_DESIGN/RTL/eth_spram_256x32.v"
`include "../../RTL_DESIGN/RTL/eth_transmitcontrol.v"
`include "../../RTL_DESIGN/RTL/eth_top.v"
`include "../../RTL_DESIGN/RTL/eth_txcounters.v"
`include "../../RTL_DESIGN/RTL/eth_txethmac.v"
`include "../../RTL_DESIGN/RTL/eth_txstatem.v"
`include "../../RTL_DESIGN/RTL/eth_wishbone.v"
`include "../../RTL_DESIGN/RTL/timescale.v"

//TOP MODULE
`include "../../RTL_DESIGN/RTL/eth_top.v"


package ethernet_package;
	
	`include "uvm_macros.svh"
	import uvm_pkg::*;

	`include "../MCS_DV09_ETHERNET_TEST/config_class.sv"

	`include "../MCS_DV09_ETHERNET_SEQUENCE/mcs_dv09_ethernet_seq_item.sv"
	`include "../MCS_DV09_ETHERNET_SEQUENCE/mcs_dv09_ethernet_sequence.sv"
	`include "../MCS_DV09_ETHERNET_SEQUENCE/mcs_dv09_ethernet_mac_sequence.sv"
	`include "../MCS_DV09_ETHERNET_SEQUENCE/mcs_dv09_ethernet_mem_sequence.sv"

	`include "../MCS_DV09_ETHERNET_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT_HOST/mcs_dv09_ethernet_host_sequencer.sv"
	`include "../MCS_DV09_ETHERNET_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT_HOST/mcs_dv09_ethernet_host_driver.sv"
	`include "../MCS_DV09_ETHERNET_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT_HOST/mcs_dv09_ethernet_host_monitor.sv"
	`include "../MCS_DV09_ETHERNET_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT_HOST/mcs_dv09_ethernet_host_active_agent.sv"

	`include "../MCS_DV09_ETHERNET_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT_MEMORY/mcs_dv09_ethernet_mem_sequencer.sv"
	`include "../MCS_DV09_ETHERNET_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT_MEMORY/mcs_dv09_ethernet_mem_driver.sv"
	`include "../MCS_DV09_ETHERNET_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT_MEMORY/mcs_dv09_ethernet_mem_active_agent.sv"

	`include "../MCS_DV09_ETHERNET_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT_MAC/mcs_dv09_ethernet_mac_sequencer.sv"
	`include "../MCS_DV09_ETHERNET_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT_MAC/mcs_dv09_ethernet_mac_driver.sv"
	`include "../MCS_DV09_ETHERNET_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT_MAC/mcs_dv09_ethernet_mac_monitor.sv"
	`include "../MCS_DV09_ETHERNET_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT/MCS_DV09_ETHERNET_ACTIVE_AGENT_MAC/mcs_dv09_ethernet_mac_active_agent.sv"

	`include "../MCS_DV09_ETHERNET_AGENT/MCS_DV09_ETHERNET_PASSIVE_AGENT/mcs_dv09_ethernet_mem_monitor.sv"
	`include "../MCS_DV09_ETHERNET_AGENT/MCS_DV09_ETHERNET_PASSIVE_AGENT/mcs_dv09_ethernet_mem_passive_agent.sv"

	`include "../MCS_DV09_ETHERNET_ENVIRONMENT/mcs_dv09_ethernet_virtual_sequencer.sv"
	`include "../MCS_DV09_ETHERNET_SEQUENCE/mcs_dv09_ethernet_virtual_sequence.sv"

	
	`include "../MCS_DV09_ETHERNET_ENVIRONMENT/mcs_dv09_ethernet_host_environment.sv"
	`include "../MCS_DV09_ETHERNET_ENVIRONMENT/mcs_dv09_ethernet_mac_environment.sv"
	`include "../MCS_DV09_ETHERNET_ENVIRONMENT/mcs_dv09_ethernet_scoreboard.sv"
	`include "../MCS_DV09_ETHERNET_ENVIRONMENT/mcs_dv09_ethernet_coverage.sv"
	`include "../MCS_DV09_ETHERNET_ENVIRONMENT/mcs_dv09_ethernet_top_environment.sv"
	
	`include "../MCS_DV09_ETHERNET_TEST/mcs_dv09_ethernet_test.sv"
endpackage