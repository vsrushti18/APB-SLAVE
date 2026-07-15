`include "defines.svh"

class apb_test;
        apb_environment env;
    	virtual apb_if.DRV drv_vif;
    	virtual apb_if.MON mon_vif;
    	virtual reset_if.DRV rst_vif;
    	function new(virtual apb_if.DRV drv_vif,
                 	virtual apb_if.MON mon_vif,
                 	virtual reset_if.DRV rst_vif);
        		this.drv_vif = drv_vif;
        		this.mon_vif = mon_vif;
        		this.rst_vif = rst_vif;
    	endfunction
    	virtual function apb_generator create_gen(mailbox #(apb_transaction) mbx_gd);
        		create_gen = new(mbx_gd);
    	endfunction
    	virtual task run();
				env = new(drv_vif, mon_vif, rst_vif);
				env.build();
				env.gen = create_gen(env.mbx_gd);
				env.start();
    	endtask
endclass

class test_basic_random extends apb_test;
    	function new(virtual apb_if.DRV drv_vif, virtual apb_if.MON mon_vif, virtual reset_if.DRV rst_vif);
        		super.new(drv_vif, mon_vif, rst_vif);
    	endfunction
endclass

class test_wr_rd extends apb_test;
    	function new(virtual apb_if.DRV drv_vif, virtual apb_if.MON mon_vif, virtual reset_if.DRV rst_vif);
        		super.new(drv_vif, mon_vif, rst_vif);
    	endfunction
    	virtual function apb_generator create_gen(mailbox #(apb_transaction) mbx_gd);
				apb_generator_wr_rd g;
				g = new(mbx_gd);
				create_gen = g;
    	endfunction
endclass

class test_multi_wr_multi_rd extends apb_test;
		function new(virtual apb_if.DRV drv_vif, virtual apb_if.MON mon_vif, virtual reset_if.DRV rst_vif);
		    		super.new(drv_vif, mon_vif, rst_vif);
		endfunction
		virtual function apb_generator create_gen(mailbox #(apb_transaction) mbx_gd);
					apb_generator_multi_wr_multi_rd g;
					g = new(mbx_gd);
					create_gen = g;
		endfunction
endclass

class test_wr_same_addr extends apb_test;
		function new(virtual apb_if.DRV drv_vif, virtual apb_if.MON mon_vif, virtual reset_if.DRV rst_vif);
		    		super.new(drv_vif, mon_vif, rst_vif);
		endfunction
		virtual function apb_generator create_gen(mailbox #(apb_transaction) mbx_gd);
					apb_generator_wr_same_addr g;
					g = new(mbx_gd);
					create_gen = g;
		endfunction
endclass

class test_error extends apb_test;
		function new(virtual apb_if.DRV drv_vif, virtual apb_if.MON mon_vif, virtual reset_if.DRV rst_vif);
		    		super.new(drv_vif, mon_vif, rst_vif);
		endfunction
		virtual function apb_generator create_gen(mailbox #(apb_transaction) mbx_gd);
					apb_generator_error g;
					g = new(mbx_gd);
					create_gen = g;
		endfunction
endclass

class test_error_recovery extends apb_test;
		function new(virtual apb_if.DRV drv_vif, virtual apb_if.MON mon_vif, virtual reset_if.DRV rst_vif);
		    		super.new(drv_vif, mon_vif, rst_vif);
		endfunction
		virtual function apb_generator create_gen(mailbox #(apb_transaction) mbx_gd);
					apb_generator_error_recovery g;
					g = new(mbx_gd);
					create_gen = g;
		endfunction
endclass

class test_pstrb_full extends apb_test;
		function new(virtual apb_if.DRV drv_vif, virtual apb_if.MON mon_vif, virtual reset_if.DRV rst_vif);
		    		super.new(drv_vif, mon_vif, rst_vif);
		endfunction
		virtual function apb_generator create_gen(mailbox #(apb_transaction) mbx_gd);
					apb_generator_pstrb_full g;
					g = new(mbx_gd);
					create_gen = g;
		endfunction
endclass

class test_pstrb_single_byte extends apb_test;
		function new(virtual apb_if.DRV drv_vif, virtual apb_if.MON mon_vif, virtual reset_if.DRV rst_vif);
		    	super.new(drv_vif, mon_vif, rst_vif);
		endfunction
		virtual function apb_generator create_gen(mailbox #(apb_transaction) mbx_gd);
				apb_generator_pstrb_single_byte g;
				g = new(mbx_gd);
				create_gen = g;
		endfunction
endclass

class test_pstrb_read_garbage extends apb_test;
		function new(virtual apb_if.DRV drv_vif, virtual apb_if.MON mon_vif, virtual reset_if.DRV rst_vif);
		    	super.new(drv_vif, mon_vif, rst_vif);
		endfunction
		virtual function apb_generator create_gen(mailbox #(apb_transaction) mbx_gd);
				apb_generator_pstrb_read_garbage g;
				g = new(mbx_gd);
				create_gen = g;
		endfunction
endclass

class test_protocol_violation extends apb_test;
		function new(virtual apb_if.DRV drv_vif, virtual apb_if.MON mon_vif, virtual reset_if.DRV rst_vif);
		    	super.new(drv_vif, mon_vif, rst_vif);
		endfunction
		virtual function apb_generator create_gen(mailbox #(apb_transaction) mbx_gd);
				apb_generator_protocol_violation g;
				g = new(mbx_gd);
				create_gen = g;
		endfunction
endclass

class test_pstrb_pattern extends apb_test;
		function new(virtual apb_if.DRV drv_vif,virtual apb_if.MON mon_vif,virtual reset_if.DRV rst_vif);
				super.new(drv_vif, mon_vif, rst_vif);
		endfunction
		virtual function apb_generator create_gen(mailbox #(apb_transaction) mbx_gd);
				apb_generator_pstrb_pattern g;
				g = new(mbx_gd);
				create_gen = g;
		endfunction
endclass

class test_data_pattern extends apb_test;
		function new(virtual apb_if.DRV drv_vif,virtual apb_if.MON mon_vif,virtual reset_if.DRV rst_vif);
				super.new(drv_vif, mon_vif, rst_vif);
		endfunction
		virtual function apb_generator create_gen(mailbox #(apb_transaction) mbx_gd);
				apb_generator_data_pattern g;
				g = new(mbx_gd);
				create_gen = g;
		endfunction
endclass

class test_back_to_back extends apb_test;
		function new(virtual apb_if.DRV drv_vif,virtual apb_if.MON mon_vif,virtual reset_if.DRV rst_vif);
		    	super.new(drv_vif,mon_vif,rst_vif);
		endfunction
		virtual function apb_generator create_gen(mailbox #(apb_transaction) mbx_gd);
				apb_generator_back_to_back g;
				g = new(mbx_gd);
				create_gen = g;
		endfunction
endclass

class test_reset_during_transfer extends apb_test;
		function new(virtual apb_if.DRV drv_vif,virtual apb_if.MON mon_vif,virtual reset_if.DRV rst_vif);
		    	super.new(drv_vif, mon_vif, rst_vif);
		endfunction
		virtual function apb_generator create_gen(mailbox #(apb_transaction) mbx_gd);
				apb_generator_reset_during_transfer g;
				g = new(mbx_gd);
				create_gen = g;
		endfunction
		virtual task run();
				env = new(drv_vif, mon_vif, rst_vif);
				env.build();
				env.gen = create_gen(env.mbx_gd);
				fork
						begin
						   		env.start();
						end
						begin
								@(posedge mon_vif.PRESETn);
								wait(mon_vif.mon_cb.PSEL == 1'b1 && mon_vif.mon_cb.PENABLE == 1'b1);
								$display("\nRESET TEST: ACCESS detected -- asserting reset NOW\n");
								env.rst_drv.assert_reset_now(3);
						end
				join
		endtask
endclass

class test_regression extends apb_test;
		function new(virtual apb_if.DRV drv_vif,virtual apb_if.MON mon_vif,virtual reset_if.DRV rst_vif);
		    	super.new(drv_vif, mon_vif, rst_vif);
		endfunction
    	virtual task run();
				test_basic_random t1;
				test_wr_rd t2;
				test_multi_wr_multi_rd t3;
				test_wr_same_addr t4;
				test_error t5;
				test_error_recovery t6;
				test_pstrb_full t7;
				test_pstrb_single_byte t8;
				test_pstrb_read_garbage t9;
				test_protocol_violation t10;
				test_pstrb_pattern t11;
				test_data_pattern t12;
				test_back_to_back t13;
				test_reset_during_transfer t14;
				t1 = new(drv_vif, mon_vif, rst_vif); t1.run();
				t2 = new(drv_vif, mon_vif, rst_vif); t2.run();
				t3 = new(drv_vif, mon_vif, rst_vif); t3.run();
				t4 = new(drv_vif, mon_vif, rst_vif); t4.run();
				t5 = new(drv_vif, mon_vif, rst_vif); t5.run();
				t6 = new(drv_vif, mon_vif, rst_vif); t6.run();
				t7 = new(drv_vif, mon_vif, rst_vif); t7.run();
				t8 = new(drv_vif, mon_vif, rst_vif); t8.run();
				t9 = new(drv_vif, mon_vif, rst_vif); t9.run();
				t10 = new(drv_vif, mon_vif, rst_vif); t10.run();
				t11 = new(drv_vif, mon_vif, rst_vif); t11.run();
				t12 = new(drv_vif, mon_vif, rst_vif); t12.run();
				t13 = new(drv_vif,mon_vif,rst_vif); t13.run();
				t14 = new(drv_vif, mon_vif, rst_vif); t14.run();
		endtask
endclass

