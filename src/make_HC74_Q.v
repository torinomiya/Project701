module make_HC74_Q(bck, lrck, HC74_Q);
    
	input bck; //-- bck
	input lrck; //-- Frame sync (asserted for channel A, negated for B)
	output HC74_Q;
    
    reg HC74_Q = 0;

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