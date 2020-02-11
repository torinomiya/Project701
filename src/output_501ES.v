module output_501ES(bck, lrck, wclk);

	// LJ16, BCK = 32fs and LRCK=L when L ch signal input.
	input bck; //-- bck
	input lrck; //-- Frame sync (asserted for channel A, negated for B)
	output wclk;

	wire HC74_Q;

	make_HC74_Q make_HC74_Q_ins(bck, lrck, HC74_Q);

	//1DACでLRを時分割で出す場合、2*LRCKが必要
	assign wclk = lrck ~^ HC74_Q;

endmodule