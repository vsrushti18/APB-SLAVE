`include "defines.svh"

class apb_driver;

	apb_transaction drv_trans;
	mailbox #(apb_transaction) mbx_gd;
	mailbox #(apb_transaction) mbx_dr;
	virtual apb_if.DRV vif;
	int num_trans;

	covergroup drv_cg;
		WR_RD: coverpoint drv_trans.PWRITE { 
			bins WRITE = {1};
			bins READ = {0};		
		} 
		DATA_IN: coverpoint drv_trans.PWDATA {
		        bins low = {[32'h0000_0000 : 32'h5555_5555]};
		        bins mid = {[32'h5555_5556 : 32'hAAAA_AAAA]};
		        bins high = {[32'hAAAA_AAAB : 32'hFFFF_FFFF]};
		}
		ADDRESS: coverpoint drv_trans.PADDR { 
			bins legal_low = {[0:63]};
			bins legal_mid = {[64:127]};
			bins legal_high = {[128:255]};
			bins illegal = {[256:511]};
		}
		STROBE: coverpoint drv_trans.PSTRB { 
			bins single_lane[] = {4'b0001, 4'b0010, 4'b0100, 4'b1000};
			bins full_lane = {4'b1111};
			bins partial = {[4'b0011:4'b1110]} with (item != 4'b1111 && $countones(item)>1);		
		}
		WRITE_DATA: cross WR_RD, DATA_IN {
		    ignore_bins read_data = binsof(WR_RD.READ);
		}
		WRITE_STROBE : cross WR_RD, STROBE {
			ignore_bins read_bins = binsof(WR_RD.READ);
		}
		WRITE_ADDRESS: cross WR_RD, ADDRESS;
		DATA_ADDRESS: cross DATA_IN, ADDRESS;
	endgroup

	function new (mailbox #(apb_transaction) mbx_gd, 
			mailbox #(apb_transaction) mbx_dr, 
			virtual apb_if.DRV vif);
		this.mbx_gd = mbx_gd;
		this.mbx_dr = mbx_dr;
		this.vif = vif;
		drv_cg = new();
	endfunction

	task start();
		@(posedge vif.PRESETn);
		for(int i=0; i<num_trans; i++) begin
			mbx_gd.get(drv_trans);
			driver_transfer();
			mbx_dr.put(drv_trans);
			drv_cg.sample();
			$display("INPUT FUNCTIONAL COVERAGE = %0d", drv_cg.get_coverage());
		end
	endtask

	task do_apb_handshake();
		{vif.drv_cb.PSEL, vif.drv_cb.PENABLE} <= drv_trans.c1state;
		vif.drv_cb.PWRITE <= drv_trans.PWRITE;
		vif.drv_cb.PWDATA <= drv_trans.PWRITE ? drv_trans.PWDATA : '0;
		vif.drv_cb.PADDR <= drv_trans.PADDR;
		vif.drv_cb.PSTRB <= drv_trans.PWRITE ? drv_trans.PSTRB : '0;
		@(vif.drv_cb);

		{vif.drv_cb.PSEL, vif.drv_cb.PENABLE} <= drv_trans.c2state;
		@(vif.drv_cb);

		if (drv_trans.is_legal_transition()) begin
			drv_trans.PRDATA = vif.drv_cb.PRDATA;
			drv_trans.PSLVERR = vif.drv_cb.PSLVERR;
		end

		if(drv_trans.back_to_back) begin
		    {vif.drv_cb.PSEL,vif.drv_cb.PENABLE} <= 2'b10;
		end
		else begin
		    {vif.drv_cb.PSEL,vif.drv_cb.PENABLE} <= drv_trans.c3state;
		end
		@(vif.drv_cb);
	endtask

	task driver_transfer();
		drv_trans.reset_abort = 0;
		fork
			begin
				do_apb_handshake();
			end
			begin	
				@(negedge vif.PRESETn);
				drv_trans.reset_abort = 1;
				vif.drv_cb.PSEL <= 0;
				vif.drv_cb.PENABLE <= 0;
				@(posedge vif.PRESETn);
			end
		join_any
		disable fork;
	endtask
endclass
						
		
