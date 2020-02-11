//謎のBCK = 128fs出しをしてくる場合
//これををBCK = 32fsの16LJに変換
module CM6631_to_16LJ32fs(bck, data, lrck, bck_701, data_701, lrck_701);

	input bck; //-- bck
	input data; // --data
	input lrck; //-- Frame sync (asserted for channel A, negated for B)
	output bck_701;
	output data_701;
	output lrck_701;

	reg data_701 = 0; 			//bck立下り基準なので、DATA出力は0初期化しておく
	
	//128fsなので1ch 64bit -> 6個数は分用意	
	reg[5:0] data_counter = 0 ; //元のI2Sにおける　何bitめのDATAか
	reg[63:0] data_fifo = 0; 	//元のI2S DATA (32bit) を 1sample分格納する

	//LRCK を 元々のBCK4個ぶん = bck_701 1個分おくらせる OKげ
	//--------------------------------------------------------
	wire lrck_16LJ;
	wire lrck_2delay;
	wire lrck_3delay;
	wire lrck_4delay;
	I2S_to_16LJ64fs delay_lrck (lrck, bck, lrck_1delay);
	I2S_to_16LJ64fs delay_lrck2 (lrck_1delay, bck, lrck_2delay);
	I2S_to_16LJ64fs delay_lrck3 (lrck_2delay, bck, lrck_3delay);
	I2S_to_16LJ64fs delay_lrck4 (lrck_3delay, bck, lrck_4delay);
	assign lrck_701 = lrck_4delay;

	//bckの周波数の半分を出す。
	//--------------------------------------------------------	
	reg lrck_changed;
	wire bck_half;
	half_freq half_freq_1 (bck, 0, bck_half);
	half_freq half_freq_2 (bck_half, lrck_changed, bck_701);

	//data乗せ換え
	//--------------------------------------------------------
	//reg lrck_before = 0;
	reg[3:0] lrck_fifo = 0;
	
	always @ (posedge bck)
	begin
		lrck_changed = 0;
		//lrckの切り替わりを検出、読んでるbitのインデックスを0にする
		//if(lrck_before != lrck_16LJ)
		if(lrck_fifo[3] != lrck_701)
		begin
			data_counter = 0;
			lrck_changed = 1;
		end
		data_fifo[data_counter] = data;
		
		//add
		lrck_fifo = {lrck_fifo[2:0],lrck_701};
		
		data_counter = data_counter + 1;
	end

	always @ (negedge bck_701)
	begin
		data_701 = data_fifo [data_counter / 4];
	end

endmodule
