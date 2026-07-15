`include "defines.svh"

class apb_scoreboard;
	
	apb_transaction rs_trans, ms_trans;
	mailbox #(apb_transaction) mbx_rs;
	mailbox #(apb_transaction) mbx_ms;

	int MATCH = 0;
	int MISMATCH = 0;
	int ABORTED = 0;
	int SYNC_ERR = 0;
	int ILLEGAL = 0;
	int num_trans;
 	
	function new ( mailbox #(apb_transaction) mbx_rs,
			mailbox #(apb_transaction) mbx_ms);
		this.mbx_rs = mbx_rs;
		this.mbx_ms = mbx_ms;
	endfunction
	
	task start();
		for(int i=0; i<num_trans; i++) begin
			fork
				begin
					mbx_rs.get(rs_trans);
				end
				begin
					mbx_ms.get(ms_trans);
				end
			join
			compare_report();
		end
	endtask

	task compare_report();
		bit ok;
		
		if (rs_trans.reset_abort && ms_trans.reset_abort) begin
			ABORTED++;
			$display("SCOREBOARD: transaction ABORTED (reset), PADDR=%0h", rs_trans.PADDR);
			return;
		end
		else if (rs_trans.reset_abort !== ms_trans.reset_abort) begin
			SYNC_ERR++;
			$display("SCOREBOARD ERROR: reset_abort mismatch REF=%0b MON=%0b (testbench desync)",
				rs_trans.reset_abort, ms_trans.reset_abort);
			return;
		end 

		if (!rs_trans.is_legal_transition()) begin
		    ILLEGAL++;
		    $display("SCOREBOARD: PROTOCOL VIOLATION transaction, PADDR=%0h, c1=%0s c2=%0s c3=%0s - not data-checked",
		        rs_trans.PADDR, rs_trans.c1state.name(), rs_trans.c2state.name(), rs_trans.c3state.name());
		    return;
		end
		
		if (rs_trans.PADDR !== ms_trans.PADDR || rs_trans.PWRITE !== ms_trans.PWRITE) begin
			SYNC_ERR++;
			$display("SCOREBOARD ERROR: transaction desync REF(PADDR=%0h,PWRITE=%0b) MON(PADDR=%0h,PWRITE=%0b)", rs_trans.PADDR, rs_trans.PWRITE, ms_trans.PADDR, ms_trans.PWRITE);
			return;
		end
			
		if (rs_trans.PWRITE) begin
			ok = (rs_trans.PSLVERR === ms_trans.PSLVERR);
			if (ok) begin
				$display("SCOREBOARD WRITE MATCH: PADDR=%0h PSLVERR REF=%0b MON=%0b",
					rs_trans.PADDR, rs_trans.PSLVERR, ms_trans.PSLVERR);
				MATCH++;
			end else begin
				$display("SCOREBOARD WRITE MISMATCH: PADDR=%0h PSLVERR REF=%0b MON=%0b",
					rs_trans.PADDR, rs_trans.PSLVERR, ms_trans.PSLVERR);
				MISMATCH++;
			end
		end
		else begin
			ok = (rs_trans.PSLVERR === ms_trans.PSLVERR);
			if (!ok) begin
				$display("SCOREBOARD READ MISMATCH: PADDR=%0h PSLVERR REF=%0b MON=%0b",
					rs_trans.PADDR, rs_trans.PSLVERR, ms_trans.PSLVERR);
			end
			else if (rs_trans.PSLVERR === 1'b0) begin
				if (rs_trans.PRDATA !== ms_trans.PRDATA) begin
					ok = 0;
					$display("SCOREBOARD READ MISMATCH: PADDR=%0h PRDATA REF=%0h MON=%0h",
						rs_trans.PADDR, rs_trans.PRDATA, ms_trans.PRDATA);
				end
			end
			
			if (ok) begin
				$display("SCOREBOARD READ MATCH: PADDR=%0h PSLVERR=%0b PRDATA REF=%0h MON=%0h",
					rs_trans.PADDR, rs_trans.PSLVERR, rs_trans.PRDATA, ms_trans.PRDATA);
				MATCH++;
			end else begin
				MISMATCH++;
			end
		end	
	endtask

	function void report();
		$display("\n======================================================================");
		$display(" APB SCOREBOARD FINAL REPORT : MATCH=%0d MISMATCH=%0d ABORTED=%0d ILLEGAL=%0d SYNC_ERR=%0d",
    			MATCH, MISMATCH, ABORTED, ILLEGAL, SYNC_ERR);
		$display("======================================================================\n");
	endfunction

endclass
