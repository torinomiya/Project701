//CM6631の出してくるBCK=128fsのBCKを、64fsに変更する
module CM6631_to_I2S64fs(bck, data, lrck, bck_out, data_out, lrck_out);

	input bck; //-- bck
	input data; // --data
	input lrck; //-- Frame sync (asserted for channel A, negated for B)
	output bck_out;
	output data_out;
	output lrck_out;

	assign lrck_out = lrck;

	//LRCK を 元々の2周期分遅らせたデータを使用する
	wire lrck_32LJ;
	delay_1BCK I2S_to_32LJ (lrck, bck, lrck_32LJ);

	//BCK及びDATAの乗せ換え
	b32LJ_to_16LJ b32LJ_to_16LJ_ins(bck, data, lrck_32LJ, bck_out, data_out);

endmodule
