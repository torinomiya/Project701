//lrck_I2SのばあいはBCK1個分ずらす
module I2S_to_16LJ64fs (lrck, bck, lrck_16LJ);

	input lrck;
	input bck;
	output lrck_16LJ;
	reg lrck_16LJ;
	reg lrck_before;

	always @ (posedge bck)
	begin
		lrck_before <= lrck;
	end

	always @ (negedge bck)
	begin
		lrck_16LJ <= lrck_before;
	end

endmodule
