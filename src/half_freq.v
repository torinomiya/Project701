//BCKを1/2分周する。
//lrck_changedに同期させる。

module half_freq(bck, lrck_changed, bck_out);
	input bck;
	input lrck_changed;
	output bck_out;

	reg bck_cnt;

	always @ (negedge bck)
	begin
		if(lrck_changed == 1)
		begin
			bck_cnt <= 0; 
		end
		else
		begin
			bck_cnt <= ~bck_cnt;
		end
	end
	assign bck_out = bck_cnt;
	
endmodule
