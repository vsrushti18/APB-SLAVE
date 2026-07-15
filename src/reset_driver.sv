class reset_driver;
		
	virtual reset_if.DRV vif;

	function new (virtual reset_if.DRV vif);
		this.vif = vif;
	endfunction

	task assert_reset (int unsigned cycles = 5);
		vif.PRESETn = 1'b0;
		repeat(cycles) @(vif.reset_cb);
		vif.PRESETn = 1'b1;
	endtask

	task assert_reset_now (int unsigned cycles = 5);
		fork
			assert_reset(cycles);
		join_none
	endtask

endclass
