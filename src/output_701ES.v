module output_701ES(bck, lrck, APT_L, APT_R, HC74_Q, HC74_Q_inv);

	// LJ16, BCK = 32fs and LRCK=L when L ch signal input.
	input bck; //-- bck
	input lrck; //-- Frame sync (asserted for channel A, negated for B)
	output APT_L;
	output APT_R;
	output HC74_Q;
	output HC74_Q_inv;
	
	wire HC74_Q;

	// shift LRCK for 8 periods of BCK.  
	make_HC74_Q make_HC74_Q_ins(bck, lrck, HC74_Q);

	assign APT_L = ~HC74_Q & ~lrck;
	assign APT_R = HC74_Q & lrck;
	assign HC74_Q_inv = ~HC74_Q;

endmodule