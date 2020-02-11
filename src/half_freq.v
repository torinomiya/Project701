
//bckの周波数の半分を出す。
//--------------------------------------------------------	

module half_freq(bck, lrck_changed, bck_701);

	input bck; //-- bck
	input lrck_changed; //-- Frame sync (asserted for channel A, negated for B)
	output bck_701;

	reg bck_cnt;

	always @ (negedge bck)
	begin
		if(lrck_changed == 1)
		begin
			bck_cnt = 0; 
		end
		else
		begin
			bck_cnt = ~bck_cnt;
		end
	end
	assign bck_701 = bck_cnt;
	
endmodule
