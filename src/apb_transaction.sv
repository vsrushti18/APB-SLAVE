`include "defines.svh"

class apb_transaction;

	typedef enum bit [1:0] {IDLE=2'b00, ILLEGAL=2'b01, SETUP=2'b10, ACCESS=2'b11} apb_state_e;
	
	rand logic PWRITE;
	rand logic [`DATA_WIDTH-1:0] PWDATA;
	rand logic [`ADDR_WIDTH-1:0] PADDR;
	rand logic [(`DATA_WIDTH/8)-1:0] PSTRB;

	rand apb_state_e c1state;
	rand apb_state_e c2state;
	rand apb_state_e c3state;
	
	logic PREADY, PSLVERR;
	logic [`DATA_WIDTH-1:0] PRDATA;

	bit reset_abort;
	bit back_to_back = 0;

	constraint address_range { PADDR inside {[0:255]}; }
	
	constraint pstrb_valid { 
		(PWRITE==1) -> (PSTRB!=0);
		(PWRITE==0) -> (PSTRB==0);		 
	}

	constraint legal_handshake {
		c1state == SETUP;
		c2state == ACCESS;
		c3state == IDLE;
	}
	
	function bit is_legal_transition();
		return (c1state == SETUP && c2state == ACCESS && c3state == IDLE);
	endfunction

	virtual function apb_transaction copy();
		copy = new();
		copy.PWRITE = this.PWRITE;
		copy.PWDATA = this.PWDATA;
		copy.PADDR = this.PADDR;
		copy.PSTRB = this.PSTRB;
		copy.c1state = this.c1state;
		copy.c2state = this.c2state;
		copy.c3state = this.c3state;
		copy.PRDATA = this.PRDATA;
		copy.PREADY = this.PREADY;
		copy.PSLVERR = this.PSLVERR;
		copy.reset_abort = this.reset_abort;
		copy.back_to_back = this.back_to_back;
		return copy;
	endfunction

endclass

class apb_transaction_write extends apb_transaction;
	constraint write_only { PWRITE==1; }
	virtual function apb_transaction copy();
		apb_transaction_write copy1;
		copy1 = new();
		copy1.PWRITE = this.PWRITE;
		copy1.PWDATA = this.PWDATA;
		copy1.PADDR = this.PADDR;
		copy1.PSTRB = this.PSTRB;
		copy1.c1state = this.c1state;
		copy1.c2state = this.c2state;
		copy1.c3state = this.c3state;
		copy1.PRDATA = this.PRDATA;
		copy1.PREADY = this.PREADY;
		copy1.PSLVERR = this.PSLVERR;
		copy1.reset_abort = this.reset_abort;
		copy1.back_to_back = this.back_to_back;
		return copy1;
	endfunction
endclass

class apb_transaction_read extends apb_transaction;
	constraint read_only { PWRITE==0; }
	virtual function apb_transaction copy();
		apb_transaction_read copy2;
		copy2 = new();
		copy2.PWRITE = this.PWRITE;
		copy2.PWDATA = this.PWDATA;
		copy2.PADDR = this.PADDR;
		copy2.PSTRB = this.PSTRB;
		copy2.c1state = this.c1state;
		copy2.c2state = this.c2state;
		copy2.c3state = this.c3state;
		copy2.PRDATA = this.PRDATA;
		copy2.PREADY = this.PREADY;
		copy2.PSLVERR = this.PSLVERR;
		copy2.reset_abort = this.reset_abort;
		copy2.back_to_back = this.back_to_back;
		return copy2;
	endfunction
endclass

class apb_transaction_error extends apb_transaction;
	constraint address_range { PADDR inside {[256:511]}; }
	virtual function apb_transaction copy();
		apb_transaction_error copy3;
		copy3 = new();
		copy3.PWRITE = this.PWRITE;
		copy3.PWDATA = this.PWDATA;
		copy3.PADDR = this.PADDR;
		copy3.PSTRB = this.PSTRB;
		copy3.c1state = this.c1state;
		copy3.c2state = this.c2state;
		copy3.c3state = this.c3state;
		copy3.PRDATA = this.PRDATA;
		copy3.PREADY = this.PREADY;
		copy3.PSLVERR = this.PSLVERR;
		copy3.reset_abort = this.reset_abort;
		copy3.back_to_back = this.back_to_back;
		return copy3;
	endfunction
endclass

class apb_transaction_error_write extends apb_transaction_error;
	constraint write_only { PWRITE == 1; }
	virtual function apb_transaction copy();
		apb_transaction_error_write copy8;
		copy8 = new();
		copy8.PWRITE = this.PWRITE;
		copy8.PWDATA = this.PWDATA;
		copy8.PADDR = this.PADDR;
		copy8.PSTRB = this.PSTRB;
		copy8.c1state = this.c1state;
		copy8.c2state = this.c2state;
		copy8.c3state = this.c3state;
		copy8.PRDATA = this.PRDATA;
		copy8.PREADY = this.PREADY;
		copy8.PSLVERR = this.PSLVERR;
		copy8.reset_abort = this.reset_abort;
		copy8.back_to_back = this.back_to_back;
		return copy8;
	endfunction
endclass


class apb_transaction_error_read extends apb_transaction_error;
	constraint read_only { PWRITE == 0; }
	virtual function apb_transaction copy();
		apb_transaction_error_read copy9;
		copy9 = new();
		copy9.PWRITE = this.PWRITE;
		copy9.PWDATA = this.PWDATA;
		copy9.PADDR = this.PADDR;
		copy9.PSTRB = this.PSTRB;
		copy9.c1state = this.c1state;
		copy9.c2state = this.c2state;
		copy9.c3state = this.c3state;
		copy9.PRDATA = this.PRDATA;
		copy9.PREADY = this.PREADY;
		copy9.PSLVERR = this.PSLVERR;
		copy9.reset_abort = this.reset_abort;
		copy9.back_to_back = this.back_to_back;
		return copy9;
	endfunction
endclass

class apb_transaction_pstrb_full extends apb_transaction_write;
	constraint pstrb_full { PSTRB == {(`DATA_WIDTH/8){1'b1}}; }
	virtual function apb_transaction copy();
		apb_transaction_pstrb_full copy4;
		copy4 = new();
		copy4.PWRITE = this.PWRITE;
		copy4.PWDATA = this.PWDATA;
		copy4.PADDR = this.PADDR;
		copy4.PSTRB = this.PSTRB;
		copy4.c1state = this.c1state;
		copy4.c2state = this.c2state;
		copy4.c3state = this.c3state;
		copy4.PRDATA = this.PRDATA;
		copy4.PREADY = this.PREADY;
		copy4.PSLVERR = this.PSLVERR;
		copy4.reset_abort = this.reset_abort;
		copy4.back_to_back = this.back_to_back;
		return copy4;
	endfunction
endclass

class apb_transaction_pstrb_single_byte extends apb_transaction_write;
	virtual function apb_transaction copy();
		apb_transaction_pstrb_single_byte copy5;
		copy5 = new();
		copy5.PWRITE = this.PWRITE;
		copy5.PWDATA = this.PWDATA;
		copy5.PADDR = this.PADDR;
		copy5.PSTRB = this.PSTRB;
		copy5.c1state = this.c1state;
		copy5.c2state = this.c2state;
		copy5.c3state = this.c3state;
		copy5.PRDATA = this.PRDATA;
		copy5.PREADY = this.PREADY;
		copy5.PSLVERR = this.PSLVERR;
		copy5.reset_abort = this.reset_abort;
		copy5.back_to_back = this.back_to_back;
		return copy5;
	endfunction
endclass

class apb_transaction_pstrb_read_garbage extends apb_transaction_read;
	constraint pstrb_valid{ PSTRB != 0; }
	virtual function apb_transaction copy();
		apb_transaction_pstrb_read_garbage copy6;
		copy6 = new();
		copy6.PWRITE = this.PWRITE;
		copy6.PWDATA = this.PWDATA;
		copy6.PADDR = this.PADDR;
		copy6.PSTRB = this.PSTRB;
		copy6.c1state = this.c1state;
		copy6.c2state = this.c2state;
		copy6.c3state = this.c3state;
		copy6.PRDATA = this.PRDATA;
		copy6.PREADY = this.PREADY;
		copy6.PSLVERR = this.PSLVERR;
		copy6.reset_abort = this.reset_abort;
		copy6.back_to_back = this.back_to_back;
		return copy6;
	endfunction
endclass

class apb_transaction_protocol_violation extends apb_transaction;
	typedef enum { VIA, VSI, VIIll, VIll, VAA} ve;
	rand ve vtype;
	constraint legal_handshake { 1; }
	constraint pick_violation {
		(vtype == VIA) -> (c1state == IDLE && c2state == ACCESS && c3state == IDLE);
		(vtype == VSI) -> (c1state == SETUP && c2state == IDLE && c3state == IDLE);
		(vtype == VIIll) -> (c1state == IDLE && c2state == ILLEGAL && c3state == IDLE);
		(vtype == VIll) -> (c1state == ILLEGAL && c2state == IDLE && c3state == IDLE);
		(vtype == VAA) -> (c1state == SETUP && c2state == ACCESS && c3state == ACCESS);
	}
	virtual function apb_transaction copy();
		apb_transaction_protocol_violation copy7;
		copy7 = new();
		copy7.PWRITE = this.PWRITE;
		copy7.PWDATA = this.PWDATA;
		copy7.PADDR = this.PADDR;
		copy7.PSTRB = this.PSTRB;
		copy7.c1state = this.c1state;
		copy7.c2state = this.c2state;
		copy7.c3state = this.c3state;
		copy7.vtype = this.vtype;
		copy7.PRDATA = this.PRDATA;
		copy7.PREADY = this.PREADY;
		copy7.PSLVERR = this.PSLVERR;
		copy7.reset_abort = this.reset_abort;
		copy7.back_to_back = this.back_to_back;
		return copy7;
	endfunction
endclass
