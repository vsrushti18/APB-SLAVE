`include "defines.svh"

class apb_reference_model;
	
	apb_transaction ref_trans;
	mailbox #(apb_transaction) mbx_dr;
	mailbox #(apb_transaction) mbx_rs;

	logic [`DATA_WIDTH-1:0] mem [256];
	int num_trans;
	
	function new (mailbox #(apb_transaction) mbx_dr,
			mailbox #(apb_transaction) mbx_rs);
		this.mbx_dr = mbx_dr;
		this.mbx_rs = mbx_rs;
		foreach(mem[i]) mem[i]='0;
	endfunction
	
	task start();
		for(int i=0; i<num_trans; i++) begin	
			mbx_dr.get(ref_trans);
			if (ref_trans.reset_abort) begin
				$display("REF MODEL: transaction ABORTED by reset, PADDR=%0h skipped",
				          ref_trans.PADDR);
			end else if (!ref_trans.is_legal_transition()) begin
				$display("REF MODEL: illegal handshake, PADDR=%0h - no transfer occurred, skipping",
				          ref_trans.PADDR);		 
			end else if (!(ref_trans.PADDR inside {[0:255]})) begin
				ref_trans.PSLVERR = 1'b1;
				$display("REF MODEL: OUT-OF-RANGE PADDR=%0h -> PSLVERR=1", ref_trans.PADDR);
			end else begin
				ref_trans.PSLVERR = 1'b0;
				if (ref_trans.PWRITE) begin
					for (int k = 0; k < (`DATA_WIDTH/8); k++) begin
				        	if (ref_trans.PSTRB[k])
				            		mem[ref_trans.PADDR][k*8 +: 8] = ref_trans.PWDATA[k*8 +: 8];
					end
					$display("REF MODEL WRITE mem[%0h]=%0h (PSTRB=%0b)", ref_trans.PADDR, mem[ref_trans.PADDR], ref_trans.PSTRB);
				end else begin
				    	ref_trans.PRDATA = mem[ref_trans.PADDR];
				    	$display("REF MODEL READ PRDATA=%0h from mem[%0h]",
				              ref_trans.PRDATA, ref_trans.PADDR);
				end
			end
			mbx_rs.put(ref_trans);
		end
	endtask
endclass
