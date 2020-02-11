//I2SをBCK = 32fsの16LJに変換
module I2S_to_16LJ32fs(bck, data, lrck, bck_701, data_701, lrck_701);

	input bck; //-- bck
	input data; // --data
	input lrck; //-- Frame sync (asserted for channel A, negated for B)
	output bck_701;
	output data_701;
	output lrck_701;

	reg data_701 = 0; 			//bck立下り基準なので、DATA出力は0初期化しておく
	reg[4:0] data_counter = 0 ; //元のI2Sにおける　何bitめのDATAか
	reg[31:0] data_fifo = 0; 	//元のI2S DATA (32bit) を 1sample分格納する

	//LRCK を 元々のBCK2個ぶん = bck_701 1個分おくらせる
	//--------------------------------------------------------
	wire lrck_16LJ;
	I2S_to_16LJ64fs I2S_to_16LJ64fs_ins (lrck, bck, lrck_16LJ);
	wire lrck_2delay;
	I2S_to_16LJ64fs delay_lrck (lrck_16LJ, bck, lrck_2delay);
	assign lrck_701 = lrck_2delay;


	//bckの周波数の半分を出す。
	//--------------------------------------------------------	
	reg lrck_changed;
	half_freq half_freq_1 (bck, lrck_changed, bck_701);
	

	//data乗せ換え
	//--------------------------------------------------------
	reg lrck_before = 0;
	always @ (posedge bck)
	begin
		lrck_changed = 0;
		//lrckの切り替わりを検出、読んでるbitのインデックスを0にする
		if(lrck_before != lrck_16LJ)
		begin
			data_counter = 0;
			lrck_changed = 1;
		end
		data_fifo[data_counter] = data;
		lrck_before = lrck_16LJ;
		data_counter = data_counter + 1;
	end

	always @ (negedge bck_701)
	begin
		data_701 = data_fifo [data_counter / 2];
	end

endmodule
