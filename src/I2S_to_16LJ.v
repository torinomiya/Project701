//I2Sを16LJに変換
module I2S_to_16LJ(bck, data, lrck, bck_out, data_out, lrck_out);

	input bck;
	input data;
	input lrck;
	output bck_out;
	output data_out;
	output lrck_out;

	//LRCK を 元々のBCK2周期分遅らせる
	wire lrck_32LJ;
	delay_1BCK I2S_to_32LJ (lrck, bck, lrck_32LJ);
	
	//BCK及びDATAの乗せ換え
	b32LJ_to_16LJ b32LJ_to_16LJ_ins(bck, data, lrck_32LJ, bck_out, data_out);

	delay_1BCK delay (lrck_32LJ, bck, lrck_out);

endmodule
