//I2Sを16LJに変換
module I2S_to_16LJ(bck, data, lrck, bck_out, data_out, lrck_out);

	input bck;
	input data;
	input lrck;
	output bck_out;
	output data_out;
	output lrck_out;

	reg data_out = 0; 			
	reg[4:0] data_counter = 0 ; //元のI2Sにおける何bitめのDATAか
	reg[31:0] data_fifo = 0; 	//元のI2S DATA (32bit) を 1sample分格納する

	//LRCK を 元々のBCK2周期分遅らせる
	wire lrck_32LJ;
	delay_1BCK I2S_to_32LJ (lrck, bck, lrck_32LJ);
	delay_1BCK delay (lrck_32LJ, bck, lrck_out);	
	
	//BCKを2分周
	//lrck_changed はないと、BCKのタイミングが狂うことがある
	reg lrck_changed;
	half_freq half_freq_ins (bck, lrck_changed, bck_out);
	
	//分周したBCKに同期させてDATA出力をする
	reg lrck_before = 0;
	always @ (posedge bck)
	begin
		if(lrck_before != lrck_32LJ)
		begin
			data_counter = 0;
			lrck_changed <= 1;
		end
		else
		begin
			lrck_changed <= 0;
		end
		data_fifo[data_counter] = data;
		lrck_before = lrck_32LJ;
		data_counter = data_counter + 1;
	end

	always @ (negedge bck_out)
	begin
		data_out <= data_fifo [data_counter / 2];
	end

endmodule
