`include "defines.svh"

interface apb_if(input bit PCLK, input bit PRESETn);
	logic PSEL, PENABLE, PWRITE, PREADY, PSLVERR;
	logic [`DATA_WIDTH-1:0] PWDATA, PRDATA;
	logic [`ADDR_WIDTH-1:0] PADDR;
	logic [(`DATA_WIDTH/8)-1:0] PSTRB;

	clocking drv_cb @(posedge PCLK);
		default input #0 output #0;
		output PSEL, PENABLE, PWRITE, PADDR, PWDATA, PSTRB;
		input PREADY, PRDATA, PSLVERR;
	endclocking

	clocking mon_cb @(posedge PCLK);
		default input #0 output #0;
		input PREADY, PRDATA, PSLVERR, PSEL, PENABLE, PWRITE, PWDATA, PADDR, PSTRB, PRESETn;
	endclocking

	clocking ref_cb @(posedge PCLK);
		default input #0 output #0;
		input PRESETn;
	endclocking

	modport DRV(input PRESETn,clocking drv_cb);
	modport MON(input PRESETn, clocking mon_cb);
	modport REF_SB(clocking ref_cb);

	psel_always_valid: assert property(
		@(posedge PCLK) disable iff(!PRESETn)
		!$isunknown(PSEL)
	) else $error("PSEL invalid");
	
	setup_signals_valid: assert property(
		@(posedge PCLK) disable iff(!PRESETn)
		PSEL -> !$isunknown(PADDR) && !$isunknown(PWRITE) && (PWRITE -> !$isunknown(PWDATA)) && (PWRITE -> !$isunknown(PSTRB))
	) else $error("PADDR/PWRITE/PWDATA/PSTRB not valid while PSEL is asserted");

	setup_to_access: assert property(
		@(posedge PCLK) disable iff(!PRESETn )
		($rose(PSEL) && !PENABLE) |=> (PENABLE && PSEL)
	) else $error("PENABLE not asserted 1 cycle after PSEL"); 

	no_idle_to_access: assert property(
		@(posedge PCLK) disable iff(!PRESETn )
		$rose(PENABLE) |-> ($past(PSEL) && !$past(PENABLE))
	) else $error("PENABLE asserted without a preceding PSEL (IDLE->ACCESS)");

	penable_held_on_wait: assert property(
		@(posedge PCLK) disable iff(!PRESETn )
		(PENABLE && !PREADY) |=> (PENABLE throughout !PREADY)
	) else $error("PENABLE low while PREADY low (wait state");
	
	penable_low_after_pready: assert property(
		@(posedge PCLK) disable iff(!PRESETn )
		(PENABLE && PREADY) |=> !PENABLE
	) else $error("PENABLE high for more then 1 cycle after PREADY=1");

	psel_stable_setup: assert property(
		@(posedge PCLK) disable iff(!PRESETn)
		(PSEL && !PENABLE) |=> PSEL
	) else $error("PSEL dropped between SETUP and ACCESS");
	
	psel_stable_access: assert property(
		@(posedge PCLK) disable iff(!PRESETn)
		(PSEL && PENABLE && !PREADY) |=> PSEL
	) else $error("PSEL dropped during wait state");

	access_hold_stable: assert property(
		@(posedge PCLK) disable iff(!PRESETn)
		(PENABLE && !PREADY) |=> $stable(PADDR) && $stable(PWRITE) && $stable(PSEL) && $stable(PENABLE) && 				$stable(PWDATA) && $stable(PSTRB)
	) else $error("PADDR/PWRITE/PSEL/PENABLE/PWDATA/PSTRB changed during wait state");

	pready_valid_in_access: assert property(
		@(posedge PCLK) disable iff(!PRESETn)
		(PSEL && PENABLE) |-> !$isunknown(PREADY)
	) else $error("PREADY invalid during ACCESS");

	prdata_pslverr_valid: assert property(
		@(posedge PCLK) disable iff(!PRESETn)
		(PSEL && PENABLE && PREADY) |-> (!$isunknown(PSLVERR) && (!PWRITE || !$isunknown(PRDATA)))
	) else $error("PRDATA and PSLVERR not valid in PSEL, PENABLE and PREADY cycle");

	no_access_to_access: assert property(
		@(posedge PCLK) disable iff(!PRESETn)
		(PENABLE && PREADY) |=> !(PENABLE && $past(PREADY))
	) else $error("ACCESS=>ACCESS without PREADY=0");

	pstrb_read_low: assert property(
		@(posedge PCLK) disable iff(!PRESETn)
		(PSEL && !PWRITE) |-> (PSTRB == 0)
	) else $error("PSTRB active on reads");
	
	pslverr_idle_low: assert property(
		@(posedge PCLK) disable iff(!PRESETn)
		(!PSEL && !PENABLE && !PREADY) |-> !PSLVERR
	) else $error("PSLVERR high in IDLE");

endinterface
