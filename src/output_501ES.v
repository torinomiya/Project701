module output_501ES(bck, lrck, wclk);

	input bck;
	input lrck;
	output wclk;
	wire delayed_lrck;
	delay_8BCK delay_8BCK_ins(bck, lrck, delayed_lrck);

	//1DACでLRを時分割で出す場合、2*LRCKが必要
	assign wclk = lrck ~^ delayed_lrck;

endmodule