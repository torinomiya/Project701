module b32LJ_to_16LJ(bck, data, lrck_32LJ, bck_out, data_out);

	input bck;
	input data;
	input lrck_32LJ;
	output bck_out;
	output data_out;

	reg data_out = 0; 			//bck立下り基準なので、DATA出力は0初期化しておく
	reg[4:0] data_counter = 0 ; //元のI2Sにおける　何bitめのDATAか
	reg[31:0] data_fifo = 0; 	//元のI2S DATA (32bit) を 1sample分格納する

	//BCKを1/2分周
	//lrck_changed はないと、BCKのタイミングが狂うことがある
	reg lrck_changed;
	half_freq half_freq_ins (bck, lrck_changed, bck_out);
	
	//分周したBCKに同期させてDATA出力をする
	reg lrck_before = 0;
	always @ (posedge bck)
	begin
		//lrckの切り替わりを検出、読んでるbitのインデックスを0にする
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