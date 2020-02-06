module output_501ES(bck, lrck, wclk);

	// LJ16, BCK = 32fs and LRCK=L when L ch signal input.
	input bck; //-- bck
	input lrck; //-- Frame sync (asserted for channel A, negated for B)

	output wclk;
	reg HC74_Q = 0;

    //1DACでLRを時分割で出す場合
	assign wclk = lrck ~^ HC74_Q;
	// assign wclk = lrck;

	//BCK8こまえのLRCKを出す
	reg[7:0] lrck_fifo;
	always @ (posedge bck)
	begin
		lrck_fifo <= {lrck_fifo[6:0],lrck};
	end
	always @ (negedge bck)
	begin
		HC74_Q <= lrck_fifo[7];
	end

endmodule