//OKそう
//I2SをBCK = 32fsの16LJに変換
module I2S_to_16LJ32fs(bck, data, lrck, bck_701, data_701, lrck_701);

input bck; //-- bck
input data; // --data
input lrck; //-- Frame sync (asserted for channel A, negated for B)
output bck_701;
output data_701;
output lrck_701;

//bck立下り基準なので、最初こいつも立ち下がらないといけない
reg data_701 = 0;
reg[4:0] data_counter = 0 ; //何個めのDATAか
reg[31:0] data_fifo = 0; //dataを格納しとくレジスタ

//I2Sの場合 -> LRCK を BCKいっこぶん遅らせる
wire lrck_16LJ;
I2S_to_16LJ64fs I2S_to_16LJ64fs_ins (lrck, bck, lrck_16LJ);

//更にもう１BCK遅らせる
wire lrck_2delay;
I2S_to_16LJ64fs delay_lrck (lrck_16LJ, bck, lrck_2delay);
assign lrck_701 = lrck_2delay;


//bckの周波数の半分を出す。
//5/14 fix negedgeだと50%くらいの確立でノイズ。-> たぶん前のWordのLSBを読んじゃうため。
//bck cntとbckのたいみんぐが逆になるよ　初期化したほうがよい？
/*
reg bck_cnt = 0;
always @ (posedge bck) 
begin
	bck_cnt <= ~bck_cnt;
end
assign bck_701 = bck_cnt;
*/

reg bck_cnt;
reg lrck_changed;
always @ (negedge bck)
begin
	if(lrck_changed == 1)
	begin
		bck_cnt = 0; 
	end
	else
	begin
		bck_cnt = ~bck_cnt;
	end
end
assign bck_701 = bck_cnt;

//data乗せ換え
//data_counter で元の何個めのデータか把握。
reg lrck_before = 0;
always @ (posedge bck)
begin
	lrck_changed = 0;
	//lrckの切り替わりを検出、添え字を0に
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

/*
//BCK = 32fsの場合何個目かっているので見る
reg[4:0] data_counter_32fs = 0; //BCK=32fsとした場合、何個めのDATAか
always @ (negedge bck_701)
begin
	data_701 <= data_fifo[data_counter_32fs];
	data_counter_32fs = data_counter_32fs + 1;
end
*/

endmodule
