//lrck_I2SのばあいはBCK1個分ずらす
module delay_1BCK (lrck, bck, lrck_out);

	input lrck;
	input bck;
	output lrck_out;
	
	reg lrck_out;
	reg lrck_before;

	always @ (posedge bck)
	begin
		lrck_before <= lrck;
	end

	always @ (negedge bck)
	begin
		lrck_out <= lrck_before;
	end

endmodule
