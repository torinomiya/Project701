//BCK8こまえのLRCKを出す
module delay_8BCK(bck, lrck, lrck_out);
    
	input bck;
	input lrck;
	output lrck_out;
    reg lrck_out = 0;

	reg[7:0] lrck_fifo;
	always @ (posedge bck)
	begin
		lrck_fifo <= {lrck_fifo[6:0],lrck};
	end
	always @ (negedge bck)
	begin
		lrck_out <= lrck_fifo[7];
	end

endmodule