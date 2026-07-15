`include "defines.svh"

class apb_environment;	
	virtual apb_if.DRV drv_vif;
	virtual apb_if.MON mon_vif;
	virtual reset_if.DRV rst_vif;
		
	mailbox #(apb_transaction) mbx_gd;
	mailbox #(apb_transaction) mbx_dr;
	mailbox #(apb_transaction) mbx_rs;
	mailbox #(apb_transaction) mbx_ms;

	apb_generator gen;
	apb_driver drv;
 	apb_monitor mon;
	apb_reference_model ref_sb;
	apb_scoreboard scb;
	reset_driver rst_drv;

	function new( virtual apb_if.DRV drv_vif, 
			virtual apb_if.MON mon_vif,
			virtual reset_if.DRV rst_vif);
		this.drv_vif = drv_vif;
		this.mon_vif = mon_vif;
		this.rst_vif = rst_vif;
	endfunction
		
	task build();
		mbx_gd = new();
		mbx_dr = new();
		mbx_rs = new();
		mbx_ms = new();
		gen = new(mbx_gd);
		drv = new(mbx_gd, mbx_dr, drv_vif);
		mon = new(mon_vif, mbx_ms);
		ref_sb = new(mbx_dr, mbx_rs);
		scb = new(mbx_rs, mbx_ms);
		rst_drv = new(rst_vif);
	endtask

	task start();
		rst_drv.assert_reset_now();
		drv.num_trans = gen.total_trans;   
		mon.num_trans = gen.total_trans;   
		ref_sb.num_trans = gen.total_trans;   
		scb.num_trans = gen.total_trans;
		fork
			gen.start();
			drv.start();
			mon.start();
			ref_sb.start();
			scb.start();
		join
		scb.report();
	endtask
endclass
			
	
