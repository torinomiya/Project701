//BCKを1/2分周する。
//lrck_changedに同期させる。

module half_freq(bck, lrck_changed, bck_out);
	input bck;
	input lrck_changed;
	output bck_out;

	reg bck_out;

	always @ (negedge bck)
	begin
		if(lrck_changed == 1)
		begin
			bck_out <= 0; 
		end
		else
		begin
			bck_out <= ~bck_out;
		end
	end
	
endmodule
