interface reset_if(input bit PCLK);
	
	logic PRESETn;

	clocking reset_cb @(posedge PCLK);
		default input #0 output #0;
	endclocking

	modport DRV(ref PRESETn, clocking reset_cb);
	modport MON(input PRESETn);

endinterface
