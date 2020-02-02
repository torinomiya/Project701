/*-------------------------------------------------------------------------------
-- AES3 / SPDIF Minimalistic Receiver
-- Version 0.9
-- Petr Nohavica (c) 2009
-- Released under GNU Lesser General Public License
-- Original target device: Xilinx Spartan-3AN family

-- + Verilog porting by tako (2016/10/10)
-------------------------------------------------------------------------------
*/

module aes3_rx(clk, aes3, reset, sdata, sclk, bsync, lrck, active);

input clk; //-- Master clock
input aes3; //-- AES3/SPDIF compatible input signal
input reset; //-- Synchronous reset
output sdata; //-- Serial data out
output sclk; //-- AES3 clock out
output bsync; //-- Block start (asserted when Z subframe is being transmitted
output lrck; //-- Frame sync (asserted for channel A, negated for B)
output active; //-- Receiver has (probably) valid data on its output

reg sdata = 0;
reg sclk = 0;
reg bsync = 0;
reg lrck = 0;
reg active = 0;

//generic文の代わりにとりあえずparameterで、、
parameter reg_width = 5;

//HDL の同時処理文はノンブロッキング代入
parameter X_PREAMBLE = 8'b01000111;
parameter Y_PREAMBLE = 8'b00100111;
parameter Z_PREAMBLE = 8'b00010111;

//ステートマシンを作るようのparameter
parameter LOCKING = 2'b00;
parameter CONFIRMING = 2'b01;
parameter LOCKED = 2'b11;

