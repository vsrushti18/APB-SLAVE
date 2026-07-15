`include "defines.svh"

class apb_generator;
	apb_transaction blueprint;
	mailbox #(apb_transaction) mbx_gd;
	int total_trans;
	function new (mailbox #(apb_transaction) mbx_gd);
		this.mbx_gd = mbx_gd;
		blueprint = new();
		total_trans = `NUM_TRANSACTIONS;
	endfunction
	virtual task start();
		for (int i=0; i<`NUM_TRANSACTIONS; i++) begin
			assert(blueprint.randomize() == 1);
			mbx_gd.put(blueprint.copy());
			$display("GENERATOR Randomized Transaction: PWDATA = %0h, PADDR = %0h, PWRITE = %0b, PSTRB = %0h", 					blueprint.PWDATA, blueprint.PADDR, blueprint.PWRITE, blueprint.PSTRB);
		end
	endtask
endclass

class apb_generator_wr_rd extends apb_generator;
	function new (mailbox #(apb_transaction) mbx_gd);
		super.new(mbx_gd);	
		total_trans = 2*(`NUM_TRANSACTIONS/20); 
	endfunction
	virtual task start();
		for(int i=0; i<(`NUM_TRANSACTIONS/20); i++) begin
			apb_transaction_write wtrans;
			apb_transaction_read rtrans;
			wtrans = new();
			assert(wtrans.randomize() with { PADDR == i; });
			mbx_gd.put(wtrans.copy());
			$display("GENERATOR(WR_RD) Generated WRITE request: PWDATA = %0h, PADDR = %0h, PWRITE = %0b, PSTRB = 					%0h", wtrans.PWDATA, wtrans.PADDR, wtrans.PWRITE, wtrans.PSTRB);
			rtrans = new();
			assert(rtrans.randomize() with { PADDR == i; });
			mbx_gd.put(rtrans.copy());
			$display("GENERATOR(WR_RD) Generated READ request: PADDR = %0h", rtrans.PADDR);
		end
	endtask
endclass

class apb_generator_multi_wr_multi_rd extends apb_generator;
	function new (mailbox #(apb_transaction) mbx_gd);
		super.new(mbx_gd);
		total_trans = 2*(`NUM_TRANSACTIONS/20); 
	endfunction
	virtual task start();
		for(int i=0; i<(`NUM_TRANSACTIONS/20); i++) begin
			apb_transaction_write wtrans3;
			wtrans3 = new();
			assert(wtrans3.randomize() with { PADDR == i; });
			mbx_gd.put(wtrans3.copy());
			$display("GENERATOR(WR_RD) Generated WRITE request: PWDATA = %0h, PADDR = %0h, PWRITE = %0b, PSTRB = 					%0h", wtrans3.PWDATA, wtrans3.PADDR, wtrans3.PWRITE, wtrans3.PSTRB);
		end
		for(int i=0; i<(`NUM_TRANSACTIONS/20); i++) begin
			apb_transaction_read rtrans3;
			rtrans3 = new();
			assert(rtrans3.randomize() with { PADDR == i; });
			mbx_gd.put(rtrans3.copy());
			$display("GENERATOR(WR_RD) Generated READ request: PADDR = %0h", rtrans3.PADDR);
		end
	endtask
endclass

class apb_generator_wr_same_addr extends apb_generator;	
	function new (mailbox #(apb_transaction) mbx_gd);
		super.new(mbx_gd);
		total_trans = (`NUM_TRANSACTIONS/20)+1; 
	endfunction
	virtual task start();
		apb_transaction_write wtrans1;
		apb_transaction_read rtrans1;
		for(int i=0; i<(`NUM_TRANSACTIONS/20); i++) begin
			wtrans1 = new();		
			assert(wtrans1.randomize() with { PADDR == 32'h0000_0000; });
			mbx_gd.put(wtrans1.copy());
			$display("GENERATOR(WR_RD) Generated WRITE request: PWDATA = %0h, PADDR = %0h, PWRITE = %0b, PSTRB = 					%0b", wtrans1.PWDATA, wtrans1.PADDR, wtrans1.PWRITE, wtrans1.PSTRB);
		end
		rtrans1 = new();
		assert(rtrans1.randomize() with { PADDR == 32'h0000_0000; });
		mbx_gd.put(rtrans1.copy());
		$display("GENERATOR(WR_RD) Generated READ request: PADDR = %0h", rtrans1.PADDR);
	endtask
endclass

class apb_generator_error extends apb_generator;
	function new(mailbox #(apb_transaction) mbx_gd);
		super.new(mbx_gd);
		total_trans = (`NUM_TRANSACTIONS/20);
	endfunction	
	virtual task start();
		for(int i = 0; i < (`NUM_TRANSACTIONS/40); i++) begin
			apb_transaction_error_write ewtrans;
			ewtrans = new();
			assert(ewtrans.randomize());
			mbx_gd.put(ewtrans.copy());
			$display("GENERATOR(ERROR) ILLEGAL WRITE: PADDR=%0h PWDATA=%0h",ewtrans.PADDR,ewtrans.PWDATA);
		end
		for(int i = 0; i < (`NUM_TRANSACTIONS/40); i++) begin
			apb_transaction_error_read ertrans;
			ertrans = new();
			assert(ertrans.randomize());
			mbx_gd.put(ertrans.copy());
			$display("GENERATOR(ERROR) ILLEGAL READ: PADDR=%0h",ertrans.PADDR);
		end
	endtask
endclass

class apb_generator_error_recovery extends apb_generator;
	function new (mailbox #(apb_transaction) mbx_gd);
		super.new(mbx_gd);
		total_trans = 2*(`NUM_TRANSACTIONS/20); 
	endfunction
	virtual task start();
		for(int i=0;i<(`NUM_TRANSACTIONS/20); i++) begin
			apb_transaction_error etrans1;
			apb_transaction_write wtrans2;	
			etrans1 = new();
			assert(etrans1.randomize());
			mbx_gd.put(etrans1.copy());
			if(etrans1.PWRITE) begin
				$display("GENERATOR(ERROR) Generated WRITE request: PWDATA = %0h, PADDR = %0h, PWRITE = %0b, 						PSTRB = %0b", etrans1.PWDATA, etrans1.PADDR, etrans1.PWRITE, etrans1.PSTRB);
			end else begin
				$display("GENERATOR(ERROR) Generated READ request: PADDR = %0h", etrans1.PADDR);
			end
			wtrans2 = new();
			assert(wtrans2.randomize()); 
			mbx_gd.put(wtrans2.copy());
			$display("GENERATOR(WR_RD) Generated WRITE request: PWDATA = %0h, PADDR = %0h, PWRITE = %0b, PSTRB = 					%0b", wtrans2.PWDATA, wtrans2.PADDR, wtrans2.PWRITE, wtrans2.PSTRB);
		end
	endtask
endclass

class apb_generator_pstrb_full extends apb_generator;		
	function new (mailbox #(apb_transaction) mbx_gd);
		super.new(mbx_gd);
		total_trans = (`NUM_TRANSACTIONS/20); 
	endfunction
	virtual task start();
		for(int i=0; i<(`NUM_TRANSACTIONS/20); i++) begin
			apb_transaction_pstrb_full ptrans;
			ptrans = new();
			assert(ptrans.randomize() == 1);
			mbx_gd.put(ptrans.copy());
			$display("GENERATOR(PSTRB_FULL) Generated FULL LANE WRITE request: PWDATA = %0h, PADDR = %0h, PWRITE = %0b, 					PSTRB = %0b", ptrans.PWDATA, ptrans.PADDR, ptrans.PWRITE, ptrans.PSTRB);
		end
	endtask
endclass

class apb_generator_pstrb_single_byte extends apb_generator;	
	function new (mailbox #(apb_transaction) mbx_gd);
		super.new(mbx_gd);
		total_trans = (`DATA_WIDTH/8); 
	endfunction
	virtual task start();
		apb_transaction_pstrb_single_byte pstrans;
		for(int i=0; i<(`DATA_WIDTH/8); i++) begin
			pstrans = new();
			assert(pstrans.randomize() with {PSTRB == (1<<i); });
			mbx_gd.put(pstrans.copy());
			$display("GENERATOR(PSTRB_SINGLE) Generated SINGLE LANE WRITE request: PWDATA = %0h, PADDR = %0h, PWRITE 					= %0b, PSTRB = %0b(i=%0d)", pstrans.PWDATA, pstrans.PADDR, pstrans.PWRITE, pstrans.PSTRB, i);
		end
	endtask
endclass

class apb_generator_pstrb_read_garbage extends apb_generator;		
	function new (mailbox #(apb_transaction) mbx_gd);
		super.new(mbx_gd);
		total_trans = (`NUM_TRANSACTIONS/20); 
	endfunction
	virtual task start();
		for(int i=0; i<(`NUM_TRANSACTIONS/20); i++) begin
			apb_transaction_pstrb_read_garbage pgtrans;
			pgtrans = new();
			assert(pgtrans.randomize() == 1);
			mbx_gd.put(pgtrans.copy());
			$display("GENERATOR(PSTRB GARBAGE) Generated READ request: PADDR = %0h PSTRB = %0b", pgtrans.PADDR, 					pgtrans.PSTRB);
		end
	endtask	
endclass

class apb_generator_protocol_violation extends apb_generator;
	function new (mailbox #(apb_transaction) mbx_gd);
		super.new(mbx_gd);
		total_trans = (`NUM_TRANSACTIONS/20);
	endfunction
	virtual task start();
		for(int i=0; i<(`NUM_TRANSACTIONS/20); i++) begin
			apb_transaction_protocol_violation vtrans;
			vtrans = new();
			assert(vtrans.randomize() with {
				vtype == apb_transaction_protocol_violation::ve'(i % 5);
			});
			mbx_gd.put(vtrans.copy());
			$display("GENERATOR(PROTOCOL_VIOLATION) vtype=%0s c1=%0s c2=%0s c3=%0s",
				vtrans.vtype.name(), vtrans.c1state.name(), vtrans.c2state.name(), vtrans.c3state.name());
		end
	endtask
endclass

class apb_generator_pstrb_pattern extends apb_generator;
	function new(mailbox #(apb_transaction) mbx_gd);
		super.new(mbx_gd);
		total_trans = 4;
	endfunction
	virtual task start();
		bit [3:0] patterns[4] = {4'b0011,4'b1100,4'b0101,4'b1010};
		for(int i = 0; i < 4; i++) begin
			apb_transaction_write ptrans;
			ptrans = new();
			assert(ptrans.randomize() with {PSTRB == patterns[i];});
			mbx_gd.put(ptrans.copy());
			$display("GENERATOR(PSTRB_PATTERN) PSTRB=%04b PADDR=%0h PWDATA=%0h",ptrans.PSTRB,ptrans.PADDR,ptrans.PWDATA);
		end
	endtask
endclass

class apb_generator_data_pattern extends apb_generator;
	function new(mailbox #(apb_transaction) mbx_gd);
		super.new(mbx_gd);
		total_trans = 8;
	endfunction
	virtual task start();
		logic [`DATA_WIDTH-1:0] patterns[4] = {32'h0000_0000,32'hFFFF_FFFF,32'hAAAA_AAAA,32'h5555_5555};
		for(int i = 0; i < 4; i++) begin
			apb_transaction_write wtrans;
			apb_transaction_read  rtrans;
			wtrans = new();
			assert(wtrans.randomize() with {PADDR  == i;PWDATA == patterns[i];PSTRB  == 4'b1111;});
			mbx_gd.put(wtrans.copy());
			rtrans = new();
			assert(rtrans.randomize() with {PADDR == i;});
			mbx_gd.put(rtrans.copy());
			$display("GENERATOR(DATA_PATTERN) ADDR=%0h DATA=%0h",wtrans.PADDR,wtrans.PWDATA);
		end
	endtask
endclass

class apb_generator_back_to_back extends apb_generator;
        function new(mailbox #(apb_transaction) mbx_gd);
        	super.new(mbx_gd);
        	total_trans = 10;
     	endfunction
        virtual task start();
        	for(int i=0;i<10;i++) begin
            		apb_transaction t;
            		t = new();
            		assert(t.randomize());
            		if(i != total_trans-1) t.back_to_back = 1;
            		else t.back_to_back = 0;
            		mbx_gd.put(t.copy());
        	end
        endtask
endclass

class apb_generator_reset_during_transfer extends apb_generator;
        function new(mailbox #(apb_transaction) mbx_gd);
        	super.new(mbx_gd);
        	total_trans = 10;
        endfunction
        virtual task start();
                for (int i = 0; i < total_trans; i++) begin
            		apb_transaction t;
            		t = new();
            		assert(t.randomize() with {c1state == SETUP;c2state == ACCESS;});
            		mbx_gd.put(t.copy());
            		$display("GENERATOR(RESET_TEST): transaction %0d PADDR=%0h",i,t.PADDR);
                end
         endtask
endclass			
			

