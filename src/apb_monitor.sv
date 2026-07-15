`include "defines.svh"

class apb_monitor;

	apb_transaction mon_trans;
	mailbox #(apb_transaction) mbx_ms;
	virtual apb_if.MON vif;

	int num_trans;
	bit cov_active;

	covergroup mon_cg;
		ERROR: coverpoint mon_trans.PSLVERR { bins error[] = {0,1}; }
		DATA_OUT: coverpoint mon_trans.PRDATA iff (!mon_trans.PWRITE){
			bins all_zero = {32'h0000_0000};
    			bins all_ones = {32'hFFFF_FFFF};
    			bins low_half = {[32'h0000_0001 : 32'h7FFF_FFFF]};
   		 	bins high_half = {[32'h8000_0000 : 32'hFFFF_FFFE]};
 		}
	endgroup

	covergroup pready_cg @(vif.mon_cb);
		PREADY_CHECK: coverpoint vif.mon_cb.PREADY iff (vif.PRESETn && cov_active) {
			bins ready_high = {1};  
	    	}
	endgroup

	covergroup state_cg @(vif.mon_cb);
	    STATE : coverpoint {vif.mon_cb.PSEL, vif.mon_cb.PENABLE} iff(vif.PRESETn && cov_active){
		bins IDLE = {2'b00};
		bins SETUP = {2'b10};
		bins ACCESS = {2'b11};

		bins IDLE_SETUP = (2'b00 => 2'b10);
		bins SETUP_ACCESS = (2'b10 => 2'b11);
		bins ACCESS_IDLE = (2'b11 => 2'b00);
		bins ACCESS_SETUP = (2'b11 => 2'b10);

		illegal_bins IDLE_ACCESS = (2'b00 => 2'b11);
		illegal_bins SETUP_IDLE = (2'b10 => 2'b00);
		illegal_bins IDLE_ILLEGAL = (2'b00 => 2'b01);
		illegal_bins ILLEGAL_STATE = {2'b01};
	    }
	endgroup
	
	function new (virtual apb_if.MON vif, mailbox #(apb_transaction) mbx_ms);
		this.vif = vif;
		this.mbx_ms = mbx_ms;
		mon_cg = new();
		pready_cg = new();
		state_cg = new();
		cov_active = 0;
	endfunction

	task start();
		@(posedge vif.PRESETn);
	 	cov_active = 1;
		for (int i = 0; i < num_trans; i++) begin
		    capture_one_transfer();
		end
		cov_active = 0;
	endtask

	task capture_one_transfer();
		mon_trans = new();
		mon_trans.reset_abort = 0;
		
		fork 
			begin			
				do_capture();
			end
			begin
				@(negedge vif.PRESETn);
				mon_trans.reset_abort = 1;
				$display("MONITOR abandoning in-flight capture due to reset, PADDR=%0h",
                     			 mon_trans.PADDR);
				mbx_ms.put(mon_trans);	
			end
		join_any
		disable fork;
		
		if(!vif.PRESETn) begin
			@(posedge vif.PRESETn);
		end
	endtask

	task do_capture();

	     @(vif.mon_cb);
	     mon_trans.PADDR = vif.mon_cb.PADDR;
	     mon_trans.PWRITE = vif.mon_cb.PWRITE;
	     mon_trans.PWDATA = vif.mon_cb.PWDATA;
	     mon_trans.PSTRB = vif.mon_cb.PSTRB;
	     $display("MONITOR EDGE1: PSEL=%0b PENABLE=%0b PADDR=%0h PWRITE=%0b",
		 vif.mon_cb.PSEL, vif.mon_cb.PENABLE, mon_trans.PADDR, mon_trans.PWRITE);

	     @(vif.mon_cb);
	     mon_trans.PRDATA = vif.mon_cb.PRDATA;
	     mon_trans.PSLVERR = vif.mon_cb.PSLVERR;
	     $display("MONITOR EDGE2: PSEL=%0b PENABLE=%0b PRDATA=%0h PSLVERR=%0b",
		 vif.mon_cb.PSEL, vif.mon_cb.PENABLE, mon_trans.PRDATA, mon_trans.PSLVERR);

	     @(vif.mon_cb);
	     $display("MONITOR EDGE3: PSEL=%0b PENABLE=%0b - transfer window closed",
		 vif.mon_cb.PSEL, vif.mon_cb.PENABLE);

	     mbx_ms.put(mon_trans);
	     mon_cg.sample();
	     $display("OUTPUT FUNCTIONAL COVERAGE = %0d", mon_cg.get_coverage());
	 endtask

endclass

	