reg [3:0] aes3_sync = 4'd0;
reg change = 0;
reg aes3_clk = 0;
reg [7:0] decoder_shift = 8'd0;
reg align_counter = 0;
reg [(reg_width - 1):0] clk_counter = {reg_width{1'b0}};
reg [5:0] sync_cnt = 6'd0; //Counts aes3_clk pulses per frame (for locking reasons)
reg [(reg_width-1):0] reg_clk_period = {reg_width{1'b1}};
reg sync_lost = 1;
//regかも
wire preamble_detected;
reg bsync_int = 0;
reg lrck_int = 0;
reg sdata_int = 0;
reg [1:0] lock_state = LOCKING;
reg [1:0] lock_state_next;

//Signal indicating some error in received AES3, used primarily by locking state machine
wire lock_error;
reg sync_cnt_full;
reg aes3_clk_activity = 0;
reg x_detected = 0;
reg y_detected = 0;
reg z_detected = 0;

always @ (posedge clk)
begin
	if (reset==1'b1)
		aes3_sync[3:0] = 0;
	else
	//VHDL連接演算&はVerilogだとそのままでは論理積なので注意
	//Shift by serial aes3 signal become MSB.
		aes3_sync = {aes3, aes3_sync[3:1]};

	if (reset==1'b1)
		change = 0;
	else
		change = aes3_sync[2] ^ aes3_sync[1];

	// Counts number of aes3_clk pulses since last preamble detection, used by locking state machine
	if (reset==1'b1)
		sync_cnt <= 0;
	else if (aes3_clk==1'b1)
	begin
		if (preamble_detected == 1'b1)
			sync_cnt <= 0;
		else
			sync_cnt <= sync_cnt + 1;
	end
end

always @ (sync_cnt)
begin
	if (sync_cnt==6'd63)
		sync_cnt_full <= 1;
	else
		sync_cnt_full <= 0;
end

// Lock error when syc_cnt is full and no preample detected
assign lock_error = (sync_cnt_full & ~preamble_detected) | (~sync_cnt_full & preamble_detected) | (change & ~aes3_clk_activity);

always @ (posedge clk)
begin
	if (reset == 1'b1)
		//すべてのビットを1にしたい
		reg_clk_period <= {reg_width{1'b1}};
	else if ((lock_state == LOCKED) && (lock_state_next == LOCKING))
		reg_clk_period <= {reg_width{1'b1}};
	else if ((aes3_clk == 1 && sync_cnt_full == 1 && lock_state_next == LOCKING) || (change == 1 && aes3_clk_activity == 0))
		reg_clk_period <= reg_clk_period - 1;
end

always @ (lock_state, preamble_detected, sync_cnt_full, lock_error)
begin
	case(lock_state)
		LOCKING:
			if (preamble_detected == 1'b1)
				lock_state_next <= CONFIRMING;
			else
				lock_state_next <= LOCKING;

		CONFIRMING:
			if (lock_error == 1'b1)
				lock_state_next <= LOCKING;
			else if (sync_cnt_full == 1'b1 && preamble_detected == 1'b1 )
				lock_state_next <= LOCKED;
			else
				lock_state_next <= CONFIRMING;

		LOCKED:
			if (lock_error == 1'b1)
				lock_state_next <= LOCKING;
			else
				lock_state_next <= LOCKED;
	endcase
end

always @ (lock_state)
begin
	if (lock_state == LOCKED)
		sync_lost <= 0;
	else
		sync_lost <= 1;
end

always @ (posedge clk)
begin
	if (reset == 1'b1)
		lock_state <= LOCKING;
	else if ((aes3_clk == 1'b1) || ((change == 1'b1) && (aes3_clk_activity == 0)))
		lock_state <= lock_state_next;
end

always @ (posedge clk)
begin
	if (reset == 1'b1)
		clk_counter <= 0;

	else if ((change == 1'b1) || (clk_counter == 0))
	begin
		if (change == 1'b1)
			clk_counter <= {1'b0, reg_clk_period[reg_width - 1:1]};
		else
			clk_counter <= reg_clk_period;
	end
	else
		clk_counter <= clk_counter - 1;
end

always @ (posedge clk)
begin
	if (reset == 1'b1)
		aes3_clk <= 0;
	else
	begin
		if (clk_counter == 0)
			aes3_clk <= 1'b1;
		else
			aes3_clk <= 0;
	end
end

always @ (posedge clk)
begin
	if (reset == 1'b1)
		aes3_clk_activity <= 0;
	else
	begin
		if (change == 1'b1)
			aes3_clk_activity <= 0;
		else
			aes3_clk_activity <= 1'b1;
	end
end

always @ (posedge clk)
begin
	if (reset == 1'b1)
		decoder_shift <= 0;
	else if (aes3_clk == 1'b1)
		decoder_shift <= {aes3_sync[0],decoder_shift[7:1]};
end

//Preamble detectors (implemented using comparators)
//明らかに関数にしたいよね
always @ (decoder_shift)
begin
	//1,0逆にしたの両方に対応
	if ((decoder_shift == X_PREAMBLE) || (decoder_shift == ~X_PREAMBLE))
		x_detected <= 1'b1;
	else
		x_detected <= 0;

	if ((decoder_shift == Y_PREAMBLE) || (decoder_shift == ~Y_PREAMBLE))
		y_detected <= 1'b1;
	else
		y_detected <= 0;

	if ((decoder_shift == Z_PREAMBLE) || (decoder_shift == ~Z_PREAMBLE))
		z_detected <= 1'b1;
	else
		z_detected <= 0;

end

assign preamble_detected = x_detected | y_detected | z_detected;

//One bit counter used for correct bit alignment
always @ (posedge clk)
begin
	if (reset == 1'b1)
		align_counter <= 0;
	else if (aes3_clk == 1'b1)
	begin
		if (preamble_detected == 1'b1)
			align_counter <= 0;
		else
			align_counter <= ~align_counter;
	end
end

//Drives lrck and bsync signals
always @ (posedge clk)
begin
	if ((aes3_clk == 1'b1) && (preamble_detected == 1'b1))
	begin
		lrck_int <= x_detected | z_detected;
		bsync_int <= z_detected;
	end
end

//00 or 11 -> 0 / 01 or 10 -> 1 BMC
always @ (posedge clk)
begin
	if ((aes3_clk == 1'b1) && (align_counter == 1'b1))
		sdata_int <= decoder_shift[1] ^ decoder_shift[0];
end

//synchronization and activity signals outputs
always @ (posedge clk)
begin
	active <= ~sync_lost;
	lrck <= lrck_int & ~sync_lost;
	bsync <= bsync_int & ~sync_lost;
	sclk <= align_counter & ~sync_lost;
	sdata <= sdata_int & ~sync_lost;
end

endmodule
