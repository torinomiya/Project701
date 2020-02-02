module output_701ES(bck, lrck, APT_L, APT_R, HC74_Q, HC74_Q_inv);

// LJ16, BCK = 32fs and LRCK=L when L ch signal input.
input bck; //-- bck
input lrck; //-- Frame sync (asserted for channel A, negated for B)

// for 701ES
output APT_L;
output APT_R;
output HC74_Q;
output HC74_Q_inv;
reg HC74_Q = 0;

//for 701ES
assign APT_L = ~HC74_Q & ~lrck;
assign APT_R = HC74_Q & lrck;

assign HC74_Q_inv = ~HC74_Q;
//assign HC74_Q_inv = lrck ~^ HC74_Q; //LRCKの倍速でどうか試すテスト違いが行くwからず

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